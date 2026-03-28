import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// گۆڕین بۆ ئۆبجێکت بۆکس
import 'package:farmer_app/main.dart'; 

class FarmerSummaryPage extends StatefulWidget {
  final int farmerId;
  final String farmerName;
  final String farmerCode;
  const FarmerSummaryPage({
    super.key,
    required this.farmerId,
    required this.farmerName,
    required this.farmerCode,
  });

  @override
  State<FarmerSummaryPage> createState() => _FarmerSummaryPageState();
}

class _FarmerSummaryPageState extends State<FarmerSummaryPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  DateTime? selectedDate;
  String? selectedShop;
  bool isProductView = true;

  @override
  Widget build(BuildContext context) {
    Color themeColor = isProductView ? const Color(0xFF144D45) : const Color(0xFF144D45);
    Color  tcolor = const Color(0xFFDCE6DF);
    return Scaffold(
      backgroundColor: const Color(0xFFDCE6DF),
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text(widget.farmerName, style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: 25)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildToggleButtons(tcolor),
          const Divider( thickness: 1  , height: 0),
          _buildDynamicStatsBox(),
          _buildFilterBar(themeColor),
          Expanded(child: _buildDataTable(themeColor)),
        ],
      ),
    );
  }

  Widget _buildToggleButtons(Color themeColor) {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 15),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // بۆ ئەوەی بە جوانی دابەش ببن
      children: [
        // ١. ئایکۆنی مەسروف
        _circleToggleBtn(
          "مەسروف", 
          Icons.payments_rounded, 
          !isProductView, 
          Colors.red.shade700, 
          () => setState(() {
            isProductView = false;
            selectedShop = null;
          })
        ),

        // ٢. ئایکۆنی مەواد
        _circleToggleBtn(
          "مەواد", 
          Icons.inventory_2_rounded, 
          isProductView, 
          Colors.green.shade700, 
          () => setState(() {
            isProductView = true;
            selectedShop = null;
          })
        ),
      ],
    ),
  );
  }

// فەنکشنی دروستکردنی ئایکۆنە بازنەییەکان
  Widget _circleToggleBtn(String title, IconData icon, bool active, Color color, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(50),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 40, // قەبارەی بازنەکەمان گەورە کرد
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? color.withValues(alpha: .1) : Colors.grey.shade300,
            border: Border.all(
              color: active ? color : Colors.grey.shade600, 
              width: active ? 2.5 : 1,
            ),
            boxShadow: active ? [
              BoxShadow(
                color: color.withValues(alpha: .2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ] : [],
          ),
          child: Icon(
            icon, 
            color: active ? color : Colors.orange.shade200, 
            size: 32, // ئایکۆنەکە گەورە و دیارە
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            color: active ? color : Colors.grey.shade700,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 17,
          ),
        ),
        // هێڵێکی بچووک لە ژێر نووسینەکە کاتێک چالاکە
        if (active)
          Container(
            margin: const EdgeInsets.all(1),
            width: 20,
            height: 2,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    ),
  );
  }

  Widget _buildDynamicStatsBox() {
  final String table = isProductView ? 'tb_product_farmer' : 'tb_expenses';
  return StreamBuilder<List<Map<String, dynamic>>>(
    stream: supabase.from(table).stream(primaryKey: [isProductView ? 'id_product' : 'id_expense']).eq('id_farmer_user', widget.farmerId),
    builder: (context, snapshot) {
      double dD = 0, dI = 0, qD = 0, qI = 0, eD = 0, eQ = 0;
      
      if (snapshot.hasData) {
        var data = snapshot.data!;
        if (selectedDate != null) {
          data = data.where((i) => DateFormat('yyyy-MM-dd').format(DateTime.parse(i['add_date'])) == DateFormat('yyyy-MM-dd').format(selectedDate!)).toList();
        }
        if (isProductView && selectedShop != null) {
          data = data.where((i) => i['name_shop'] == selectedShop).toList();
        }

        for (var i in data) {
          double amt = double.tryParse((i['total_amount'] ?? i['amount_expense'] ?? 0).toString()) ?? 0.0;
          if (isProductView) {
            if (i['p_many_type'] == '\$') {
              if (i['p_pay_type'] == 'دراوە') dD += amt; else qD += amt;
            } else {
              if (i['p_pay_type'] == 'دراوە') dI += amt; else qI += amt;
            }
          } else {
            if (i['e_pay_type'] == 'قەرز') eQ += amt; else eD += amt;
          }
        }
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBFB), // ڕەنگێکی زۆر کاڵ
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // بۆ ئەوەی جێگەی زیادە نەگرێت
          children: [
            if (isProductView) ...[
              // ڕیزبەندی دۆلار (باریک)
              Row(
                children: [
                  Expanded(child: _compactStatTile("نەخت\n\$", dD, Colors.green.shade700)),
                  const SizedBox(width: 8),
                  Expanded(child: _compactStatTile("قەرز\n\$", qD, Colors.red.shade700)),
                ],
              ),
              const SizedBox(height: 8),
              // ڕیزبەندی دینار (باریک)
              Row(
                children: [
                  Expanded(child: _compactStatTile("نەخت\nد.ع", dI, Colors.teal.shade700)),
                  const SizedBox(width: 8),
                  Expanded(child: _compactStatTile("قەرز\nد.ع", qI, Colors.red.shade700)),
                ],
              ),
            ] else ...[
              // ڕیزبەندی مەسروف
              Row(
                children: [
                  Expanded(child: _compactStatTile("نەخت\nد.ع", eD, Colors.teal.shade700)),
                  const SizedBox(width: 8),
                  Expanded(child: _compactStatTile("قەرز\nد.ع", eQ, Colors.red.shade700)),
                ],
              ),
            ],
          ],
        ),
      );
    },
  );
  }

