import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:farmer_app/models/farmer_product_model.dart';
import 'package:farmer_app/models/expense_model.dart';
import 'package:farmer_app/models/shop_type_model.dart'; // دڵنیابە ئەمەت زیاد کردووە
import 'package:farmer_app/main.dart';
import 'views_product_data_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui'; // بۆ ImageFilter و شوشەییەکە پێویستە
import 'package:flutter/services.dart'; // بۆ SystemNavigator پێویستە
import 'package:intl/intl.dart' as intl ;

// لە ناو کڵاسەکە ئەم گۆڕاوە پێناسە بکە بۆ دوو جار گەڕانەوەکە

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


class AddFarmerDataPage extends StatefulWidget {
  final int farmerId;
  final String farmerName;
  final String farmerCode;
  
  const AddFarmerDataPage({
    super.key,
    required this.farmerId,
    required this.farmerName,
    required this.farmerCode,
  });

  @override
  State<AddFarmerDataPage> createState() => _AddFarmerDataPageState();
}

class _AddFarmerDataPageState extends State<AddFarmerDataPage> {
 // final hive_service hive_service = hive_service();
  final SupabaseClient supabase = Supabase.instance.client;
  bool isProductView = true;

  final _pNameController = TextEditingController();
  final _pPriceController = TextEditingController();
  final _pCountController = TextEditingController();
  final _pShopController = TextEditingController();
  final TextEditingController _partnerNameController = TextEditingController();
  final TextEditingController _partnerPhoneController = TextEditingController();
  String selectedMoneyType = 'iq'; 
  String selectedPayType = 'قەرز';
  String selectedExpensePayType = 'دراوە'; 

  final _eNameController = TextEditingController();
  final _eAmountController = TextEditingController();
  final TextEditingController shopController = TextEditingController();  DateTime? lastPressed;

  List<String> shopList = ["دوکانەکان"];
  
