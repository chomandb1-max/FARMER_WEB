import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';

class ActivationScreen extends StatefulWidget {
  final String code;
  final String jobTitle;

  const ActivationScreen({super.key, required this.code, required this.jobTitle});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  // --- فەنکشنی سەرەکی تۆمارکردن ---
  Future<void> _handleActivation() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تکایە ناو و ژمارەی مۆبایل پڕ بکەرەوە", textAlign: TextAlign.right))
      );
      return;
    }

    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ژمارەی مۆبایل ناتەواوە", textAlign: TextAlign.right))
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // ١. ناردن بۆ سوپابەیس و دروستکردنی پڕۆفایل
      final result = await SupabaseService().activateAndCreateProfile(
        code: widget.code.trim(), 
        name: name, 
        phone: phone, 
        jobTitle: widget.jobTitle
      );

      if (result != null) {
        // ٢. سەیڤکردنی زانیارییەکان لە ناو SharedPrefs (بۆ ئەوەی ئەپەکە بزانێت کێ چۆتە ژوورەوە)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('farmer_code', widget.code.trim());
        await prefs.setString('farmer_name', name);
        await prefs.setInt('farmer_id', result['id_farmer']); // ئەمە زۆر گرنگە بۆ تەیبڵەکانی تر
        await prefs.setBool('is_active', true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("بە سەرکەوتوویی ئەکتیڤ کرا"))
          );
          // ٣. چوونی کۆتایی بۆ لاپەڕەی سەرەکی و سڕینەوەی لاپەڕەکانی پێشوو
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("کۆدەکە هەڵەیە یان پێشتر بەکارهاتووە"))
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("هەڵە لە پەیوەندی: $e"))
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // دیزاینی سەرەوە
          Container(
            height: 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade800, Colors.green.shade500],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Icon(Icons.verified_user_rounded, size: 80, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    "ئەکتیڤکردنی ${widget.jobTitle}",
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 50),
                  
                  // کارتی سپی فۆرمەکە
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      children: [
                        _buildTextField(nameController, "ناوی تەواو", Icons.person_outline),
                        const SizedBox(height: 20),
                        _buildTextField(phoneController, "ژمارەی مۆبایل", Icons.phone_android_outlined, isNumber: true),
                        const SizedBox(height: 40),
                        
                        // دوگمەی تۆمارکردن
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleActivation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 2,
                            ),
                            child: isLoading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("چالاککردن و چوونە ژوورەوە", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text("کۆدی بەکارهێنراو: ${widget.code}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(icon, color: Colors.green),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2)),
      ),
    );
  }
}