import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:farmer_app/models/driver_model.dart';
import 'package:farmer_app/models/driver_work_model.dart';
import 'dart:io';
import 'views_driver_report.dart';
import 'views_driver_expense.dart';
import 'package:farmer_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // بۆ SystemNavigator پێویستە
import 'package:dropdown_search/dropdown_search.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final intl.NumberFormat _formatter = intl.NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    // لادانی فاریزە کۆنەکان بۆ ئەوەی دووبارە حساب بکرێتەوە
    String newText = newValue.text.replaceAll(',', '');
    
    // تەنها ئەگەر ژمارە بوو فۆرماتی بکە
    double? value = double.tryParse(newText);
    if (value == null) return oldValue;

    String formatted = _formatter.format(value);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
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

class AddDriverAndWorkPage extends StatefulWidget {
  final int farmerId;
  final String farmerCode;
  final String farmerName; // ئەمە زیاد بکە
  const AddDriverAndWorkPage({super.key, required this.farmerId, required this.farmerName,required this.farmerCode});

  @override
  State<AddDriverAndWorkPage> createState() => _AddDriverAndWorkPageState();

}

class _AddDriverAndWorkPageState extends State<AddDriverAndWorkPage> {
  //final hiveService hiveService = hiveService();
  final SupabaseClient supabase = Supabase.instance.client;

  final TextEditingController _nameFelahController = TextEditingController();
  final TextEditingController _phoneFelahController = TextEditingController();
  final TextEditingController _workTypeController = TextEditingController();
  final TextEditingController _placeNameController = TextEditingController();
  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _partnerNameController = TextEditingController();
  final TextEditingController _partnerPhoneController = TextEditingController();
  
   // گۆڕدراو بۆ هەڵگرتنی جۆری هەڵبژێردراو
  final List<String> _workTypes = ["کێڵان (جووت کرن)","کڵۆکوت","لایلۆن ڕاخستن","نەوار ڕاخستن","هۆڵدەر ڕشتن","ماڵوکردن","باری عەرەبانە","هەباشەکردن","گیادورین","بڵاوکردنەوەی پەین","ئیشیتر"];
  String? _selectedWorkType;

  String? selectedFelahId;
  String? selectedFelahName;
  String payType = 'دراوە';
  
    // لە ناو کڵاسەکە ئەم گۆڕاوە پێناسە بکە بۆ دوو جار گەڕانەوەکە
  DateTime? lastPressed;


  //List<Map<String, dynamic>> felahList = [];
  List<Driver> felahList = [];

  //Stream<List<Map<String, dynamic>>> _getFelahsStream() {
    //return supabase.from('tb_driver')
      //  .stream(primaryKey: ['d_id_farmer'])
        //.eq('id_farmer_user', widget.farmerId);
  //}

