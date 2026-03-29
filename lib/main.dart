import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'services/hive_service.dart'; 
import 'views/add_product_page.dart'; 
import 'views/add_driver_and_work.dart'; 
import 'views/help_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart'; // ئەمە زیاد بکە بۆ ناسینەوەی وێب
import 'package:flutter/services.dart'; // بۆ SystemNavigator پێویستە


const kBgLight = Color(0xFFDCE6DF); 
const kPrimaryGreen = Color(0xFF0A2E29); 
const kSecondaryGreen = Color(0xFF144D45); 
const kAccentNeon = Color(0xFF4CA67D); 
bool isNum = true;

late HiveService hiveService;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  hiveService = await HiveService.create();


  await Supabase.initialize(
    url: 'https://fljchnkqhaopmlexsuru.supabase.co',
    anonKey: 'sb_publishable_oKnrwnECmxcYk5YtHhQK-Q_bsbgZfci',
  );

  // لێرە پشکنین دەکەین بزانین پێشتر لۆگین کراوە یان نا
  final prefs = await SharedPreferences.getInstance();
  final int? savedId = prefs.getInt('farmer_id');
  final String? savedCode = prefs.getString('farmer_code');
  final String? savedJob = prefs.getString('job_title');
  final String? savedName = prefs.getString('farmer_name');
  Widget startPage;
  
  if (savedId != null && savedCode != null && savedJob != null) {
    // ئەگەر زانیاری هەبوو، یەکسەر دەچێتە لاپەڕەی مەبەست
    if (savedJob == "سایەق مەکینە") {
      startPage = AddDriverAndWorkPage(farmerId: savedId, farmerName: savedName ?? "", farmerCode: savedCode);
    } else {
      startPage = AddFarmerDataPage(farmerId: savedId, farmerName: savedName ?? "", farmerCode: savedCode);
    }
  } else {
    // ئەگەر یەکەم جاری بێت، دەچێتە هۆم
    startPage = const HomePage();
  }

  runApp(MyApp(startWidget: startPage));
}

class MyApp extends StatelessWidget {
  final Widget startWidget;
  const MyApp({super.key, required this.startWidget});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmer App', // ناوی ئەپەکەت
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.green,
        fontFamily: 'KurdishFont', 
      ),
      
      builder: (context, child) {
        return MediaQuery(
          // ئەم دێڕە ڕێگری دەکات لە گەورەبوونی فۆنت
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling, 
          ),
          child: child!,
        );
      },
      home: startWidget,
    );
  }
}

class applink {
  static Future<void> launchYoutubeVideo() async {
    final Uri _url = Uri.parse('https://www.youtube.com/watch?v=myVcct1mZM4');
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }
}
class EnglishNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;
    
    // لیستی گۆڕینی ژمارەکان
    const kurdish = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    for (int i = 0; i < 10; i++) {
      text = text.replaceAll(kurdish[i], english[i]);
      text = text.replaceAll(persian[i], english[i]);
    }

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
  }

