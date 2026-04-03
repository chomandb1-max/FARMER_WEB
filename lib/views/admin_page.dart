import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:farmer_app/models/admin_page_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AdminControlPage extends StatefulWidget {
  const AdminControlPage({super.key});

  @override
  State<AdminControlPage> createState() => _AdminControlPageState();
}

class _AdminControlPageState extends State<AdminControlPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<AdminCodeModel> allCodes = [];
  List<AdminCodeModel> filteredCodes = [];
  bool isLoading = true;

  // ڕەنگەکان بۆ ستایلە دارکەکە
  final Color kDarkBg = const Color(0xFF080808);
  final Color kCardBg = const Color(0xFF121212);
  final Color kNeonGreen = const Color(0xFF00FF88);
  final Color kNeonBlue = const Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();
    fetchAdminData();
  }

  Future<void> fetchAdminData() async {
    try {
      final codesData = await supabase.from('tb_codes').select().order('id_code', ascending: true);
      final farmersData = await supabase.from('tb_farmer').select('code_farmer, name_farmer, phone_farmer, job_title');

      List<AdminCodeModel> tempData = [];
      AdminCodeModel? readyCode;

      for (var codeRow in codesData) {
        String currentCode = codeRow['code_value'];
        bool isUsed = codeRow['is_used'];
        
        if (!isUsed) {
          if (readyCode == null) {
            readyCode = AdminCodeModel(code: currentCode, isUsed: false);
          }
        } else {
          var farmer = farmersData.firstWhere((f) => f['code_farmer'] == currentCode, orElse: () => {});
          tempData.add(AdminCodeModel(
            code: currentCode,
            isUsed: true,
            name: farmer['name_farmer'] ?? "N/A",
            phone: farmer['phone_farmer'] ?? "N/A",
            jobTitle: farmer['job_title'] ?? "N/A",
          ));
        }
      }

      // لیستەکە پێچەوانە دەکەینەوە (تازەترین بۆ سەرەوە)
      tempData = tempData.reversed.toList();
      
      // کۆدە ئامادەکە دەخەینە یەکەم خانە
      if (readyCode != null) {
        tempData.insert(0, readyCode);
      }

      setState(() {
        allCodes = tempData;
        filteredCodes = tempData;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void filterSearch(String query) {
    setState(() {
      filteredCodes = allCodes.where((item) {
        return item.code.contains(query) || 
               (item.name ?? "").contains(query) || 
               (item.phone ?? "").contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        title: const Text("ADMIN TERMINAL", style: TextStyle(fontFamily: 'monospace', letterSpacing: 2)),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,leading: IconButton(
    icon: const Icon(Icons.logout, color: Colors.red),
    onPressed: () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_admin_logged_in'); // سڕینەوەی لۆگینەکە
      Navigator.pop(context); // گەڕانەوە بۆ پەیجی هێڵپ
       },
  ),

      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: kNeonGreen))
        : Column(
            children: [
              _buildHeaderStats(),
              _buildSearchBar(),
              Expanded(child: _buildCodeList()),
            ],
          ),
    );
  }

  Widget _buildHeaderStats() {
    int farmers = allCodes.where((e) => e.jobTitle == "جوتیار").length;
    int drivers = allCodes.where((e) => e.jobTitle == "سایەق مەکینە").length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(bottom: BorderSide(color: kNeonGreen.withValues(alpha: 0.3), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("TOTAL", (allCodes.length - 1).toString(), kNeonBlue),
          _statItem("FARMER", farmers.toString(), Colors.white),
          _statItem("DRIVER", drivers.toString(), Colors.white),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: TextField(
        onChanged: filterSearch,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "SEARCH SYSTEM...",
          hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
          prefixIcon: Icon(Icons.radar, color: kNeonGreen, size: 20),
          filled: true,
          fillColor: kCardBg,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildCodeList() {
    return ListView.builder(
      itemCount: filteredCodes.length,
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        final item = filteredCodes[index];
        bool isReady = !item.isUsed;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isReady ? kNeonGreen.withValues(alpha: 0.5) : Colors.transparent),
            boxShadow: isReady ? [BoxShadow(color: kNeonGreen.withValues(alpha: 0.1), blurRadius: 10)] : [],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            title: Text(
              item.code,
              style: TextStyle(
                color: isReady ? kNeonGreen : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
                fontFamily: 'monospace',
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: isReady 
                ? Text(">>> WAITING FOR NEXT USER", style: TextStyle(color: kNeonGreen.withValues(alpha: 0.7), fontSize: 11))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${item.name} | ${item.phone}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      Text("TYPE: ${item.jobTitle}", style: TextStyle(color: kNeonBlue.withValues(alpha: 0.8), fontSize: 11)),
                    ],
                  ),
            ),
            trailing: isReady 
              ? Icon(Icons.lock_open, color: kNeonGreen)
              : Icon(Icons.verified_user, color: kNeonBlue.withValues(alpha: 0.5), size: 20),
          ),
        );
      },
    );
  }
}