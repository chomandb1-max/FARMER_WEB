import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/farmer_product_model.dart';
import '../models/expense_model.dart';


class SupabaseService {
  final _supabase = Supabase.instance.client;

    Future<void> insertProduct(FarmerProductModel product) async {
    try {
      final data = product.toMap();
      // سڕینەوەی ئەو خانانەی کە لە داتابەیسەکەدا نین یان خۆکار (Auto) دروست دەبن
      data.remove('id_product'); // چونکە خۆی دروست دەبێت
      
      await _supabase
          .from('tb_product_farmer') 
          .insert(data);
    } catch (e) {
      throw Exception('هەڵە لە ناردنی بەرهەم: $e');
    }}

    Stream<List<Map<String, dynamic>>> getProductsStream(String codeFarmer) {
    return _supabase
        .from('tb_product_farmer')
        .stream(primaryKey: ['id_product']) 
        .eq('code_farmer', codeFarmer)
        .order('add_date', ascending: false); 
  }

    Future<Map<String, dynamic>?> insertExpense(Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('tb_expense')
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      print("هەڵە لە تۆمارکردنی خەرجی: $e");
      return null;
    }
  }


    Stream<List<Map<String, dynamic>>> getExpensesStream(String codeFarmer) {
    return _supabase
        .from('tb_expenses')
        .stream(primaryKey: ['id_expense']) 
        .eq('code_farmer', codeFarmer)
        .order('add_date', ascending: false); 
  }




  // ١. پشکنینی کۆد (ئایا هەیە و بەکارنەهێنراوە؟)
  Future<bool> isCodeValid(String codeValue) async {
    try {
      final response = await _supabase
          .from('tb_codes')
          .select('is_used')
          .eq('code_value', codeValue.trim())
          .maybeSingle();

      if (response == null) return false;
      return response['is_used'] == false;
    } catch (e) {
      print("هەڵە لە پشکنینی کۆد: $e");
      return false;
    }
  }

  // ٢. هێنانی زانیاری جوتیار
  Future<Map<String, dynamic>?> getFarmerProfile(String codeValue) async {
    try {
      final response = await _supabase
          .from('tb_farmer')
          .select('*')
          .eq('code_farmer', codeValue.trim())
          .maybeSingle();
      
      return response; 
    } catch (e) {
      print("هەڵە لە دۆزینەوەی پڕۆفایل: $e");
      return null;
    }
  }

  // ٣. دروستکردنی پڕۆفایلی نوێ و "سوتاندنی" کۆدەکە
  Future<Map<String, dynamic>?> activateAndCreateProfile({
    required String code, 
    required String name, 
    required String phone, 
    required String jobTitle
  }) async {
    try {
      final newUser = await _supabase.from('tb_farmer').insert({
        'code_farmer': code.trim(),
        'name_farmer': name,
        'phone_farmer': phone,
        'job_title': jobTitle,
        'create_date': DateTime.now().toIso8601String(),
        'expiry_date': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
      }).select().single();

      await _supabase.from('tb_codes')
          .update({'is_used': true})
          .eq('code_value', code.trim());

      return newUser;
    } catch (e) {
      print("هەڵە لە پڕۆسەی ئەکتیڤکردن: $e");
      return null;
    }
  }

  // ٤. تۆمارکردنی سایەقی نوێ
  Future<Map<String, dynamic>?> insertDriver(Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('tb_driver')
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      print("هەڵە لە تۆمارکردنی سایەق: $e");
      return null;
    }
  }

  // ٥. تۆمارکردنی کارێکی نوێ (وۆرک) - تێبینی: داتا لێرە بە Map دێت لە مۆدێلەکەوە
  Future<Map<String, dynamic>?> insertDriverWork(Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('tb_driver_work')
          .insert(data) // لێرە 'toMap'ی ناو مۆدێلەکە پێشتر گۆڕینی بۆ ژمارە کردووە
          .select()
          .single();
      return response;
    } catch (e) {
      print("هەڵە لە تۆمارکردنی ئیش: $e");
      return null;
    }
  }

  // ٦. تۆمارکردنی خەرجی نوێ (Expense) - ئەمەت نەمابوو بۆم زیاد کردیت

  // ٧. سڕینەوەی ئیش
  Future<void> deleteDriverWork(int idWork) async {
    try {
      await _supabase.from('tb_driver_work').delete().eq('id_work', idWork);
    } catch (e) {
      print("هەڵە لە سڕینەوەی ئیش: $e");
    }
  }
}