// ویجێتی باریک و بازنەیی بۆ نرخەکان
  Widget _compactStatTile(String title, double value, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: .2)),
    ),
    child: Row(
      children: [
        // بازنەیەکی بچووک بۆ ئایکۆن یان ڕەنگ
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
          ),
        ),
        Text(NumberFormat("#,###").format(value),
         // value.toStringAsFixed(value % 1 == 0 ? 0 : 1),
          style: TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
  }  


  Widget _buildFilterBar(Color themeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () async {
                DateTime? p = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2022), lastDate: DateTime(2030));
                if (p != null) setState(() => selectedDate = p);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300)),
                child: Row(children: [
                  const Icon(Icons.event, size: 15, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(selectedDate == null ? "بەروار" : DateFormat('MM-dd').format(selectedDate!), style: const TextStyle(fontSize: 15)),
                  if (selectedDate != null) const Spacer(),
                  if (selectedDate != null) IconButton(onPressed: () => setState(() => selectedDate = null), icon: const Icon(Icons.close, size: 12), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (isProductView)
            Expanded(flex: 3, child: _buildShopDropdown()),
        ],
      ),
    );
  }

    void _showSnackBar(String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, textAlign: TextAlign.right),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
  }


  Widget _buildDataTable(Color themeColor) {
    final String table = isProductView ? 'tb_product_farmer' : 'tb_expenses';
    return StreamBuilder(
      stream: supabase.from(table).stream(primaryKey: [isProductView ? 'id_product' : 'id_expense']).eq('id_farmer_user', widget.farmerId).order('add_date'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var list = snapshot.data!;
        if (selectedDate != null) list = list.where((i) => DateFormat('yyyy-MM-dd').format(DateTime.parse(i['add_date'])) == DateFormat('yyyy-MM-dd').format(selectedDate!)).toList();
        if (isProductView && selectedShop != null) list = list.where((i) => i['name_shop'] == selectedShop).toList();

  return Column(
  children: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("وردەکاری لیست", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          TextButton.icon(

            onPressed: () async {
                 if (!isProductView) {
                 if (list.isNotEmpty) {
                await _deleteFilteredItems(list);
                setState(() {
                  
                }); (); // یان setState بۆ نوێکردنەوە
                } else {
                   _showSnackBar("هیچ خەرجییەک نییە بۆ سڕینەوە", Colors.orange);
                }
                return; // لێرە کۆدەکە تەواو دەبێت بۆ خەرجی
                 }
            // مەرجەکە: ئەگەر نە بەروار و نە ناوی دوکان دیاری نەکرابوو، ڕێگە مەدە بسڕێتەوە
                  if (selectedDate == null && selectedShop == null) {
           _showSnackBar("تکایە سەرەتا (بەروار) یان (ناوی دوکان) دیاری بکە بۆ سڕینەوەی بەکۆمەڵ", Colors.orange);
           return; // لێرە دەوەستێت
            }

       // ئەگەر لیستەکە خاڵی نەبوو
              if (list.isNotEmpty) {
             // ١. بانگکردنی فەنکشنی سڕینەوە و چاوەڕێکردن تا تەواو دەبێت
                await _deleteFilteredItems(list);

          // ٢. دوای سڕینەوە فلتەرەکان سفر بکەرەوە و شاشەکە نوێ بکەرەوە
               setState(() {
            selectedDate = null;
              selectedShop = null;
             });
    
             } else {
                _showSnackBar("هیچ داتایەک لەم فلتەرەدا نییە بۆ سڕینەوە", Colors.orange);
           }
                },

            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            label: const Text("سڕینەوەی لیستی ", style: TextStyle(color: Colors.red,fontSize: 13,fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ),
    Expanded(
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: SizedBox(
      width: 850, 
      child: Column(
        children: [
          Container(
            color: Colors.green.shade400,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Row(
              children: const [
                SizedBox(width: 150, child: Text("دوکان", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13, color: Colors.black87 ))),
                SizedBox(width: 150, child: Text("مەواد", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold , fontSize: 13,color: Colors.black87 ))),          
                SizedBox(width: 100, child: Text("جۆری پارە", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13 ))),
                SizedBox(width: 70, child: Text("نرخ ", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13))),
                SizedBox(width: 70, child: Text("دانە", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13))),
                SizedBox(width: 100, child: Text("کۆی نرخ", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13))),
                SizedBox(width: 100, child: Text("بەروار", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13))),
                SizedBox(width: 70, child: Text("سڕینەوە", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, idx) {
                final item = list[idx];
                bool isDebt = (item['p_pay_type'] == 'قەرز' || item['e_pay_type'] == 'قەرز');
                String dateStr = DateFormat('yyyy-MM-dd').format(DateTime.parse(item['add_date']));
                
                return Container(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade500))),
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                  child: Row(
                    children: [
                      SizedBox(width: 150, child: Text(isProductView ? "${item['name_shop']}" : "-", textAlign: TextAlign.center ,style: TextStyle(fontSize: 13,color: Colors.black87) )),
                      SizedBox(width: 150, child: Text(isProductView ? "${item['name_product']}" : "${item['name_expense'] ?? ""}", textAlign: TextAlign.center  ,style: TextStyle(fontSize: 15,color: Colors.black))),
                      SizedBox(width: 70, child: Text(isProductView ? "${item['p_many_type']}" : "-", textAlign: TextAlign.center)),
                      SizedBox(width: 100, child: Text(NumberFormat("#,###").format(item['price_product'] ?? item['amount_expense'] ?? 0), textAlign: TextAlign.center, style: TextStyle(color: isDebt ? Colors.red : Colors.green, fontWeight: FontWeight.bold))),
                      SizedBox(width: 70, child: Text(NumberFormat("#,###").format(item['number_product'] ?? 0), textAlign: TextAlign.center)),
                      SizedBox(width: 100, child: Text(NumberFormat("#,###").format(item['total_amount'] ?? 0), textAlign: TextAlign.center, style: TextStyle(color: const Color.fromARGB(255, 7, 196, 229)))),
                      SizedBox(width: 100, child: Text(dateStr, textAlign: TextAlign.center)),
                      SizedBox(
                        width: 70,
                        child: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {  
                          _deleteSingleItem(item);
                           }, ),),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  ),
  ),
  ],
  );
  },
    );
  }

  Widget _buildShopDropdown() {
    return StreamBuilder(
      stream: supabase.from('tb_product_farmer').stream(primaryKey: ['id_product']).eq('id_farmer_user', widget.farmerId),
      builder: (context, snapshot) {
        List<String> shops = snapshot.hasData ? (snapshot.data as List).map((e) => e['name_shop'].toString()).toSet().toList() : [];
        if (selectedShop != null && !shops.contains(selectedShop)) selectedShop = null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade700 ) ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text("ناوی دوکان دیاری بکە", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              value: selectedShop ,
              items: shops.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => selectedShop = v),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteFilteredItems(List<dynamic> items) async {
  if (items.isEmpty) return;

  bool? confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("ئاگاداری", textAlign: TextAlign.right),
      content: Text("دڵنیایت لە سڕینەوەی ${items.length} تۆمار؟", textAlign: TextAlign.right),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false), // لێرە بە تەنها false دەگەڕێتەوە
          child: const Text("نەخێر"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(ctx, true), // تەنها لێرە true دەگەڕێتەوە
          child: const Text("بەڵێ"),
        ),
      ],
    ),
  );

  // زۆر گرنگە: لێرە تەنها و تەنها ئەگەر confirm ڕێک یەکسان بێت بە true ئیش دەکات
  if (confirm == true) {
    try {
      for (var i in items) {
        final id = isProductView ? i['id_product'] : i['id_expense'];
        
        // سڕینەوە لە داتابەیس
        await supabase
            .from(isProductView ? 'tb_product_farmer' : 'tb_expenses')
            .delete()
            .eq(isProductView ? 'id_product' : 'id_expense', id);
        
        // سڕینەوە لە ئۆبجێکت بۆکس
        if (isProductView) {
          objectBoxService.deleteProduct(id); 
        } else {
          objectBoxService.deleteExpense(id);
        }
      }

      // ئەم نامەیە تەنها لە ناو کەوانەی confirm == true دایە
      _showSnackBar("تۆمارەکان بە سەرکەوتوویی سڕانەوە", Colors.green);
      setState(() {});

    } catch (e) {
      _showSnackBar("هەڵەیەک لە کاتی سڕینەوە ڕوویدا", Colors.red);
    }
  } 
  // ئەگەر لێرە بیت، واتە پەنجەت ناوە بە نەخێر یان دیالۆگەکەت داخستووە، بۆیە هیچ ڕوو نادات.
  }

  Future<void> _deleteSingleItem(dynamic item) async {
  // پیشاندانی نامەی دڵنیایی
  bool? confirm = await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("ئاگاداری", textAlign: TextAlign.right),
      content: const Text("دڵنیایت لە سڕینەوەی ئەم تۆمارە؟", textAlign: TextAlign.right),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("نەخێر")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text("بەڵێ"),
        ),
      ],
    ),
  );

  if (confirm == true) {
    // دۆزینەوەی ئایدی بەپێی ئەوەی لە چ پەیجێکیت
    final id = isProductView ? item['id_product'] : item['id_expense'];

    try {
      // ١. سڕینەوە لە سێرڤەر (Supabase)
      await supabase
          .from(isProductView ? 'tb_product_farmer' : 'tb_expenses')
          .delete()
          .eq(isProductView ? 'id_product' : 'id_expense', id);

      // ٢. سڕینەوە لە ناوخۆ (ObjectBox)
      if (isProductView) {
        objectBoxService.deleteProduct(id);
      } else {
        objectBoxService.deleteExpense(id);
      }

      // ٣. نوێکردنەوەی شاشەکە و لابردنی لە ناو لیستی فلاتەرەکە
      setState(() { });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("بە سەرکەوتوویی سڕایەوە")),
      );
    } catch (e) {
      print("Error deleting: $e");
    }
  }
  }


}