  // مێتۆدی نیشاندانی نامە
  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center), 
        backgroundColor: color, 
        duration: const Duration(seconds: 1)
      )
    );
  }

    @override
  void initState() {
  super.initState();
  // کاتێک لاپەڕەکە دەکرێتەوە، یەکسەر داتاکان دەهێنین
  Future.delayed(Duration.zero, () => _fetchAndSyncFelahs());
  }

    Future<void> _fetchAndSyncFelahs() async {
    try {
      final response = await supabase
          .from('tb_driver')
          .select()
          .eq('id_farmer_user', widget.farmerId)
          .order('d_id_farmer', ascending: false);
      if (response != null && response is List) {
        // ١. گرنگترین هەنگاو: سەرەتا سندوقی Hive پاک بکەرەوە بۆ ئەم بەکارهێنەرە
        // یان هەموو سندوقەکە پاک بکەرەوە ئەگەر تەنها یەک بەکارهێنەر مۆبایلەکە بەکاردێنێت
        await hiveService.driverBox.clear(); 

        List<Driver> tempFelahs = [];
        
        for (var item in response) {
          final driver = Driver(
            d_id_farmer: item['d_id_farmer'],
            id_farmer_user: item['id_farmer_user'],
            d_name_farmer: item['d_name_farmer'],
            d_phone_farmer: item['d_phone_farmer'],
            code_farmer: item['code_farmer'],
            add_date: item['add_date'],
            is_synced: true,
          );

          // ٢. ئێستا داتاکانی سوپابەیس بخەرە ناو Hive بە پاکی
          await hiveService.driverBox.add(driver); 
          
          tempFelahs.add(driver);
        }

        setState(() {
          felahList = tempFelahs; 
        });
      }
    } catch (e) {
      print("هەڵە لە کاتی Sync: $e");
      // ٣. ئەگەر ئینتەرنێت نەبوو (Offline)، تەنها ئەوەی ناو Hive پیشان بدە
      final localDrivers = await hiveService.getDriversForUser(widget.farmerId);
      setState(() {
        felahList = localDrivers;
      });
    }
  }


  Future<void> _saveFelah() async {
  if (_nameFelahController.text.isNotEmpty) {

      final newDriver = Driver(
        id_farmer_user: widget.farmerId,
        d_name_farmer: _nameFelahController.text,
        d_phone_farmer: _phoneFelahController.text,
        code_farmer: widget.farmerCode,
        add_date: DateTime.now().toIso8601String(),
        is_synced: false
      );

       await supabase.from('tb_driver').insert(newDriver.toMap());
      await _fetchAndSyncFelahs();
      _nameFelahController.clear();
      _phoneFelahController.clear();
       _showSnackBar("جوتیار بە سەرکەوتوویی تۆمار کرا", Colors.green);
      setState(() {}); // نوێکردنەوەی شاشەکە
  } else {
    _showSnackBar("هەڵە:دڵنیابە لە هەبوونی ئینتەرنێت.", Colors.red);
  }
  }


  Future<void> _syncPendingWork() async {
    try {
      final pendingWorks = await hiveService.getUnsyncedWorks();
        if (pendingWorks.isEmpty) return;

          for (var work in pendingWorks) {
            try {
        // لێرە toMap بەکاردێنین کە خۆی داتاکان دەگۆڕێت بۆ ژمارە پێش ناردن
              await supabase.from('tb_driver_work').insert(work.toMap());
              await hiveService.deleteLocalDriverWork(work.id); 
            } catch (itemError) {
          debugPrint("Error syncing item: $itemError");
        continue;
      }
    }
    if (mounted) setState(() {});
  } catch (e) {
    debugPrint("Sync failed: $e");
  }
  }


  Future<void> _saveWork() async {
    String pricetWithoutComma = _priceController.text.replaceAll(',', '');
    if (selectedFelahId == null || _priceController.text.isEmpty) {
    _showSnackBar("تکایە ناو و نرخ پڕ بکەرەوە", Colors.orange);
    return;
    }

    try {
    // لێرە گۆڕانکاری سەرەکیمان کرد: داتاکان دەخەینە ناو کەوانەی مۆدێلەکە
// لە ناو فەنکشنی _saveWork ئەم بەشە بگۆڕە
    // لە ناو فەنکشنی _saveWork ئەم بەشە بگۆڕە
    final newWork = DriverWork(
  w_id_driver: widget.farmerId, // لێرە ئایدی سایەقەکە وەک ناسنامە دەدەین بە ئیشەکە
  d_id_farmer: int.tryParse(selectedFelahId ?? '0'),
  d_name_farmer: selectedFelahName,
  type_work: _workTypeController.text,
  name_place_work: _placeNameController.text,
  time_work_hours: _hourController.text,
  time_work_minutes: _minuteController.text,
  count_work: _countController.text,
  price_work: pricetWithoutComma,
  pay_type_work: payType,
  is_synced: false,
    );
    // پاشەکەوتکردن لە ئیسار
    await hiveService.saveDriverWork(newWork);
    
    _showSnackBar("کارەکە تۆمار کرا", Colors.green);
    
    // بانگی سینک دەکەین بۆ سوپابەیس ئەگەر نێت هەبوو
    _syncPendingWork(); 
    
    // پاککردنەوەی مەیدانەکان
    _clearWorkFields();
    
    setState(() {});
    
  } catch (e) {
    _showSnackBar("هەڵە ڕوویدا: $e", const Color.fromARGB(255, 117, 56, 52));
    debugPrint("Save Error: $e");
  }
  }

  void _showFelahListDialog() {
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("لیستی جوتیارەکان", textAlign: TextAlign.center),
          content: SizedBox(
            width: double.maxFinite,
            child: felahList.isEmpty
                ? const Center(child: Text("هیچ جوتیارێک نییە"))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: felahList.length,
                    itemBuilder: (context, index) {
                      final f = felahList[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Color.fromARGB(255, 6, 68, 154)), // یان هەر ڕەنگێکی تر کە پێت جوانە
                          title: Text(f.d_name_farmer ?? "بێ ناو", 
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(f.d_phone_farmer ?? ""),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_forever, color: Colors.red),
                            onPressed: () async {
                              // ١. چاوەڕێ دەکەین تا سڕینەوەکە تەواو دەبێت
                              await _confirmDelete(f);
                              // ٢. دوای سڕینەوە، لیستەکە لە ناو ئەم دیالۆگە نوێ دەکەینەوە
                              setDialogState(() {});
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("داخستن"),
            )
          ],
        ),
      ),
    ),
  );
}