     @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => _fetchAndSyncShops());  }

  Future<void> _fetchAndSyncShops() async {
    try {
      final response = await supabase
          .from('tb_type_all')
          .select()
          .eq('t_id_farmer', widget.farmerId)
          .order('t_id_type', ascending: false);
      if (response != null && response is List) {
        // ١. یەکەم هەنگاوی گرنگ: پاککردنەوەی سندوقی لۆکاڵی دوکانەکان
        // بۆ ئەوەی ناوە سڕاوەکان لە مۆبایلەکەدا نەمێنن و دەبڵ نەبن
        await hiveService.shopBox.clear(); 

        List<String> tempNames = [];
        
        for (var item in response) {
          final shop = ShopTypeModel.fromMap(item);
          
          // ٢. پاشەکەوتکردن لە ناو Hive بە ئایدییە ڕاستەقینەکەی سوپابەیس
          await hiveService.shopBox.add(shop); 
          
          tempNames.add(shop.t_name_type!);
        }

        setState(() {
          // ئەگەر لیستەکە خاڵی بوو، ناوێکی بنەڕەتی دابنێ
          shopList = tempNames.isNotEmpty ? tempNames : ["دوکانەکان"];
        });
      }
    } catch (e) {
      print("هەڵە لە کاتی Sync: $e");
      // ٣. ئەگەر ئینتەرنێت نەبوو، تەنها داتای ناو مۆبایلەکە (Offline) بخوێنەوە
      final localShops = await hiveService.getShopsForFarmer(widget.farmerId);
      setState(() {
        if (localShops.isNotEmpty) {
          shopList = localShops.map((s) => s.t_name_type!).toList();
        } else {
          shopList = ["دوکانی سەرەکی"];
        }
      });
    }
  }
    // لە ناو hive_service دایبنێ ئەگەر نەتەبوو
   

  Widget _buildShopRegistrationCard() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 2),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        // ١. خانەی نوسینی ناوی دوکان
        Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20), // لێرە پاناییەکەی کۆنتڕۆڵ بکە (زیادی بکە باریکتر دەبێت)
            child: TextField(
            autofocus: false,
           controller: shopController,
            textAlign: TextAlign.right,
             style: const TextStyle(fontSize: 15),
           decoration: InputDecoration(
            hintText: "ناوی دوکان (نوسینگە)",
           hintStyle: TextStyle(color: Colors.grey.shade800, fontSize: 15),
             prefixIcon: const Icon(Icons.add_business, color: Colors.green, size: 20),
              filled: true,
             fillColor: Colors.grey.shade200, // ڕەنگێکی زۆر کاڵ بۆ ناوەکەی
      
      // بۆردەری ئاسایی (زۆر کاڵ)
           enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
             ),
          
      // بۆردەر کاتێک کلیکی لێ دەکەیت
                focusedBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(15),
           borderSide: const BorderSide(color: Colors.green, width: 1),
            ),
      
      // لابردنی بۆردەرە بنەڕەتییەکە بۆ ئەوەی زەق نەبێت
                border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
             ),
             contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
           ),
           ),
                ),        
        const SizedBox(height: 5),
        
        // ٢. دوگمەکانی تۆمارکردن و بینینی لیست
        Row(
          children: [
            // دوگمەی لیستی جوتیار (ئەمە دایەلۆگی لیستەکە دەکاتەوە)
            Expanded(
              flex: 1,
               child:   Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

              child: ElevatedButton.icon(
                onPressed: _showShopListDialog, // ئەم فەنکشنە لە خوارەوەیە
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF607D8B), // ڕەنگی مۆری وەک وێنەکە
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                ),
                icon: const Icon(Icons.list, color: Colors.white, size: 20),
                label: const Text("لیستی دوکان", style: TextStyle(color: Colors.white)),
              ),
               ),
            ),
            const SizedBox(width: 0),
            
            // دوگمەی تۆمارکردن
            Expanded(
              flex: 1,
              child:   Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () async {
                  if (shopController.text.isNotEmpty) {
                    final newShop = ShopTypeModel(
                      t_id_farmer: widget.farmerId,
                      t_name_type: shopController.text,
                      is_synced: false,
                    );
                    await supabase.from('tb_type_all').insert(newShop.toMap());
                    await _fetchAndSyncShops();
                    shopController.clear();
                    _showSnackBar("دوکانەکە بە سەرکەوتوویی تۆمار کرا", Colors.green);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // ڕەنگی سەوز
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text("تۆمارکردن", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  }
  
  
  void _showShopListDialog() {
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("لیستی دوکانەکان", textAlign: TextAlign.center),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<List<Map<String, dynamic>>>(
              // بەکارهێنانی Stream بۆ ئەوەی هەر گۆڕانکارییەک کرا دەستبەجێ نیشانی بدات
              stream: supabase
                  .from('tb_type_all')
                  .stream(primaryKey: ['id'])
                  .eq('t_id_farmer', widget.farmerId)
                  .order('t_id_type', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 20),
                      Center(child: Text("هیچ دوکانێک نییە")),
                      SizedBox(height: 20),
                    ],
                  );
                }

                final data = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    String currentShopName = data[i]['t_name_type'];

                    return Card(
                      child: ListTile(
                        title: Text(currentShopName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                          onPressed: () {
                            // دایەلۆگی دڵنیایی پێش سڕینەوە
                            showDialog(
                              context: context,
                              builder: (BuildContext confirmContext) {
                                return Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: AlertDialog(
                                    title: const Text("دڵنیای؟"),
                                    content: Text("ئایا دڵنیای لە سڕینەوەی دوکانی: $currentShopName؟"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(confirmContext),
                                        child: const Text("نەخێر", style: TextStyle(color: Colors.grey)),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(confirmContext); // داخستنی دایەلۆگی پرسیار
                                          
                                          try {
                                            // ١. سڕینەوە لە سوپابەیس
                                            await supabase
                                                .from('tb_type_all')
                                                .delete()
                                                .eq('t_name_type', currentShopName)
                                                .eq('t_id_farmer', widget.farmerId);

                                               await hiveService.deleteLocalProduct(i);

                                            // ٢. نوێکردنەوەی شاشەی ناوەوە (ئەگەر پێویست بکات)
                                            setDialogState(() {});
                                             await _fetchAndSyncShops();
                                            // ٣. نوێکردنەوەی شاشەی سەرەکی ئەپەکە
                                            setState(() {});

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("بە سەرکەوتوویی سڕایەوە"), backgroundColor: Colors.green),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("هەڵە ڕوویدا: $e"), backgroundColor: Colors.red),
                                            );
                                          }
                                        },
                                        child: const Text("بەڵێ، بسڕەوە", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        leading: const Icon(Icons.store, color: Colors.green),
                      ),
                    );
                  },
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
  }   // --- Functions ---


  Future<void> _syncPendingData() async {
    try {
      if (isProductView) {
        // ١. لێرەدا await پێویست نییە چونکە ئۆبجێکت بۆکس لیستەکە ڕاستەوخۆ دەداتەوە
        final allProducts = await hiveService.getProductsForFarmer(widget.farmerId);
        // ٢. فلتەرکردنی ئەو دانانەی کە سینک نەکراون
        final pending = allProducts.where((p) => p.is_synced == false).toList();

        for (var p in pending) {
          // ناردن بۆ سێرڤەر
          await supabase.from('tb_product_farmer').insert(p.toMap());
          
          // گۆڕینی دۆخی سینک و پاشەکەوتکردنەوە لە ناوخۆ
          p.is_synced = true;
          hiveService.saveProduct(p); // ئۆبجێکت بۆکس لێرەدا پێویستی بە await نییە
        }
      } else {
        // بەشی خەرجییەکان (Expenses)
        final allExpenses = await hiveService.getExpensesForFarmer(widget.farmerId);
        
        final pending = allExpenses.where((ex) => ex.is_synced == false).toList();

        for (var e in pending) {
          await supabase.from('tb_expenses').insert(e.toMap());
          
          e.is_synced = true;
          hiveService.saveExpense(e);
        }
      }
      setState(() {});
    } catch (e) {
      debugPrint("Sync failed: $e");
    }
    }
  



  Future<void> _saveData() async {
    String amountWithoutComma = _eAmountController.text.replaceAll(',', '');
    String pricetWithoutComma = _pPriceController.text.replaceAll(',', '');
    String pCountControllercome =  _pCountController.text.replaceAll(',','');
    try {
      if (isProductView) {
        if (_pNameController.text.isEmpty || _pPriceController.text.isEmpty || _pShopController.text.isEmpty) {
          _showSnackBar("تکایە خانەکان پڕ بکەرەوە", const Color.fromARGB(255, 176, 133, 69)); return;
        }
        final newProduct = FarmerProductModel(
          id_farmer_user: widget.farmerId,
          code_farmer: widget.farmerCode,
          name_product: _pNameController.text,
          price_product: double.tryParse(pricetWithoutComma) ?? 0.0,
          number_product: double.tryParse(pCountControllercome) ?? 1.0,
          total_amount: (double.tryParse(_pCountController.text) ?? 1.0) * (double.tryParse(_pPriceController.text) ?? 0.0), 
          name_shop: _pShopController.text,
          p_pay_type: selectedPayType, 
          p_many_type: selectedMoneyType,
          add_date: DateTime.now(),
          is_synced: false,
        );
        await hiveService.saveProduct(newProduct);
        _pNameController.clear(); _pPriceController.clear();
        _pCountController.clear(); 
      } else {
        if (_eNameController.text.isEmpty || _eAmountController.text.isEmpty) {
          _showSnackBar("تکایە خانەکان پڕ بکەرەوە", Colors.orange); return;
        }
        final newExpense = ExpenseModel(
          id_farmer_user: widget.farmerId,
          name_farmer: widget.farmerName,
          code_farmer: widget.farmerCode,
          name_expense: _eNameController.text,
          amount_expense: amountWithoutComma,
          e_pay_type: selectedExpensePayType, 
          add_date: DateTime.now(),
          is_synced: false,
        );
        await hiveService.saveExpense(newExpense);
        _eNameController.clear(); _eAmountController.clear();
        
      }
      _showSnackBar("تۆمار کرا", Colors.green);
      _syncPendingData(); 
      setState(() {}); 
    } catch (e) {
      _showSnackBar("هەڵە: $e", Colors.red);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center), backgroundColor: color, duration: const Duration(seconds: 1)));
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
            content: Text("بۆ چوونە دەرەوە، جارێکی تر کلیک بکەرەوە", textAlign: TextAlign.right),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF144D45),
          ),
        );
      } else {
        SystemNavigator.pop(); // داخستنی ئەپەکە
      }
    },
    child: Scaffold(
      backgroundColor: const Color(0xFFDCE6DF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130.0,
            toolbarHeight: 60.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF144D45),
            automaticallyImplyLeading: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            
            // ١. بەشی لای چەپ (ڕێنمایی و هۆم)
            leadingWidth: 80,
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 5),
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
              padding: const EdgeInsets.only(top: 13),
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
             
              IconButton(
                icon: const Icon(Icons.sync_rounded, color: Colors.white, size: 30),
                onPressed: () async {
                  await _syncPendingData();
                  setState(() {});
                  _showSnackBar("داتاکان نوێ کرانەوە", Colors.blue);
                },
              ),
              const SizedBox(width: 10),
            ],

            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(top: 60, left: 20, right: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // دوگمەی شەریک بە باکگراوندی شووشەیی
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: InkWell(
                              onTap: () => _showAddPartnerDialog(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.person_add_alt_1, color: Colors.white, size: 18),
                                    SizedBox(width: 5),
                                    Text(
                                      "زیادکردنی شەریک",
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.farmerName,
                              style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${widget.farmerCode}   : کۆد  ",
                              style: const TextStyle(color: Colors.white70, fontSize: 5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ٥. بەشی بەرهەمەکان و میتۆدەکان
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildTopMenu(),
                _buildShopRegistrationCard(),
                const SizedBox(height: 10),
                _buildAnimatedForm(),
                const SizedBox(height: 20),
                _buildLocalBackupList(),
                const Divider(height: 40, thickness: 2),
                _buildSupabaseListHeader(),
                _buildSupabaseDataList(),
                const SizedBox(height: 50), // بۆ ئەوەی کۆتا لیست نەچێتە ژێر شاشەکە
              ],
            ),
          ),
        ],
      ),
    ),
  );
  }

    

  void _showAddPartnerDialog() {

    showDialog(

      context: context,

      builder: (context) => StatefulBuilder(

        builder: (context, setDialogState) => Directionality(

          textDirection: TextDirection.rtl,

          child: AlertDialog(

            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

            title: const Column(

              children: [

                Text("زیادکردنی شەریک", style: TextStyle(fontWeight: FontWeight.bold)),

                Text("تەنها دەتوانی یەک شەریک زیاد بکەیت",

                  style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.normal)),

              ],

            ),

            content: SingleChildScrollView(

              child: Column(

                mainAxisSize: MainAxisSize.min,

                children: [

                  _textField(_partnerNameController, "ناوی شەریک", Icons.person_add),

                  const SizedBox(height: 10),

                  _textField(_partnerPhoneController, "ژمارەی مۆبایل", Icons.phone, isNumber: true),

                  const Divider(height: 30),

                  const Text(" ناوی زیاد کراو", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey)),

                  const SizedBox(height: 10),

                  StreamBuilder(

                    stream: supabase.from('tb_add_user').stream(primaryKey: ['id_add_user']).eq('account_id_farmer', widget.farmerId),

                    builder: (context, snapshot) {

                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                      var partners = snapshot.data!;

                      return Column(

                        children: partners.map((p) => Card(

                          color: Colors.blue.withValues(alpha: .05),

                          child: ListTile(

                            title: Text(p['name_user'], style: const TextStyle(fontWeight: FontWeight.bold)),

                            trailing: IconButton(

                              icon: const Icon(Icons.delete_forever, color: Colors.red),

                              onPressed: () async {

                                await supabase.from('tb_add_user').delete().eq('id_add_user', p['id_add_user']);

                                setDialogState(() {});

                                setState(() {});

                              },

                            ),

                          ),

                        )).toList(),

                      );

                    },

                  )

                ],

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

                child: const Text("پاشەکەوت"),

              )

            ],

          ),

        ),

      ),

    );

  }

  Widget _buildTopMenu() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // ١. لای ڕاست: مەسروفی ڕۆژانە (ئەمە لۆجیکی گۆڕینی فۆرمەکەیە)
        _topBtn(
          "مەسروفی\nڕۆژانە", 
          Icons.money_off_rounded, 
          !isProductView ? Colors.orange.shade700 : Colors.grey.shade600, 
          () => setState(() => isProductView = false)
        ),

        // ٢. ناوەڕاست: کڕینی مەواد (ئەمە لۆجیکی گۆڕینی فۆرمەکەیە)
        _topBtn(
          "کڕینی\nمەواد", 
          Icons.shopping_cart_rounded, 
          isProductView ? Colors.green.shade700 : Colors.grey.shade600, 
          () => setState(() => isProductView = true)
        ),

        // ٣. لای چەپ: کۆی گشتی (ئەمە دەچێت بۆ لاپەڕەی ڕاپۆرت)
        _topBtn(
          "کۆی گشتی\nکڕین", 
          Icons.analytics_rounded, 
          Colors.blue.shade700, 
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FarmerSummaryPage(
                  farmerId: widget.farmerId,
                  farmerName: widget.farmerName,
                  farmerCode: widget.farmerCode,
                ),
              ),
            );
          }
        ),
      ],
    ),
  );
  }