// لە ناو initState بانگی بکە

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.height < 700;

    return Scaffold(
      backgroundColor: kBgLight,
      endDrawer: _buildCustomDrawer(context), 
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipPath(
                        clipper: CustomHeaderClipper(),
                        child: Container(
                          height: size.height * 0.38,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [kPrimaryGreen, kSecondaryGreen],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                          ),
                          child: SafeArea(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/app_icons.png',
                                  height: isSmallScreen ? 80 : 100, 
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 5), 
                                Text(
                                  "فەلاحی زیرەک",
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 24 : 30, 
                                    color: Colors.white, 
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "بۆ تۆمارکردنی مەواد و کارەکان وە ژمێریاری بەشێوەی زیرەک",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 12 : 14, 
                                      color: Colors.white.withValues(alpha: .7)
                                    ),
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 20 : 40), 
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 20,
                        child: Builder(builder: (context) => InkWell(
                          onTap: () => Scaffold.of(context).openEndDrawer(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.menu_open_rounded, size: 35, color: Colors.white),
                              const Text("ڕێنمای", style: TextStyle(
                                fontSize: 12, 
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(blurRadius: 2, color: Colors.black26)] 
                              )),
                            ],
                          ),
                        )),
                      ),
                    ],
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        _buildMainCard(
                          context,
                          title: "جوتیار",
                          subtitle: "تۆمارکردنی کڕین و خەرجی",
                          icon: Icons.eco_rounded,
                          iconColor: const Color(0xFF4CA67D), 
                          onTap: () => _showCodeInputDialog(context, "جوتیار"),
                        ),
                        const SizedBox(height: 15),
                        _buildMainCard(
                          context,
                          title: "خاوەن مەکینە",
                          subtitle: "تۆمارکردنی جوتیار و ئیشەکانی ",
                          icon: Icons.agriculture_rounded, 
                          iconColor: const Color(0xFF4CA67D), 
                          onTap: () => _showCodeInputDialog(context, "سایەق مەکینە"),
                        ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () => _showLoginDialog(context),
                          icon: const Icon(Icons.history_rounded, size: 18, color: kPrimaryGreen),
                          label: Text(
                            "پێشتر کۆدم هەبووە ؟ بگەڕێ..", 
                            style: TextStyle(
                              fontSize: isSmallScreen ? 15 : 18, 
                              color: kPrimaryGreen, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.fromLTRB(70, 0, 70, MediaQuery.of(context).size.height * 0.14),
            child: Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kAccentNeon.withValues(alpha: .3), 
                    blurRadius: 15, 
                    offset: const Offset(0, 8)
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => applink.launchYoutubeVideo(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentNeon,
                  foregroundColor: kPrimaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.play_circle_fill, size: 25),
                label: const Text(
                  "چۆنیەتی بەکارهێنان(Youtube)", 
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(BuildContext context, {
    required String title, 
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap, 
    Color iconColor = const Color(0xFF4CA67D), 
  }) {   
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .06), 
              blurRadius: 20, 
              offset: const Offset(0, 10)
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title, 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryGreen)
                  ),
                  Text(
                    subtitle, 
                    style: const TextStyle(fontSize: 12, color: Colors.grey)
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kBgLight, 
                borderRadius: BorderRadius.circular(15)
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: kPrimaryGreen),
            child: Center(child: Icon(Icons.eco_rounded, size: 80, color: kAccentNeon)),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: kPrimaryGreen), 
            title: const Text("ڕێنمای چالاککردن و بەکارهێنان", style: TextStyle(fontSize: 15, color: kPrimaryGreen, fontWeight: FontWeight.bold)), 
            onTap: () {
              Navigator.pop(context); 
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const HelpPage()),
              );
            }
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("بۆ هەر پرسیار و ڕێنماییەک یان کۆدی چالاک کردن\n :پەیوەندی بکە\n0772 152 5711 \n0750 178 3028\n", 
              style: TextStyle(color:kPrimaryGreen, fontSize: 16), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  void _showCodeInputDialog(BuildContext context, String jobTitle) {
    final TextEditingController codeController = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("کۆدی $jobTitle", textAlign: TextAlign.right),
      content: TextField(controller: codeController, textAlign: TextAlign.center, decoration: const InputDecoration(hintText: "کۆدەکە لێرە بنووسە")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("گەڕانەوە")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
          onPressed: () async {
            final String inputCode = codeController.text.trim();
            if (inputCode.isEmpty) return;
            final codeResponse = await Supabase.instance.client.from('tb_codes').select().eq('code_value', inputCode).maybeSingle();
            if (codeResponse != null) {
              if (codeResponse['is_used'] == true) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ئەم کۆدە پێشتر بەکارهاتووە")));
              } else {
                Navigator.pop(context);
                _showCreateProfileDialog(context, inputCode, jobTitle);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("کۆدەکە بوونی نییە")));
            }
          },
          child: const Text("پشکنین", style: TextStyle(color: Colors.white)),
        )
      ],
    ));
  }
  
  

  void _showCreateProfileDialog(BuildContext context, String code, String job) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(
      title: const Text("تەواوکردنی زانیارییەکان", textAlign: TextAlign.right),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: nameController, textAlign: TextAlign.right,
           decoration: const InputDecoration(labelText: "ناو دوانی(نازناو)")),
          TextField(controller: phoneController, textAlign: TextAlign.right, 
          decoration: const InputDecoration(labelText: "ژمارە مۆبایل"),
          inputFormatters: isNum ? [ EnglishNumberFormatter()] : [],
           keyboardType: TextInputType.phone),
        ],
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
          onPressed: () async {
            if (nameController.text.isEmpty || phoneController.text.isEmpty) return;
            final response = await Supabase.instance.client.from('tb_farmer').insert({
              'code_farmer': code,
              'name_farmer': nameController.text,
              'phone_farmer': phoneController.text,
              'job_title': job,
              'create_date': DateTime.now().toIso8601String(),
              'expiry_date': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
            }).select().single();
            await Supabase.instance.client.from('tb_codes').update({'is_used': true}).eq('code_value', code);
            
            if (context.mounted) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('farmer_id', response['id_farmer']);
              await prefs.setString('farmer_code', code);
              await prefs.setString('job_title', job);
              await prefs.setString('farmer_name', response['name_farmer']);

              Navigator.pop(context);
              
              if (job == "سایەق مەکینە") {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddDriverAndWorkPage(farmerId: response['id_farmer'], farmerName: response['name_farmer'], farmerCode: code)));
              } else {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddFarmerDataPage(farmerId: response['id_farmer'], farmerName: response['name_farmer'], farmerCode: code)));
              }
            }
          },
          child: const Text("تۆمارکردن", style: TextStyle(color: Colors.white)),
        )
      ],
    ));
  }

  void _showLoginDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("کۆدەکەت بنووسە", textAlign: TextAlign.right),
      content: TextField(controller: controller, textAlign: TextAlign.center),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("داخستن")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
          onPressed: () async {
            final String inputCode = controller.text.trim();
            final response = await Supabase.instance.client.from('tb_farmer').select().eq('code_farmer', inputCode).maybeSingle();
            if (response != null && context.mounted) {
               final prefs = await SharedPreferences.getInstance();
               await prefs.setInt('farmer_id', response['id_farmer']);
               await prefs.setString('farmer_code', inputCode);
               await prefs.setString('job_title', response['job_title']);
               await prefs.setString('farmer_name', response['name_farmer']);

               Navigator.pop(context);
               
               if (response['job_title'] == "سایەق مەکینە") {
                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddDriverAndWorkPage(farmerId: response['id_farmer'], farmerName: response['name_farmer'], farmerCode: inputCode)));
               } else {
                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddFarmerDataPage(farmerId: response['id_farmer'], farmerName: response['name_farmer'], farmerCode: inputCode)));
               }
            } else {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("پڕۆفایل نەدۆزرایەوە")));
            }
          },
          child: const Text("گەڕان", style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}

class CustomHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;


}