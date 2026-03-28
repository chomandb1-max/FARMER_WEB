import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:farmer_app/main.dart'; 


class DriverReportPage extends StatefulWidget {
  final int driverId;
  final String driverName;

  const DriverReportPage({super.key, required this.driverId, required this.driverName});

  @override
  State<DriverReportPage> createState() => _DriverReportPageState();
}

class _DriverReportPageState extends State<DriverReportPage> {
  final supabase = Supabase.instance.client;
  int refreshKey = 0; // ئەمە بۆ ڕیفریشکردنی ستریمەکە بەکاردێت
  String? selectedFarmer;
  String? selectedWorkType;
  DateTime? selectedDate;
  
  List<String> farmersList = [];
  List<String> workTypesList = [];

   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCE6DF),
      appBar: AppBar(
        title: Text(" ${widget.driverName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: const Color(0xFF144D45),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
            key: ValueKey(refreshKey), // ئەم دێڕە زیاد بکە
        stream: supabase
            .from('tb_driver_work')
            .stream(primaryKey: ['id_work'])
            .eq('w_id_driver', widget.driverId) // ئەم دێڕە گرنگترینە: تەنها ئەو ئیشانە بێنە کە ئایدی سایەقەکەیان وەک ئەمەیە
            .order('date_work', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("هیچ کارێک لە داتابەیس نییە"));

          final allData = snapshot.data!;
          
          // دروستکردنی لیستەکان
          farmersList = allData.map((e) => e['d_name_farmer'].toString()).toSet().toList();
          workTypesList = allData.map((e) => e['type_work'].toString()).toSet().toList();

          // --- چارەسەری سوربوونی شاشەکە لێرەدایە ---
          // ئەگەر نرخێکی فلتەر هەڵبژێردرابوو بەڵام ئێستا لە لیستەکەدا نەمابوو (سڕابووەوە)، سفر دەکرێتەوە
          if (selectedFarmer != null && !farmersList.contains(selectedFarmer)) {
            selectedFarmer = null;
          }
          if (selectedWorkType != null && !workTypesList.contains(selectedWorkType)) {
            selectedWorkType = null;
          }
          // ---------------------------------------

          var filteredData = allData;
          if (selectedFarmer != null) filteredData = filteredData.where((e) => e['d_name_farmer'] == selectedFarmer).toList();
          if (selectedWorkType != null) filteredData = filteredData.where((e) => e['type_work'] == selectedWorkType).toList();
          if (selectedDate != null) {
             String formatted = intl.DateFormat('yyyy-MM-dd').format(selectedDate!);
             filteredData = filteredData.where((e) => e['date_work'] == formatted).toList();
          }

          double totalCash = 0;
          double totalDebt = 0;
          int totalH = 0;
          int totalM = 0;

          for (var item in filteredData) {
            double amount = double.tryParse(item['total_work']?.toString() ?? '0') ?? 0;
            if (item['pay_type_work'] == 'نەخت' || item['pay_type_work'] == 'دراوە') {
              totalCash += amount;
            } else {
              totalDebt += amount;
            }
            totalH += int.tryParse(item['time_work_hours']?.toString() ?? '0') ?? 0;
            totalM += int.tryParse(item['time_work_minutes']?.toString() ?? '0') ?? 0;
          }
          
          totalH += totalM ~/ 60;
          totalM = totalM % 60;

          return Column(
            children: [
              _buildModernHeader(totalCash, totalDebt, totalH, totalM),
              _buildFilterBar(filteredData),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 10),
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) => _buildWorkItem(filteredData[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // چاککردنی کۆی گشتییەکان (نوسین لەسەرەوە و گەورەتر)
  Widget _buildModernHeader(double cash, double debt, int h, int m) {
    double grandTotal = cash + debt;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:  const Color(0xFF144D45), 
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const Text("کۆی گشتی ئیشەکان💸", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), // نوسین لەسەرەوە
          const SizedBox(height: 10),
          Text("${intl.NumberFormat("#,###").format(grandTotal)} دینار", 
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _headerStat("نەخت (دراو)", intl.NumberFormat("#,###").format(cash), Colors.greenAccent),
              _headerStat(" کۆی قەرز ", intl.NumberFormat("#,###").format(debt), Colors.redAccent),
              _headerStat("کۆی سەعات"," سەعات $h\n$m  دەقە ", Colors.blueAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), // نوسین لە سەرەوە
        const SizedBox(height: 10),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)), // ژمارە لە خوارەوە
      ],
    );
  }

 Widget _buildFilterBar(List<Map<String, dynamic>> dataToOps) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    child: Column(
      children: [
        // ڕیزی یەکەم: فلتەری ناوی جوتیار و جۆری ئیش
        Row(
          children: [
            Expanded(child: _filterChip(" : ناوی جوتیار", selectedFarmer, farmersList, (v) => setState(() => selectedFarmer = v))),
            const SizedBox(width: 10),
            Expanded(child: _filterChip(" : جۆری ئیش", selectedWorkType, workTypesList, (v) => setState(() => selectedWorkType = v))),
          ],
        ),
        const SizedBox(height: 8),

        // ڕیزی دووەم: ڕیفریش، بەروار، و سڕینەوەی گشتی
        Row(
          children: [
            // ١. دوگمەی ڕیفریش (پاککردنەوەی فلتەرەکان)
            IconButton(
              onPressed: () => setState(() {
                selectedFarmer = null;
                selectedWorkType = null;
                selectedDate = null;
              }),
              icon: const Icon(Icons.refresh_rounded, color: Colors.redAccent, size: 26),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            
            const SizedBox(width: 10),

            // ٢. دوگمەی بەروار (بچووکتر کراوەتەوە)
            Expanded(
              child: InkWell(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
                child: Container(
                  height: 40, // بەرزییەکەی کەم کراوەتەوە بۆ ئەوەی زۆر گەورە نەبێت
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 16, color: Colors.blueGrey),
                      const SizedBox(width: 6),
                      Text(
                        selectedDate == null ? "بەروار" : intl.DateFormat('yyyy-MM-dd').format(selectedDate!),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // ٣. دوگمەی سڕینەوەی گشتی (تەنها ئەو لیستەی فلتەر کراوە دەسڕێتەوە)
          IconButton(
            onPressed: ()async {
              if (selectedFarmer == null && selectedWorkType == null && selectedDate == null) {
             _showSnackBar("تکایە سەرەتا فلتەرێک دیاری بکە بۆ سڕینەوەی بەکۆمەڵ", Colors.orange);
             return; // لێرە کۆدەکە دەوەستێت و ناچێت بۆ سڕینەوە
              }
             if ( dataToOps.isNotEmpty) {
              await _deleteFilteredDriverItems(dataToOps);
             setState(() {
              selectedFarmer = null;
              selectedWorkType = null;
              selectedDate = null;
               });

             } else {
               _showSnackBar("لیستەکە خاڵییە", Colors.orange);
                }
                  },
                   icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red, size: 28),
                   padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
                    ),
                    ],
        ),
      ],
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
        content: Text("دڵنیایت لە سڕینەوەی ${items.length} تۆماری ئەم درایڤەرە؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("نەخێر")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("بەڵێ، بسڕەوە"),
          ),
        ],
      ),
    ),
  );

  if (confirm == true) {
    try {
      for (var i in items) {
        // لێرە id_work بەکاربهێنە چونکە لە ستریمەکە ئاوا نووسیوتە
        final id = i['id_work']; 

        if (id != null) {
          // ١. سڕینەوە لە سوپابەیس
          await supabase.from('tb_driver_work').delete().eq('id_work', id);

          // ٢. سڕینەوە لە ئۆبجێکت بۆکس
          hiveService.deleteLocalDriverWork(id);
        }
      }
      
      // چونکە StreamBuilder بەکاردێنیت، خۆی ئۆتۆماتیکی نوێ دەبێتەوە
      _showSnackBar("تۆمارەکان بە سەرکەوتوویی سڕانەوە", Colors.green);
    } catch (e) {
      _showSnackBar("هەڵەیەک لە کاتی سڕینەوە ڕوویدا", Colors.red);
    }
  }
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

  Widget _filterChip(String label, String? selected, List<String> items, Function(String?) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [

        Padding(
          padding: const EdgeInsets.only(right:2, bottom: 2),
          child: Text(label, style: const TextStyle(fontSize: 20, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
          child: DropdownButton<String>(
            value: selected,
            hint: const Text("هەمووی", style: TextStyle(fontSize: 14,color: Colors.black, fontWeight: FontWeight.bold)),
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold)))).toList(),
            onChanged: onSelected,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkItem(Map<String, dynamic> w) {
    bool isDebt = w['pay_type_work'] == "قەرز" || w['pay_type_work'] == "قەرز";
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () => _deleteRecord(w['id_work']), // لێرە کرا بە id_work
            ),
            const VerticalDivider(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(w['d_name_farmer'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue)),
                  Text("${w['type_work']} -- ${w['name_place_work'] ?? ''}", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(w['pay_type_work'], style: TextStyle(color: isDebt ? Colors.red : Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time, size: 10, color: Colors.grey),
                      Text(" ${w['count_work']??0} س ${w['time_work_hours']??0} د ${w['time_work_minutes']??0}  --  دانە  ", style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 8),
                      //const Icon(Icons.tag, size: 14, color: Colors.grey),
                    ],
                  ),
                  Text(w['date_work'] ?? "", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: 25),
            Column(
              children: [
                const Text("کۆی گشتی", style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 59, 58, 58) )),
                Text(intl.NumberFormat("#,###").format(w['total_work'] ?? 0), 
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                const Text("دینار", style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteRecord(dynamic idWork) async {
    bool confirm = await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("سڕینەوە", textAlign: TextAlign.right),
        content: const Text("دڵنیایت لە سڕینەوەی ئەم کارە؟", textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("نەخێر")),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text("بەڵێ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await supabase.from('tb_driver_work').delete().eq('id_work', idWork);
      setState(() {}); 
      // چونکە StreamBuilder بەکاردێنیت، یەکسەر لیستەکە خۆی نوێ دەکاتەوە
    }
  }
}