// فەنکشنی دروستکردنی ئایکۆنە بازنەییەکان (دیزاینی درایڤەر)
  Widget _topBtn(String title, IconData icon, Color color, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(15),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .15), // ڕەنگی کاڵی پشت ئایکۆنەکە
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color == Colors.grey.shade600 ? Colors.black87 : color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
  }

  Widget _buildAnimatedForm() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: const Color.fromARGB(205, 220, 233, 233), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 15)]),
      child: Column(
        children: [
          Text(isProductView ? "بەشی تۆمارکردنی مەوادەکان(کڕین)" : "بەشی مەسروفی ڕۆژانە", style: TextStyle(fontWeight: FontWeight.bold, color: isProductView ? Colors.black87 : Colors.grey.shade900, fontSize: 20)),
          const Divider(height: 25),
          if (isProductView) ...[
            _buildShopDropdown(),
             const SizedBox(height: 10),
            _myTextField(_pNameController, "ناوی مەواد", Icons.shopping_bag_outlined), const SizedBox(height: 10),
            Row(children: [Expanded(child: _myTextField(_pCountController, "دانە", Icons.numbers, isNum: true)),
             const SizedBox(width: 10),
              Expanded(child: _myTextField(_pPriceController, "نرخ", Icons.sell_outlined, isNum: true))]),
            const SizedBox(height: 10),
            _buildTypeSelectors(),
          ] else ...[
            _myTextField(_eNameController, "جۆری مەسروف(ناو) ", Icons.edit_note), const SizedBox(height: 12),
            _myTextField(_eAmountController, "بڕی پارە", Icons.money, isNum: true), const SizedBox(height: 20),
            _segmentedRow(['قەرز', 'دراوە'], selectedExpensePayType, (v) => setState(() => selectedExpensePayType = v)),
          ],
          const SizedBox(height: 15),
          ElevatedButton(onPressed: _saveData, 
          style: ElevatedButton.styleFrom(backgroundColor: isProductView ? Colors.green.shade600 : Colors.orange.shade500,
           minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
             child: Text(isProductView ? "تۆمارکردن" : "تۆمارکرن ", 
             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
        ],
      ),
    );
  }

    Widget _buildShopDropdown() {
  return Directionality(
    textDirection: TextDirection.rtl, // هەموو شتێک دەبات بۆ لای ڕاست
    child: DropdownButtonFormField<String>(
       isExpanded: true,
      // گۆڕینی initialValue بۆ value
      initialValue: shopList.contains(_pShopController.text) && _pShopController.text.isNotEmpty 
          ? _pShopController.text 
          : null,
      
      style: TextStyle(
        color: Colors.grey.shade900, 
        fontSize: 18, 
        height: 1.2,
        fontWeight: FontWeight.w500,
        fontFamily: 'KurdishFont' // ئەگەر فۆنتی تایبەتت هەیە لێرە دایبنێ
      ),
       decoration: _inputStyle("ناوی دوکانەکان", Icons.store_outlined).copyWith(
       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // ٣. لای ڕاست بکە بە 0
       ),
      // ڕێکخستنی شێوەی نیشاندانی لیستەک
      items: shopList.map((s) => DropdownMenuItem(
        value: s,
        child: Align(
          alignment: Alignment.centerRight, // نووسینی ناو لیستەکە دەبات بۆ لای ڕاست
          child: Text(s),
        ),
      )).toList(),   

      onChanged: (val) {
        setState(() {
          _pShopController.text = val!;
        });
      },
     // isExpanded: true, 
    ),
  );
  }



  Widget _buildTypeSelectors() {
    return Column(children: [
      _segmentedRow(['iq', '\$'], selectedMoneyType, (v) => setState(() => selectedMoneyType = v)),
      const SizedBox(height: 12),
      _segmentedRow(['قەرز', 'دراوە'], selectedPayType, (v) => setState(() => selectedPayType = v)),
    ]);
  }

  Widget _segmentedRow(List<String> opts, String selected, Function(String) onSelect) {
    return Row(children: opts.map((o) {
      bool isS = selected == o;
      String label = o == 'iq' ? 'دینار' : o == '\$' ? 'دۆلار' : o == 'دراوە' ? 'نەخت' : o;
      return Expanded(child: GestureDetector(onTap: () => onSelect(o),
          child: Container(margin: const EdgeInsets.symmetric(horizontal:1),
          padding: const EdgeInsets.symmetric(vertical: 6), 
          decoration: BoxDecoration(color: isS ? Colors.green.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20), border: Border.all(color: isS ? Colors.black : Colors.transparent, width: 1)),
          child: Center(child: Text(label, style: TextStyle(color: isS ? Colors.green.shade900 : Colors.grey.shade600, 
          fontWeight: FontWeight.bold))))));
    }).toList());
  }
  
