import 'package:flutter/material.dart' ;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:farmer_app/models/expense_model.dart';
import 'package:intl/intl.dart'as intl;
import 'package:farmer_app/main.dart';
import 'package:flutter/services.dart';

class DriverExpensePage extends StatefulWidget {
  final int driverId;
  final String driverName;
  final String driverCode;

  const DriverExpensePage({
    super.key,
    required this.driverId,
    required this.driverName,
    required this.driverCode,
  });

  @override
  State<DriverExpensePage> createState() => _DriverExpensePageState();
}

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

class _DriverExpensePageState extends State<DriverExpensePage> {
 // final objectBoxService objectBoxService = objectBoxService();
  final SupabaseClient supabase = Supabase.instance.client;

  final _eNameController = TextEditingController();
  final _eAmountController = TextEditingController();
  String selectedExpensePayType = 'دراوە'; 
  final formatter = intl.NumberFormat("#,###");

  Future<void> _syncPendingExpenses() async {
    try {
      final allLocal = await objectBoxService.getExpensesForFarmer(widget.driverId);
      final pending = allLocal.where((ex) => ex.is_synced == false).toList();
      if (pending.isEmpty) return;
      for (var e in pending) {
        try {
          await supabase.from('tb_expenses').insert(e.toMap());
          await objectBoxService.deleteLocalExpense(e.id); // یەکەم: سڕینەوە لە ئۆبجێکت بۆکس
        } catch (e) { continue; }
      }
      if (mounted) setState(() {});
    } catch (e) { debugPrint("Sync failed: $e"); }
  }

  Future<void> _saveExpense() async {  
    String amountWithoutComma = _eAmountController.text.replaceAll(',', '');

    if (_eNameController.text.isEmpty || _eAmountController.text.isEmpty) {
      _showSnackBar("تکایە خانەکان پڕ بکەرەوە", Colors.orange);
      return;
    }
    try {
      final newExpense = ExpenseModel(
        id_farmer_user: widget.driverId,
        name_farmer: widget.driverName,
        code_farmer: widget.driverCode,
        name_expense: _eNameController.text,
        amount_expense: amountWithoutComma,
        e_pay_type: selectedExpensePayType,
        add_date: DateTime.now(),
        is_synced: false,
      );
      await objectBoxService.saveExpense(newExpense);
      _eNameController.clear();
      _eAmountController.clear();
      _showSnackBar("تۆمار کرا", Colors.green);
      _syncPendingExpenses();
      setState(() {});
    } catch (e) { _showSnackBar("هەڵە: $e", Colors.red); }
  }

