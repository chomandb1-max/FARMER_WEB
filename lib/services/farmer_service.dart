import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/farmer_product_model.dart';
import '../models/expense_model.dart';

class FarmerService {
  final _supabase = Supabase.instance.client;

  // ١. ناردنی بەرهەم بۆ Supabase
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
    }
  }

  // ٢. ناردنی خەرجی بۆ Supabase
  Future<void> insertExpense(ExpenseModel expense) async {
    try {
      final data = expense.toMap();
      data.remove('id_expense'); // چونکە خۆی دروست دەبێت

      await _supabase
          .from('tb_expenses') 
          .insert(data);
    } catch (e) {
      throw Exception('هەڵە لە ناردنی خەرجی: $e');
    }
  }

  // ٣. هێنانی ستریمی بەرهەمەکان (بۆ ئەوەی هەر گۆڕانکارییەک کرا یەکسەر بیبینیت)
  Stream<List<Map<String, dynamic>>> getProductsStream(String codeFarmer) {
    return _supabase
        .from('tb_product_farmer')
        .stream(primaryKey: ['id_product']) 
        .eq('code_farmer', codeFarmer)
        .order('add_date', ascending: false); 
  }

  // ٤. هێنانی ستریمی خەرجییەکان
  Stream<List<Map<String, dynamic>>> getExpensesStream(String codeFarmer) {
    return _supabase
        .from('tb_expenses')
        .stream(primaryKey: ['id_expense']) 
        .eq('code_farmer', codeFarmer)
        .order('add_date', ascending: false); 
  }
}