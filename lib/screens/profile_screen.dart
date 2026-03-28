import 'dart:ui';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> data; // ئەم داتایە لە سوپابەیسەوە دێت (tb_farmer)
  const ProfileScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("پڕۆفایلی من", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'KurdishFont')),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // پاشبنەمای سەوز بۆ گونجان لەگەڵ کارەکەت
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // وێنەی پڕۆفایل
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 4),
                    ),
                    child: const CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white12,
                      child: Icon(Icons.person, size: 65, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    data['name_farmer'] ?? "ناوی تۆمارنەکراوە",
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      data['job_title'] ?? "جوتیار / خاوەن مەکینە",
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // کارتی زانیارییەکان
                  _buildGlassCard(
                    child: Column(
                      children: [
                        _buildInfoRow("کۆدی بەکارهێنەر", data['code_farmer'] ?? "---", Icons.vpn_key_outlined),
                        _buildDivider(),
                        _buildInfoRow("ژمارەی مۆبایل", data['phone_farmer'] ?? "دیاری نەکراوە", Icons.phone_android_outlined),
                        _buildDivider(),
                        _buildInfoRow("بەرواری دەستپێک", _formatDate(data['create_date']), Icons.event_available_outlined),
                        _buildDivider(),
                        _buildInfoRow("ماوەی بەسەرچوون", _formatDate(data['expiry_date']), Icons.timer_outlined),
                      ],
                    ),
                  ),
                  const Spacer(),
                  
                  // دوگمەی گەڕانەوە
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                      label: const Text("گەڕانەوە بۆ لاپەڕەی سەرەکی", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
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
  }

  String _formatDate(dynamic date) {
    if (date == null) return "---";
    try {
      return date.toString().split('T')[0];
    } catch (e) {
      return date.toString();
    }
  }

  Widget _buildDivider() => Divider(color: Colors.white.withOpacity(0.1), height: 30);

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      textDirection: TextDirection.rtl, // بۆ ڕێکخستنی دەقە کوردییەکە
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(width: 15),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}