  Future<void> _deleteExpense(Map<String, dynamic> item) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("سڕینەوە", textAlign: TextAlign.right),
        content: const Text("ئایا دڵنیای لە سڕینەوەی ئەم خەرجییە؟", textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("نەخێر")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("بەڵێ", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await supabase.from('tb_expenses').delete().eq('id_expense', item['id_expense']);
        _showSnackBar("سڕایەوە", Colors.blueGrey);
      } catch (e) { _showSnackBar("هەڵە لە سڕینەوە", Colors.red); }
    }
  }

  
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCE6DF),
      appBar: AppBar(
        title: const Text("مەسروفات", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF144D45),
        centerTitle: true,
        elevation: 0,
        actions: [IconButton(onPressed: _syncPendingExpenses, icon: const Icon(Icons.sync, color: Colors.white))],
      ),
      body: StreamBuilder(
        stream: supabase.from('tb_expenses').stream(primaryKey: ['id_expense']).eq('id_farmer_user', widget.driverId).order('add_date', ascending: false),
        builder: (context, snapshot) {
          final supabaseList = snapshot.data ?? [];
          
          return Column(
            children: [
              _buildHeader(),
              
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          children: [
                            _buildForm(),
                            const SizedBox(height: 15),
                            _buildTotalSummary(supabaseList),
                            const SizedBox(height: 15),
                            _buildLocalList(),
                            
                            // --- بەشی ناونیشان و دوگمەی سڕینەوەی گشتی ---
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Row(
                                children: [
                                  const Expanded(child: Divider(thickness: 1.2)),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.list_alt, color: Colors.grey, size: 20),
                                  const SizedBox(width: 5),
                                  const Text(
                                    "لیستی خەرجییەکان", 
                                    style: TextStyle(color: Color.fromARGB(255, 53, 49, 49), fontWeight: FontWeight.bold, fontSize: 15)
                                  ),
                                  const SizedBox(width: 10),
                                  // دوگمەی سڕینەوە لێرە دانراوە
                                  IconButton(
                                    onPressed: () {
                                      if (supabaseList.isNotEmpty) {
                                        _deleteFilteredDriverItems(supabaseList); // دڵنیابە ئەم فەنکشنەت هەیە
                                      } else {
                                        _showSnackBar("لیستەکە خاڵییە", Colors.orange);
                                      }
                                    },
                                    icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red, size: 28),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(child: Divider(thickness: 1.2)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildSliverExpenseList(supabaseList),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    }
   
  Future<void> _deleteFilteredDriverItems(List<dynamic> items) async {
  if (items.isEmpty) return;

  bool? confirm = await showDialog(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text("ئاگاداری"),
        content: Text("دڵنیایت لە سڕینەوەی هەموو (${items.length}) خەرجییەکانی ئەم درایڤەرە؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), 
            child: const Text("نەخێر")
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 164, 139, 139)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("بەڵێ، هەمووی بسڕەوە"),
          ),
        ],
      ),
    ),
  );

  if (confirm == true) {
    try {
      for (var i in items) {
        // لێرە ئایدی خەرجی بەکاردێنین
        final id = i['id_expense']; 

        if (id != null) {
          // ١. سڕینەوە لە سوپابەیس (خشتەی خەرجییەکان)
          await supabase.from('tb_expenses').delete().eq('id_expense', id);

          // ٢. سڕینەوە لە ئۆبجێکت بۆکس (ئەگەر فەنکشنی سڕینەوەی خەرجیت هەیە)
          // ئەگەر ناوی فەنکشنەکەت جیاوازە، لێرە بیگۆڕە
          objectBoxService.deleteExpense(id);
        }
      }
      
      _showSnackBar("هەموو خەرجییەکان بە سەرکەوتوویی سڕانەوە", Colors.green);
      
      // بۆ دڵنیایی زیاتر شاشەکە نوێ دەکەینەوە
      setState(() {});
      
    } catch (e) {
      _showSnackBar("هەڵەیەک لە کاتی سڕینەوە ڕوویدا", Colors.red);
    }
  }
  }

  Widget _buildTotalSummary(List<dynamic> list) {
    double totalPaid = 0;
    double totalDebt = 0;
    for (var item in list) {
      double amt = double.tryParse(item['amount_expense'].toString()) ?? 0.0;
      if (item['e_pay_type'] == 'دراوە') { totalPaid += amt; } else { totalDebt += amt; }
    }
    return Row(
      children: [
        _summaryItem("کۆی نەختی مەسروف", totalPaid, const Color(0xFF2A7035), Icons.check_circle ),
        const SizedBox(width: 12),
        _summaryItem("کۆی قەرزی مەسروف", totalDebt, Colors.red.shade600, Icons.info_outline),
      ],
    );
  }

  Widget _summaryItem(String label, double value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(height: 1),
          // لێرەدا فۆنتی ناونیشانەکە (وەک: کۆی قەرز)
          Text(
            label,
            style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // لێرەدا فۆنتی ژمارەکە (بڕی پارەکە)
          Text(  intl.NumberFormat("#,###").format(value) + " دینار",
            //value.toStringAsFixed(0), 
            style: TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
      decoration: const BoxDecoration(
        color: Color(0xFF144D45),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Text(widget.driverName, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
          Text("کۆدی : ${widget.driverCode}", style: const TextStyle(color: Colors.white70, fontSize: 3)),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color:  Colors.white38  , borderRadius: BorderRadius.circular(20),
       boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: Column(
        children: [
          _myTextField(_eNameController, "ناوی مەسروف(نمونە:گاز)", Icons.handyman , fontSize: 15, textColor: Colors.black87),
          const SizedBox(height: 10),
          _myTextField(_eAmountController, "بڕی پارە بە دینار", Icons.payments, isNum: true, fontSize: 15, textColor: Colors.black87),
          const SizedBox(height: 12),
          _segmentedRow(['قەرز', 'دراوە'], selectedExpensePayType, (v) => setState(() => selectedExpensePayType = v) ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: _saveExpense,
            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 63, 167, 75), minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("تۆمارکردن", style: TextStyle(color: Colors.white,fontSize: 20 ,fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverExpenseList(List<dynamic> list) {
  if (list.isEmpty) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(60),
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: 50, color: Colors.grey.shade300),
              const SizedBox(height: 10),
              const Text("هیچ خەرجییەک تۆمار نەکراوە", 
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  // لێرەدا چیتر .reversed بەکارناهێنین چونکە لە ستریمەکەدا ascending: false مان داناوە
  final displayList = list; 

  return SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // داتاکە ڕاستەوخۆ لە لیستە ئەسڵییەکە وەردەگرین
          final item = displayList[index]; 
          
          // --- لۆجیکی حیسابکردنی بڕی پارە ---
          String rawAmount = item['amount_expense']?.toString() ?? "0";
          double amountValue = double.tryParse(rawAmount.replaceAll(',', '')) ?? 0.0;
          String formattedAmount = formatter.format(amountValue);
          
          bool isDebt = item['e_pay_type'] == 'قەرز';
          String dateStr = "";
          try {
            if (item['add_date'] != null) {
              DateTime dt = DateTime.parse(item['add_date'].toString());
              dateStr = intl.DateFormat('yyyy/MM/dd').format(dt);
            }
          } catch (e) { dateStr = ""; }

          // --- دیزاینی کارتەکە وەک خۆیەتی و تێک ناچێت ---
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      color: isDebt ? Colors.redAccent : const Color(0xFF2A7035),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: isDebt ? Colors.red.shade50 : Colors.green.shade50,
                      child: Icon(
                        isDebt ? Icons.arrow_outward : Icons.call_received,
                        color: isDebt ? Colors.red : Colors.green,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['name_expense'] ?? "بێ ناو",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF1A1A1A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (dateStr.isNotEmpty)
                              Text(
                                dateStr,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "$formattedAmount   دینار",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: isDebt ? Colors.red.shade700 : const Color(0xFF2A7035),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDebt ? Colors.red.shade50 : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isDebt ? "قەرز" : "نەخت",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDebt ? Colors.red : Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.grey.shade400, size: 20),
                    onPressed: () async {
                       // یەکەم: بانگی فەنکشنی سڕینەوەکە بکە
                       await _deleteExpense(item);
                      // دووەم: شاشەکە نوێ بکەرەوە (Refresh)
                       setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: displayList.length,
      ),
    ),
  );
  }

  Widget _buildLocalList() {
    return FutureBuilder(
      future: objectBoxService.getExpensesForFarmer(widget.driverId),
      builder: (context, snapshot) {
        final list = (snapshot.data as List?)?.where((e) => e.is_synced == false).toList() ?? [];
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          children: list.map((e) => Card(color: Colors.orange.shade50, child: ListTile(title: Text(e.name_expense), subtitle: const Text("بێ ئینتەرنێت..."), trailing: const Icon(Icons.cloud_off, color: Colors.orange)))).toList(),
        );
      },
    );
  }

  Widget _segmentedRow(List<String> opts, String selected, Function(String) onSelect) {
  return Row(
    children: opts.map((o) {
      bool isS = selected == o;

      // دیاریکردنی ڕەنگی جیاواز بۆ هەر جۆرێک
      Color activeColor;
      if (o == "قەرز") {
        activeColor = const Color.fromARGB(255, 218, 71, 63); // سوورەکە
      } else {
        activeColor = const Color.fromARGB(255, 63, 149, 50); // سەوزە تۆخەکە
      }

      return Expanded(
        child: GestureDetector(
          onTap: () => onSelect(o),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              // ئەگەر هەڵبژێردرابوو (isS)، ڕەنگە تایبەتەکەی خۆی بدەرێ، ئەگەر نا ڕەساسی
              color: isS ? activeColor : Colors.grey.shade300 , 
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                o,
                style: TextStyle(
                  color: isS ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList(),
  );
  }


 Widget _myTextField(TextEditingController ctrl, String hint, IconData icon, {bool isNum = false, double fontSize = 13, Color textColor = Colors.black}) {
  return TextField(
    controller: ctrl,
    textAlign: TextAlign.right,
    keyboardType: isNum ? TextInputType.number : TextInputType.text,
    // لێرەدا fontSize و textColor مان دانا بۆ ئەوەی داینامیکی بێت
    style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.w500),
    inputFormatters: isNum ? [ThousandsSeparatorInputFormatter()] : [],
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF144D45), size: 22),
      hintText: hint,
      hintStyle: TextStyle(fontSize: fontSize - 2), // هینتەکە هەمیشە کەمێک بچووکتر بێت
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    ),
  );
  }
  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center), backgroundColor: color, duration: const Duration(seconds: 2)));
  }
}