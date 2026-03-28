import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  // فەنکشنی پشکنینی خەت بە شێوەی ڕاستەوخۆ
  Future<bool> hasInternet() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    
    // ئەگەر لیستەکە بەتاڵ بوو یان تەنها 'none' تێدا بوو، واتە خەت نییە
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return false;
    }
    
    // لێرە پشکنین دەکەین بۆ هەموو جۆرە پەیوەندییەکان (WiFi, Mobile, Ethernet, VPN, Bluetooth)
    // ئەگەر هەر یەکێک لەمانە هەبێت، واتە ئامێرەکە پەیوەستە بە نێتۆرکێکەوە
    return results.any((result) => result != ConnectivityResult.none);
  }

  // ئەم Stream-ە زۆر بەسوودە بۆ ئەوەی لە هەموو ئەپەکەدا ئاگاداری گۆڕانی خەت بیت
  Stream<List<ConnectivityResult>> get connectivityStream => _connectivity.onConnectivityChanged;
}