Widget _buildSupabaseDataList() {
  final table = isProductView ? 'tb_product_farmer' : 'tb_expenses';
  final String primaryKeyName = isProductView ? 'id_product' : 'id_expense';

  return StreamBuilder(
    // لێرە مەرجەکە دادەنێین: ئەگەر لە بەشی مەواد بوویت و دوکان هەڵبژێردرابوو، فلتەری بکە
    stream: (isProductView && _pShopController.text.isNotEmpty)
        ? supabase
            .from(table)
            .stream(primaryKey: [primaryKeyName])
            .eq('id_farmer_user', widget.farmerId) // فلتەری یەکەم           
            //.filter('p_shop_name', 'eq', _pShopController.text) 
            .order(primaryKeyName, ascending: false)
          : supabase
            .from(table)
            .stream(primaryKey: [primaryKeyName])
            .eq('id_farmer_user', widget.farmerId)   
            .order(primaryKeyName, ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
              }

  // ١. هەموو داتاکان وەردەگرین
               var allData = snapshot.data as List<Map<String, dynamic>>? ?? [];  // ٢. لێرە فلتەرەکە بە کۆدی فڵاتەر دەکەین (زۆر ئاسانە و سوور نابێت)
           List<Map<String, dynamic>> list = allData;
          if (isProductView && _pShopController.text.isNotEmpty) {
         list = allData.where((item) => item['name_shop'] == _pShopController.text).toList();
             }

              if (list.isEmpty) {
              return const Center(child: Padding(padding: EdgeInsets.all(30), child: Text("داتایەک بۆ ئەم دوکانە نییە")));
                }
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text("${list.length} دانە", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
                Text(isProductView ? "ژمارەی کاڵاکان" : "ژمارەی خەرجییەکان", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              
              // دەرهێنانی داتاکان
              final String name = isProductView ? (item['name_product'] ?? 'بێ ناو') : (item['name_expense'] ?? 'بێ ناو');
              final String shop = item['name_shop'] ?? 'دیاری نەکراوە';
              final double price = (item[isProductView ? 'price_product' : 'amount_expense'] ?? 0).toDouble();
              final double count = (item[isProductView ? 'number_product' : ''] ?? 1).toDouble();
              final double total = (item['total_amount'] ?? (price * count)).toDouble();
              final String payType = item[isProductView ? 'p_pay_type' : 'e_pay_type'] ?? 'نەخت';
              final String currency = (item[isProductView ? 'p_many_type' : 'e_many_type'] == '\$' ? 'دۆلار' : 'دینار');

              // ڕەنگی قەرز و نەخت
              bool isPaid = payType == 'دراوە' || payType == 'نەخت';
              Color statusColor = isPaid ? Colors.green : Colors.redAccent;

              // کات و بەروار
              DateTime? date = item['add_date'] != null ? DateTime.parse(item['add_date']) : null;
              String formattedDate = date != null ? "${date.year}/${date.month}/${date.day}" : "-";

              // ... لە ناو itemBuilder ...

           return Directionality(
        textDirection: TextDirection.rtl,
       child: Container(
             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
             decoration: BoxDecoration(
            color: Colors.white,
             borderRadius: BorderRadius.circular(15),
               boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row( // لێرە IntrinsicHeight مان لادا بۆ ئەوەی ئازاد بێت لە بەرزبوونەوە
      crossAxisAlignment: CrossAxisAlignment.start, // بۆ ئەوەی لە سەرەوە دەست پێ بکات
      children: [
        Container(width: 6, color: statusColor, constraints: const BoxConstraints(minHeight: 100)), // هێڵە ڕەنگاوڕەنگەکە
        
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isProductView) ...[
                  
                  Text(shop, style: const TextStyle(color: Color.fromARGB(255, 62, 142, 183), fontSize: 16)),
                   ],
                   const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // هەنگاوی یەکەم: ناوی کاڵاکە یان تێبینی بخەرە ناو Expanded
                    Expanded( 
                      child: Text(
                        name, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        softWrap: true, // ڕێگە دەدات بچێتە دێڕی دووەم
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: statusColor.withValues(alpha: .1), borderRadius: BorderRadius.circular(6)),
                      child: Text(payType, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const Divider(height: 20),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // بەشی چەپ: نرخ و دانە
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "نرخ: ${intl.NumberFormat("#,###").format(price)} $currency",
                            style: const TextStyle(fontSize: 13),
                          ),
                          if (isProductView)
                            Text(
                              "دانە: ${intl.NumberFormat("#,###").format(count)}",
                              style: const TextStyle(fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                    // بەشی ڕاست: کۆی گشتی
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("کۆی گشتی", style: TextStyle(fontSize: 12, color: Colors.black54)),
                        Text(
                          "${intl.NumberFormat("#,###").format(total)} $currency",
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // ٣. بەروار و دوگمەی سڕینەوە
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    GestureDetector(
                      onTap: () => _confirmDelete(context, item, primaryKeyName, table),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: .05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
  );
      },

          ),

        ],

      );

    },

  );

  }
                                      // هەنگاوی دووەم: بۆ پاراستنی شاشەکە لە Overflow، بەشەکان بە Column دادەنێین


// فەنکشنی دڵنیابوونەوە لە سڕینەوە
  void _confirmDelete(BuildContext context, Map item, String pk, String table) {
   showDialog(
    context : context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text("دڵنیای؟"),
        content: const Text("ئەم زانیارییە بە یەکجاری لە سێرڤەر دەسڕێتەوە."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("پەشیمانبوونەوە")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await supabase.from(table).delete().eq(pk, item[pk]);
                setState(() {}); // بۆ نوێکردنەوەی لیستەکە پاش سڕینەوە
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("بە سەرکەوتوویی سڕایەوە"), backgroundColor: Colors.green));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("هەڵەیەک ڕوویدا: $e"), backgroundColor: Colors.red));
              }
            },
            child: const Text("بیسڕەوە", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
  }
  

  Widget _buildLocalBackupList() {
  return FutureBuilder(
    future: isProductView
        ? hiveService.getProductsForFarmer(widget.farmerId)
        : hiveService.getExpensesForFarmer(widget.farmerId),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const SizedBox.shrink();

      final dynamic rawData = snapshot.data;
      final list = (rawData is List)
          ? rawData.where((item) => item.is_synced == false).toList()
          : [];

      if (list.isEmpty) return const SizedBox.shrink();

      return Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ئاگادارکردنەوەی سەرەوە (پرتەقاڵی)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.sync_problem_rounded, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "داتای نەنێردراو",
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          "ئەم ${list.length} دانەیە تەنها لە مۆبایلەکەدان و نەنێردراون بۆ سێرڤەر",
                          style: TextStyle(color: Colors.orange.shade700, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            ...list.map((item) {
              // ١. دەرهێنانی زانیارییەکان بە وریایی (ObjectBox)
              String name = isProductView ? (item.name_product ?? 'بێ ناو') : (item.name_expense ?? 'بێ ناو');
              String payType = isProductView ? (item.p_pay_type ?? 'نەخت') : (item.e_pay_type ?? 'نەخت');
              bool isPaid = payType == 'دراوە' || payType == 'نەخت';
              
              double price = isProductView ? (double.tryParse(item.price_product?.toString() ?? "0") ?? 0.0) : (double.tryParse(item.amount_expense?.toString() ?? "0") ?? 0.0);
              double count = isProductView ? (double.tryParse(item.number_product?.toString() ?? "1") ?? 1.0) : 1.0;
              double total = price * count;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.orange.shade200, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // هێڵە پرتەقاڵییەکە
                    Container(
                      width: 6, 
                      color: Colors.orange,
                      constraints: const BoxConstraints(minHeight: 100),
                    ),
                    
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ناوی کاڵا و ئایکۆنی نۆ-کڵاود
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(name, 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                                    softWrap: true,
                                  ),
                                ),
                                const Icon(Icons.cloud_off_rounded, color: Colors.orange, size: 18),
                              ],
                            ),
                            
                            if (isProductView && item.name_shop != null)
                              Text("دوکان: ${item.name_shop}", style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                            
                            const Divider(color: Colors.orange, thickness: 0.2, height: 20),
                            
                            // بەشی نرخەکان (فێکسەبڵ)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (isProductView) ...[
                                        Text("نرخ: ${intl.NumberFormat("#,###").format(price)}", style: const TextStyle(fontSize: 13)),
                                        Text("دانە: ${intl.NumberFormat("#,###").format(count)}", style: const TextStyle(fontSize: 13)),
                                      ] else ...[
                                        const Text("بڕی خەرجی:", style: TextStyle(fontSize: 12)),
                                      ],
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(payType, style: TextStyle(color: isPaid ? Colors.blue : Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                                    Text(
                                      "${intl.NumberFormat("#,###").format(total)} دینار", 
                                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14)
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // بەشی دوگمەی سڕینەوە (وەک لیستی ۆنلاین)
                            Align(
                              alignment: Alignment.centerLeft, // چونکە RTLـە، دەبێتە لای چەپ (واتە لای ڕاستی بەکارهێنەر)
                              child: GestureDetector(
                                onTap: () => _deleteLocalItem(item), // فەنکشنێکی نوێ بۆ سڕینەوەی لۆکاڵ
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: .1), shape: BoxShape.circle),
                                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const Divider(height: 30),
          ],
        ),
      );
    },
  );
  }


  void _deleteLocalItem(dynamic item) {
  showDialog(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text("دڵنیای؟"),
        content: const Text("ئەم زانیارییە تەنها لە مۆبایلەکەت دەسڕێتەوە (چونکە هێشتا نەنێردراوە بۆ سێرڤەر)."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("پەشیمانبوونەوە")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              // لێرە بەگوێرەی جۆری مۆدێلەکە دەیسڕینەوە
              if (isProductView) {
                hiveService.productBox.delete(item.id); 
              } else {
                hiveService.expenseBox.delete(item.id);
              }
              setState(() {}); // لیستەکە نوێ دەکاتەوە
            },
            child: const Text("بیسڕەوە", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
  }

  Widget _textField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
  return TextField(
    controller: controller,
    textAlign: TextAlign.right,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    inputFormatters: isNumber ? [ThousandsSeparatorInputFormatter()] : [],
    decoration: InputDecoration(
      hintText: hint,
      suffixIcon: Icon(icon, color: Colors.green, size: 18),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    ),
  );
  }


  Widget _buildSupabaseListHeader() {
    return Row(children: [Icon(Icons.storage_rounded, color: Colors.green.shade700, size: 20),
     const SizedBox(width: 8), Text(isProductView ? "لیستی گشتی کڕین" : "لیستی خەرجییەکان",
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]);
  }

    InputDecoration _inputStyle(String hint, IconData icon) {
  return InputDecoration(
    // بەکارهێنانی prefixIcon وەک خۆی یان suffixIcon بە کەیفی خۆت
    suffixIcon: Icon(icon, color: Colors.green.shade600, size: 20),
    hintText: hint,
    // لێرە textDirection-ەکەمان لاداوە چونکە نای ناسێتەوە
    filled: true,
    fillColor: Colors.grey.shade50,
    contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
    alignLabelWithHint: true, // ئەمە یارمەتی ڕێکخستنی نووسینەکە دەدات
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade200)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.green.shade400)),
  );
  }
  

  Widget _myTextField(TextEditingController ctrl, String hint, IconData icon, {bool isNum = false}) {
  return TextField(
    controller: ctrl,
    // دیاریکردنی ئاڕاستەی نووسین بە ڕاست بۆ چەپ
    textDirection: TextDirection.rtl,
    // ڕێکخستنی نووسینەکە بۆ لای ڕاست
    textAlign: TextAlign.right,
    keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true,signed: false) : TextInputType.text,
    inputFormatters: isNum ? [
    EnglishNumberFormatter(), // ١. سەرەتا ژمارەکان دەگۆڕێت بۆ ئینگلیزی
    ThousandsSeparatorInputFormatter(), // ٢. پاشان فۆرماتی سێ سێ جیادەکاتەوە
           ] : [],
    decoration: _inputStyle(hint, icon),
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
  );
  }

}