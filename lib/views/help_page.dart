import 'package:flutter/material.dart';
import 'package:farmer_app/main.dart';
import 'package:farmer_app/views/admin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // دڵنیابە ئەمەت ئیمپۆرت کردووە
  class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  int _clickCount = 0; // بۆ ژماردنی کلیکەکان

  // فەنکشنی پشکنینی لۆگین
  void _showAdminLogin() {
    final TextEditingController userController = TextEditingController();
    final TextEditingController passController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text("چوونەژوورەوەی ئەدمین"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userController,
                decoration: const InputDecoration(labelText: "ناوی بەکارهێنەر"),
              ),
              TextField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "وشەی تێپەڕ"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("داخستن"),
            ),
            ElevatedButton(
              onPressed: () async {
                final String envUser = dotenv.env['ADMIN_USER'] ?? ""; 
                final String envPass = dotenv.env['ADMIN_PASS'] ?? "";
                // لێرە یوزەر و پاسۆردە نهێنییەکەی خۆت دابنێ
                if (userController.text == envUser && passController.text == envPass) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('is_admin_logged_in', true);
                  if (!context.mounted) return; // دڵنیابوونەوە لەوەی پەیجەکە هێشتا ماوە
                  Navigator.pop(context); // داخستنی دیالۆگەکە
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminControlPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("زانیارییەکان هەڵەن!")),
                  );
                }
              },
              child: const Text("چوونەژوورەوە"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: GestureDetector(
            onTap: () {
              _clickCount++;
              if (_clickCount >= 5) {
                _clickCount = 0; // سفرکردنەوەی ژمارەکە
                _showAdminLogin(); // پیشاندانی لۆگین
              }
            },
            child: const Text("  ڕێنماییەکان  ", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF144D45),
          foregroundColor: Colors.white,
        ),

           body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
            _buildHeaderCard("زانیاری گشتی", Icons.info, Colors.blue.shade800),
            _instructionStep("سیستەمی فەلاحی زیرەک ئەپێکە بۆ تۆمار کردنی ئیش و حساباتی جوتیار و خاوەن مەکینە لە کۆگا(گۆگڵ)،واتا تەنانەت ئەگەر مۆبایلەکەشت بفەوتێ تەنها کۆدەکە لە مۆبایلێکیتر بنوسە هەموو زانیاریەکانت وەکخۆی دێتەوە و هیچکاتێک نافەوتێت. "),
            _instructionStep("بۆچالاککردنی ئەم بەرنامە پێویستت بەکۆدە دەتوانی لە ڕێگەی پەیوەندی تەلەفونی یان لە وەتس ئەپ و ڤایبەر یەیوەندی بکەیت بۆ وەرگرتنی کۆد یان هەر ڕێنمایی و پرسیارێک."),
            _instructionStep("سیستەمی فەلاحی زیرەک بەردەوام نوێبونەوە(ئەپدەیت) دەکرێت لەسەر داوای بەکارهێنەران بۆ زیاتر بەرەوپێشچونی وەساڵانە چالاکدەکرێتەوە."),
            // بەشی جووتی
            _buildHeaderCard(
              "ڕێنمایی جووتیاران", 
              Icons.agriculture, 
              Colors.green.shade800
            ),
            _instructionStep("جوتیاری بەڕێز لەڕێگەی ئەم بەرنامەوە دەتوانی زۆر بەوردی وئاسانی ئاگاداری هەموو ئەو مەواد و مەسروفانە بیت کەدەیانکڕیت لەماوەی ئەو ساڵەدا."),
            _instructionStep("سەرەتا یەکجار ناو یان نازناوی دوکانە کشتوکالیەکە تۆمار بکە لە هەبونی ئینتەرنێتدا،وە لە لیستی جوتیار سەیری بکەرەوە ."),
            _instructionStep("دواتر دەتوانی مەوادەکانی دوکانەکە تۆمار بکەی لەنەبوونی  ئینتەرنێتدا،وەتۆمار کردنی مەسروفەکان لەنەبونی خەت,\nتەنها دواتر چویتەوە خەت یەکجار ئایکۆنی سەرەوەی لای ڕاست 🔄️ دابگرە هەموو تۆمار کراوەکان پاشەکەوت دەبن بۆ کۆگا(سێرڤەر)ی گۆگڵ."),
            _instructionStep("لەبەشی کۆی گشتی کڕین و مەسروف دەتوانی بڕی هەموو ئەو مەوادو و کڕینانە کەلە هەر دوکانێک کردوتە بە جیا ببینیتەوە،\nهەروەها هەموو مەسروفەکانت لەو ساڵەدا."),

            const SizedBox(height: 25),

            // بەشی خاوەن مەکینە
            _buildHeaderCard(
              "ڕێنمایی خاوەن مەکینە", 
              Icons.settings_suggest, 
              Colors.blue.shade800
            ), 
            _instructionStep("بەڕێزت دەتوانی لەڕێگەی ئەم بەرنامەوە ناوی جوتیارەکانت و ئیشەکانیان تۆمار بکەت،\nوە هەموو ئەو مەسروفانەی کە دەیکەیت لە ماوەی ئەو ساڵەدا."),
            _instructionStep("سەرەتا لەهەبوونی ئینتەرنێتدا یەکجار ناو یان نازناوی جوتیارەکە تۆمار بکە و لە لیستی جوتیار سەیری بکەرەوە."),
            _instructionStep("دواتر لەبەشی تۆمار کردنی ئیش دەتوانی لە نەبونی ئینتەرنێتیشدا ناوی جوتیارەکە هەڵبژێریت و ئیشەکەی بەتەواوی تۆمار بکەی کە دەچیتە لیستی پرتەقاڵی."),
            _instructionStep("هەروەها لەبەشی مەسروف (لەنەبونی ئینتەرنێتیشدا) دەتوانی هەر مەسروفێکی ڕۆژانە بۆ ئیشەکەت  یان شکانی ئامێر تۆمار بکەی ،بۆ ئەوەی لە کۆتای ساڵدا هەمووی ببینیتەوە."),         
            _instructionStep("ئەوکاتانەی چویتەوە خەتی ئینتەرنێت تەنها یەکجار ئەو ئایکۆنەی سەرەوەی لای ڕاست 🔄️ دابگرە هەموو تۆمارکراوەکان پاشەکەوت دەبن بۆ کۆگا(سێرڤەر)ی گۆگڵ."),
            _instructionStep("لەبەشی کۆی گشتی دەتوانی بە وردی و بە ئاسانی کۆی تەواوی ئیشەکانت بە کات  و قەز و نەخت  بۆ هەر جوتیارێک یان هەموویان بە گشتی ببینیتەوە."),
            const SizedBox(height: 30),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 10),

            // بەشی پەیوەندی
            _buildHeaderCard(
              "پەیوەندی و پشتگیری", 
              Icons.contact_support, 
              const Color(0xFF144D45)
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "بۆ هەر پێویستیەک و کێشەیەک یان پێشنیارێک، دەتوانیت لە ڕێگەی هەموو ئەمانەوە پەیواندیمان پێوەبکەی :",
                style: TextStyle(fontSize: 17, color: Colors.black87, height: 1.5),
              ),
            ),
            
            // دوگمەی پەیوەندی (دەتوانیت ژمارەکە بگۆڕیت)
            Card(
             elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.phone, color: Color(0xFF144D45)),
                title: const Text("0750 178 3028", textDirection: TextDirection.ltr),
                subtitle: const Text("WhatsApp / Viber / FastPay", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold , color: Color.fromARGB(135, 5, 193, 48))),
                onTap: () {
                  //لێرە دەتوانیت فەنکشنی تەلەفۆن کردن دابنێیت
                },

              ),

            ),

            const SizedBox(height: 12),
                        Card(
             elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.phone, color: Color(0xFF144D45)),
                title: const Text("0772 152 5711", textDirection: TextDirection.ltr),
                subtitle: const Text("FIB / SuperQi", style: TextStyle(fontSize: 20, color: Color.fromARGB(137, 48, 247, 61))),
                onTap: () {
                  //لێرە دەتوانیت فەنکشنی تەلەفۆن کردن دابنێیت
                },

              ),

            ),

           const SizedBox(height: 5),

            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10), // لێرە مەوداکەی بۆ دیاری بکە
            child: Container(
             height: 60,
              width: double.infinity, // بۆ ئەوەی پانییەکەی بگرێت
           decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                 BoxShadow(
                 color: kAccentNeon.withValues(alpha: 0.3), 
               blurRadius: 15, 
                 offset: const Offset(0, 8)
           ),
             ],
                  ),
              
            child:  Padding(
           padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5), // لێرە مەوداکەی بۆ دیاری بکە
              child: ElevatedButton.icon(

                 onPressed: () => applink.launchYoutubeVideo(),
               style: ElevatedButton.styleFrom(
                backgroundColor: kAccentNeon,
                foregroundColor: kPrimaryGreen,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
                ),
               icon: const Icon(Icons.play_circle_fill, size: 20),
                 label: const Text(
                   "چۆنیەتی بەکارهێنان(Youtube)", 
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
               ),
              ),
            ),
            ),
            ), 
                     const SizedBox(height: 20),

            // نوسینێک بۆ ڕێنمایی بەکارهێنەر
            const Center(
              child: Text(
                "کۆدی سکانکردن بۆ ناردنی پارە",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF144D45),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // لێرەوە QR Code-ەکان دەست پێ دەکەن
            _buildQRCard("assets/images/fib_qr.png", "FIB QR Code"),
            const SizedBox(height: 15),
            
            _buildQRCard("assets/images/fastpay_qr.png", "FastPay QR Code"),
            const SizedBox(height: 15),
            
            _buildQRCard("assets/images/qi_qr.png", "Qi Card QR Code"),
            
            const SizedBox(height: 40), // بۆشایی کۆتایی لاپەڕە

           Divider(thickness: 1, color: Colors.grey.shade400),
         ],
        ),
      ),
    
    );
  }
  
  Widget _buildQRCard(String imagePath, String title) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: 280, // قەبارەکەی لێرە گەورە کراوە
                height: 280,
                fit: BoxFit.contain,
                // ئەگەر وێنەکە نەبوو، ئەم نوسینە نیشان دەدات
                errorBuilder: (context, error, stackTrace) => const Text("وێنەکە نەدۆزرایەوە"),
              ),
            ),
          ],
        ),
      ),
    );
    }

  // میتۆد بۆ دروستکردنی سەردێڕی بەشەکان
  Widget _buildHeaderCard(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  // میتۆد بۆ دروستکردنی خاڵەکانی ڕێنمایی
  Widget _instructionStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 8, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}