// لێرە StateSetter مان لاداوە چونکە لە ناوەوە پێویستمان نییە
Future<void> _confirmDelete(Driver f) async {
  return showDialog(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text("دڵنیای؟"),
        content: Text("ئایا دڵنیای لە سڕینەوەی جوتیار: ${f.d_name_farmer}؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("نەخێر", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              try {
                if (f.d_id_farmer != null) {
                  await supabase.from('tb_driver').delete().eq('d_id_farmer', f.d_id_farmer!);
                }
                // لێرە بەپێی ئایدی Hive ڕەشی دەکەینەوە
                await hiveService.driverBox.delete(f.id); 
                await _fetchAndSyncFelahs(); // نوێکردنەوەی داتاکان لە ناو میمۆری
                
                Navigator.pop(context); // داخستنی دیالۆگی "دڵنیای"
                _showSnackBar("بە سەرکەوتوویی سڕایەوە", Colors.green);
                
                setState(() {}); // نوێکردنەوەی شاشەی سەرەکی (درۆپداون)
              } catch (e) {
                Navigator.pop(context);
                _showSnackBar("هەڵە لە سڕینەوە", Colors.red);
              }
            },
            child: const Text("بەڵێ، بسڕەوە", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ),
  );
  }

  void _clearWorkFields() {
    _workTypeController.clear();
    _placeNameController.clear();
    _hourController.clear();
    _minuteController.clear();
    _countController.clear();
    _priceController.clear();
  }

  void _showPartnerDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Column(
            children: [
              Text("زیادکردنی سایەق", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("ئاگادار بە تەنها دەتوانی یەک سایەق زیاد کەیت", 
                style: TextStyle(fontSize: 15, color: Colors.red, fontWeight: FontWeight.normal)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView( 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _textField(_partnerNameController, "ناوی سایەق", Icons.person_add),
                  const SizedBox(height: 8),
                  _textField3(_partnerPhoneController, "ژمارەی مۆبایل", Icons.phone, isNumber: true),
                  const SizedBox(height: 15),
                  const Divider(),
                  const Text("سایەقی زیاد کراو", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 10),
                  StreamBuilder(
                    stream: supabase.from('tb_add_user').stream(primaryKey: ['id_add_user']).eq('account_id_farmer', widget.farmerId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      var partners = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: partners.length,
                        itemBuilder: (context, idx) {
                          final p = partners[idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              title: Text(p['name_user'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_forever, color: Colors.red, size: 28),
                                onPressed: () async {
                                  await supabase.from('tb_add_user').delete().eq('id_add_user', p['id_add_user']);
                                  setDialogState(() {});
                                  setState(() {});
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("داخستن")),
            ElevatedButton(
              onPressed: () async {
                if (_partnerNameController.text.isNotEmpty) {
                  await supabase.from('tb_add_user').insert({
                    'name_user': _partnerNameController.text,
                    'phone_user': _partnerPhoneController.text,
                    'account_id_farmer': widget.farmerId,
                    'link_code': widget.farmerCode,
                  });
                  _partnerNameController.clear();
                  _partnerPhoneController.clear();
                  setDialogState(() {});
                  setState(() {});
                }
              },
              child: const Text("زیادکردن"),
            )
          ],
        ),
      ),
    );
  }
  


  Future<void> _handleRefresh() async {
  // ١. سەرەتا سینکی ئەو کارانە بکە کە ماون
  await _syncPendingWork(); 
  
  // ٢. لێرەدا ئەو فەنکشنە بانگ بکە کە داتاکان لە سێرڤەر یان داتابەیس دەهێنێتەوە
  // بۆ نموونە ئەگەر ناوی _loadData بێت:
  await _buildWorkList(); 

  // ٣. نوێکردنەوەی شاشەکە
  setState(() {
    // ئەگەر پێویستی بە گۆڕینی بارودۆخێک هەبێت لێرە دەیکەیت
  });
    
  // نیشاندانی نامەیەک بۆ دڵنیایی بەکارهێنەر
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("هەموو زانیارییەکان نوێکرانەوە")),
  );
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // ڕێگری لە گەڕانەوەی یەکجارە
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final now = DateTime.now();
        if (lastPressed == null || now.difference(lastPressed!) > const Duration(seconds: 2)) {
          lastPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("بۆ داخستن دوو جار کلیک بکە", textAlign: TextAlign.right),
              duration: Duration(seconds: 2),
              backgroundColor: Color(0xFF144D45),
            ),
          );
        } else {
          SystemNavigator.pop(); // داخستنی ئەپەکە بە تەواوی
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFDCE6DF),
        
        // ١. بەرزکردنی AppBar بۆ جێگیرکردنی دوگمەکانی لای چەپ
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0), // بەرزییەکە کەمێک زیاد کرا بۆ دڵنیایی
          child: AppBar(
            backgroundColor: const Color(0xFF144D45),
            elevation: 0,
            automaticallyImplyLeading: false,
            
            leadingWidth: 100,
            toolbarHeight: 70.0,
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center, // بۆ ئەوەی بە ستوونی ناوەڕاست بێت
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // دوگمەی ڕێنمایی لەسەرەوە

                // دوگمەی هۆم لە خوارەوە
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 4),
                  child: InkWell(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                          (route) => false,
                        );
                      }
                    },
                    child: const Icon(Icons.home_rounded, color: Colors.white, size: 35),
                  ),
                ),
              ],
            ),

           centerTitle: true,
             title: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
               mainAxisSize: MainAxisSize.min, // بۆ ئەوەی بکەوێتە ناوەڕاست
              children: [
            // دانانی وێنەی لۆگۆکە
            Image.asset(
            'assets/images/app_icons.png', // ناونیشانی وێنەکەت لە ناو فۆڵدەری assets
            height: 45, // بەرزی وێنەکە (بچووک و گونجاو)
             width: 45,
           ),
           const SizedBox(width: 2), // مەودایەک لە نێوان وێنەکە و نووسینەکە
            const Text(
             "فەلاحی زیرەک",
             style: TextStyle(
               fontWeight: FontWeight.bold, 
              color: Color.fromARGB(255, 198, 193, 193), 
               fontSize: 25,
            ),
          ),
           ],
           ),
          ),
           
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: IconButton(
                  icon: const Icon(Icons.sync_rounded, color: Colors.white, size: 30),
                  onPressed: () {
                     _handleRefresh(); // میتۆدی ڕیفرێشی خۆت
                  },
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),

        // ٢. بەشی ناوەڕۆکی لاپەڕەکە (Body) بە هەمان میتۆدەکانی خۆت
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildUserInfoHeader(), 
              _buildTopMenu(),
              //const SizedBox(height: 0),
              _buildFelahSection(),
              const Divider(thickness: 1, indent: 30, endIndent: 30, color: Colors.black87),
              const SizedBox(height: 7),
              const Text(
                "تۆمار کردنی ئیشەکانی جوتیار", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 6, 6, 6))
              ),
              const SizedBox(height: 7),
              _buildWorkSection(),
              
              // لیستی باک ئەپی ناوخۆیی
              _buildWorkLocalBackupList(),
              
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 10),
                child: Text(
                  "لیستی ئیشەکان", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blueGrey)
                ),
              ),
              _buildWorkList(),
              const SizedBox(height: 100), // بۆ ئەوەی کۆتا لیستەکە دیار بێت
            ],
          ),
        ),
      ),
    );
  }
  


  Widget _buildUserInfoHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
      decoration: BoxDecoration(
       // color: Colors.green.shade700,
       color:const Color(0xFF144D45),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
      ),
      child: Column(
        children: [
           // const Text("خاوەن مەکینە", style: TextStyle(color: Colors.white70, fontSize: 14)),
          Text(widget.farmerName, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(15)),
            child: Text("کۆد: ${widget.farmerCode}", style: const TextStyle(fontSize: 2,  color: Colors.white, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _topBtn(" خەرجی\n(مەسرەف)", Icons.account_balance_wallet, Colors.orange, () {
              Navigator.push(
              context,
              MaterialPageRoute(
              builder: (context) => DriverExpensePage(
              driverId: widget.farmerId,
              driverName: widget.farmerName,
              driverCode: widget.farmerCode,
               ),
             ),
            );
           }),
         

         
          _topBtn("کۆی گشتی\nئیشەکان", Icons.assessment, Colors.blue, () {
            Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) => DriverReportPage(
            driverId: widget.farmerId,
            driverName: widget.farmerName,
                    ),
                 ),
              );
          }),


          _topBtn("زیادکردنی\nسایەق", Icons.person_add_alt_1, Colors.green, _showPartnerDialog),
        ],
      ),
    );
  }

  Widget _topBtn(String t, IconData i, Color c, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(children: [Icon(i, color: c, size: 32), const SizedBox(height: 3), Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))]),
    );
  }

  Widget _buildFelahSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20 ,vertical: 5),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              _textField(_nameFelahController, "ناوی جوتیار (نازناو)", Icons.person),
              const SizedBox(height: 5),
              _textField3(_phoneFelahController, "ژمارەی مۆبایل", Icons.phone, isNumber: true),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, padding: const EdgeInsets.symmetric(vertical: 8)),
                      onPressed: _showFelahListDialog,
                      icon: const Icon(Icons.list, color: Colors.white),
                      label: const Text("لیستی جوتیار", style: TextStyle(fontSize: 13,color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 8)),
                      onPressed: _saveFelah,
                      child: const Text("تۆمارکردن", style: TextStyle(color: Colors.white,fontSize: 13 ,fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildWorkSection() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25),
    child: Column(
      children: [
        // ئیتر StreamBuilder پێویست نییە، چونکە پشت بە felahList دەبەستین

        Container(
         padding: const EdgeInsets.symmetric(horizontal: 12),
         decoration: BoxDecoration(
        color: Colors.white,
         borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade600),
          ),
             child: DropdownSearch<dynamic>( // بەکارهێنانی داینامیک بۆ ئەوەی مۆدێلەکەت قبوڵ بکات
        // داتاکان لە لیستەکەی خۆتەوە دەخوێنێتەوە
             items: (filter, loadProps) => felahList,
    
         // دیاریکردنی ئەوەی کام نووسین نیشان بدات لە لیستەکەدا
           itemAsString: (dynamic driver) => driver.d_name_farmer ?? "بێ ناو",
         
         // لۆجیکی هەڵبژاردنی داتا (بۆ ئەوەی بزانێت کام ئایدی هەڵبژێردراوە)
             compareFn: (item, selectedItem) => item.d_id_farmer == selectedItem.d_id_farmer,

        // لۆجیکی سێرچەکە (لێرەدا پیتەکان فلتەر دەکات)
             filterFn: (driver, filter) => 
        driver.d_name_farmer!.toLowerCase().contains(filter.toLowerCase()),

           // لۆجیکی Value ی هەڵبژێردراو
         selectedItem: felahList.any((f) => f.d_id_farmer.toString() == selectedFelahId)
        ? felahList.firstWhere((f) => f.d_id_farmer.toString() == selectedFelahId)
        : null,

    // کاتێک ناوەکە دەگۆڕێت
      onChanged: (dynamic driver) {
      setState(() {
        selectedFelahId = driver?.d_id_farmer.toString();
        selectedFelahName = driver?.d_name_farmer;
      });
    },

    // ڕێکخستنی شێوەی درۆپداونەکە (دیزاین)
       decoratorProps: DropDownDecoratorProps(
      decoration: InputDecoration(   
        hintTextDirection: TextDirection.rtl,    
       hintText: "ناوی جوتیار هەڵبژێرە",
       hintStyle: TextStyle(fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(6),
      ),
    ),

    dropdownBuilder: (context, dynamic selectedItem) {       
    return Directionality(
    textDirection: TextDirection.rtl,
    child: Row(
      children: [
        // ١. نوسینەکە یەکەم دانە بێت بۆ ئەوەی لای ڕاست بگرێت
        Expanded(
          child: Text(
            selectedItem?.d_name_farmer ?? "",
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),

        const SizedBox(width: 10), // بۆشایی

        // ٢. ئایکۆنەکە لە دوای نوسینەکە بێت، دەکەوێتە لای چەپ (لە RTL)
        const Icon(Icons.person, color: Color.fromARGB(255, 6, 68, 154)),
      ],
    ),
  );
  },
       
    // ڕێکخستنی ئەو لیستەی دەکرێتەوە (سێرچەکە لێرەدایە)
    popupProps: PopupProps.menu(
      showSearchBox: true, // سێرچەکە لێرە چالاک دەبێت
      searchFieldProps: TextFieldProps(
        textDirection: TextDirection.rtl, // بۆ ئەوەی سێرچەکە بە کوردی بێت
        decoration: InputDecoration(
         suffixIcon: const Icon(Icons.person, color: Color.fromARGB(255, 6, 68, 154)),
          hintText: "گەڕان بە ناو...",
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
      itemBuilder: (context, dynamic driver, isSelected, isHovered) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: ListTile(
            selected: isSelected,
            title: Text(
              driver.d_name_farmer ?? "بێ ناو",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    ),
  ),
  ),

        

        const SizedBox(height: 10),
        // لێرە بەردەوام بە لە نووسینی ئەوی تری ناو Column...

            Row(
              children: [
              const SizedBox(width: 8),

    // ٢. لیستەکە (Dropdown)
            Expanded(
              child: DropdownButtonFormField<String>(
              initialValue: _selectedWorkType,
              isExpanded: true,

              hint: Align(
               alignment: Alignment.centerRight,
                child: Text(
                 "جۆری ئیش هەڵبژێرە",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                   
                ),
                 ),  
             
              decoration: _inputStyle("", Icons.agriculture),
              items: _workTypes.map((type) => DropdownMenuItem(
              value: type,
              child: Align(
              alignment: Alignment.centerRight,
              child: Text(type, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                
              ),
            )).toList(),
            onChanged: (val) {
            setState(() {
            _selectedWorkType = val;
            if (val != null) {
              _workTypeController.text = val;
            }
           });
          },
          ),
        ),
     ],
    ),

          const SizedBox(height: 10),
          _textField(_placeNameController, "شوێن یان ناوی زەوی", Icons.location_on),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _textField2(_countController, "دانە", Icons.numbers, isNumber: true)),
              const SizedBox(width: 8),
              Expanded(child: _textField2(_minuteController, "دەقە", Icons.timer, isNumber: true)),
              const SizedBox(width: 8),
              Expanded(child: _textField2(_hourController, "سەعات", Icons.access_time, isNumber: true)),
            ],
          ),
          const SizedBox(height: 10),
          _textField(_priceController, "نرخ", Icons.payments, isNumber: true),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _payBtn("قەرز", const Color.fromARGB(255, 157, 57, 52), payType == "قەرز")),
              const SizedBox(width: 10),
              Expanded(child: _payBtn("نەخت", const Color.fromARGB(255, 49, 114, 52), payType == "دراوە")),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            
            
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              onPressed: _saveWork,
              child: const Text("تۆمارکردن", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _payBtn(String t, Color c, bool active) {
  return InkWell(
    onTap: () {
      setState(() {
        // ئەگەر t یەکسان بوو بە "نەخت"، بنووسە "دراوە" لە ناو payType
        // ئەگەر نا، هەر چییەک بوو (وەک قەرز) وەک خۆی دایبنێ
        payType = (t == "نەخت") ? "دراوە" : t;
      });
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: active ? c : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c, width: 2),
      ),
      child: Center(
        child: Text(
          t,
          style: TextStyle(
            color: active ? Colors.white : c,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildWorkList() {
    return StreamBuilder(
      stream: supabase.from('tb_driver_work').stream(primaryKey: ['id_work']).eq('d_id_farmer', selectedFelahId != null ? int.parse(selectedFelahId!) : -1).order('id_work', ascending: false),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: Text("جوتیارێک هەڵبژێرە بۆ بینینی کارەکان"));
        var works = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: works.length,
          itemBuilder: (context, idx) {
            final w = works[idx];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                      onPressed: () async {    // پیشاندانی دیالۆگی دڵنیابوونەوە
                        bool confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                          title: const Text("سڕینەوە", textAlign: TextAlign.right),
                          content: const Text("ئایا دڵنیایت لە سڕینەوەی ئەم کارە؟", textAlign: TextAlign.right),
                          actions: [
                          TextButton(
                          onPressed: () => Navigator.pop(context, false), // نەخێر
                          child: const Text("نەخێر", style: TextStyle(color: Colors.grey)),
                          ),
                          TextButton(
                          onPressed: () => Navigator.pop(context, true), // بەڵێ
                          child: const Text("بەڵێ", style: TextStyle(color: Colors.red)),
                          ),
                          ],
                          ),
                       ) ?? false; // ئەگەر لە دەرەوەی دیالۆگەکە کلیکی کرد، بە نەخێر دایبنێ
                                 // ئەگەر وەڵامەکەی بەڵێ بوو، ئینجا بیسڕەوە
                        if (confirm) {
                        await supabase.from('tb_driver_work').delete().eq('id_work', w['id_work']);
                        setState(() {});
                        }
                      },
                    ),
                    const VerticalDivider(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(w['d_name_farmer'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue)),
                          Text(  "${w['type_work']} - ${w['name_place_work']}", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(w['pay_type_work'], style: TextStyle(color: w['pay_type_work'] == "قەرز" ? const Color.fromARGB(255, 234, 32, 17) : Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 10),
                              const Icon(Icons.history_toggle_off, size: 14, color: Colors.grey),
                              Text("س ${w['time_work_hours'] ?? 0} د  ${w['time_work_minutes'] ?? 0} -- دانە  ${(w['count_work'] ?? 0).toInt()}", style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      children: [
                        const Text("کۆی گشتی", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(intl.NumberFormat("#,###").format(w['total_work']), 
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                        const Text("دینار", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _textField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: isNumber ? TextInputType.numberWithOptions(decimal: true , signed: false) : TextInputType.text,
      inputFormatters: isNumber ? [ThousandsSeparatorInputFormatter() , EnglishNumberFormatter() ] : [],
      style: TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: Icon(icon, color: Colors.green, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }
    
    Widget _textField2(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: isNumber ? TextInputType.numberWithOptions(decimal: true , signed: false) : TextInputType.text,
      inputFormatters: isNumber ? [ThousandsSeparatorInputFormatter() , EnglishNumberFormatter() ] : [],
      style: TextStyle(fontSize: 12),
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: Icon(icon, color: Colors.green, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

    Widget _textField3(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: isNumber ? TextInputType.numberWithOptions(decimal: true , signed: false) : TextInputType.text,
      style: TextStyle(fontSize: 15),
      inputFormatters: isNumber ? [ EnglishNumberFormatter() ] : [],
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: Icon(icon, color: Colors.green, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }



  Widget _buildWorkLocalBackupList() {
  return FutureBuilder<List<DriverWork>>(
    future: hiveService.getUnsyncedWorks(),
    builder: (context, snapshot) {
      final list = snapshot.data ?? [];
      if (list.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.cloud_off, color: Colors.orange, size: 18),
                SizedBox(width: 8),
                Text(
                  "کارە پاشەکەوتکراوەکان (نەنێردراوە)",
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, idx) {
              final w = list[idx];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    children: [
                      // دوگمەی سڕینەوە
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 26),
                        onPressed: () async {
                          bool confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                           // textDirection: TextDirection.rtl, // بۆ ئەوەی دیزاینەکە کوردی بێت
                          // child: AlertDialog(
                           // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            title: const Row(
                            children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.red),
                            SizedBox(width: 10),
                            Text("ئاگاداری"),
                            ],
                            ),
                            content: const Text("ئەم کارە هێشتا ڕەوانە نەکراوە بۆ سێرڤەر، ئایا دڵنیایت لە سڕینەوەی بە یەکجاری؟"),
                            actions: [
                            TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("پاشگەزبوونەوە", style: TextStyle(color: Colors.grey)),
                              ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              foregroundColor: Colors.red,
                              elevation: 0,
                               ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("بەڵێ، بسڕەوە"),
                                 ),
                                 ],
                                
                                ),
                          ) ?? false;

                              // ئەگەر وەڵامەکە بەڵێ بوو
                          if (confirm) {
                            await hiveService.deleteLocalDriverWork(w.id);
                            setState(() {});
                                // نیشاندانی نامەیەکی خێرا بۆ سڕینەوە
                            ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("کارەکە بە سەرکەوتوویی سڕایەوە"), backgroundColor: Colors.red),
                             );
                          }
                        },
                      ),  

                      const SizedBox(height: 35, child: VerticalDivider(color: Colors.orange, thickness: 1)),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // ناوی جوتیار
                            Text(
                              w.d_name_farmer ?? "بێ ناو",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange.shade900),
                            ),
                            // جۆری کار و شوێن
                            Text(
                              "${w.type_work ?? ""} - ${w.name_place_work ?? ""}",
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // کات
                                const Icon(Icons.history_toggle_off, size: 14, color: Colors.grey),
                                Text(" ${w.time_work_hours ?? 0} س  ${w.time_work_minutes ?? 0} د ", 
                                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                
                                const SizedBox(width: 12),
                                
                                // جۆری پارەدان
                                Text(
                                  w.pay_type_work ?? "",
                                  style: TextStyle(
                                    color: (w.pay_type_work == "قەرز" || w.pay_type_work == "قەرز-") ? Colors.red : Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 10),
                      // ئایکۆنی لۆکاڵ بۆ ئاگادارکردنەوە
                      const Icon(Icons.storage_rounded, color: Colors.orange, size: 18),
                      const SizedBox(width: 5),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(color: Colors.orange, indent: 20, endIndent: 20),
        ],
      );
    },
  );
  }

  // ئەم فەنکشنە لێرە زیاد بکە بۆ ئەوەی ئیرەرەکە نەمێنێت
  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.green.shade600, size: 22),
      hintTextDirection:TextDirection.rtl,
      hintText: hint,
      hintStyle: TextStyle(fontSize: 20, fontFamily: 'KurdishFont'),
      labelStyle: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.green.shade500),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.green.shade400),
      ),
    );
  }
 // ئەمە کۆتا کەوانەی کڵاسەکەیە، دڵنیابە فەنکشنەکە لە ناوەوەیە



}