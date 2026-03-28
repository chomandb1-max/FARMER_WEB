import 'package:hive/hive.dart';

// ئەم دێڕە بۆ دروستکردنی فایلی یارمەتیدەرە
part 'farmer_product_model.g.dart';

@HiveType(typeId: 3)
class FarmerProductModel extends HiveObject {
  
  @HiveField(0)
  int id; 

  @HiveField(1)
  final int? id_product;

  @HiveField(2)
  final int? id_farmer_user; 

  @HiveField(3)
  final int? id_add_user;    

  @HiveField(4)
  final String? code_farmer; 

  @HiveField(5)
  final String? name_shop;

  @HiveField(6)
  final String? name_product;

  @HiveField(7)
  final double? number_product;

  @HiveField(8)
  final double? price_product;

  @HiveField(9)
  final double? total_amount;

  @HiveField(10)
  final String? p_pay_type; 

  @HiveField(11)
  final String? p_many_type;

  @HiveField(12)
  final double? total_amount_draw_iq;

  @HiveField(13)
  final double? total_amount_draw_dolar; 

  @HiveField(14)
  final double? total_amount_qarz_iq;

  @HiveField(15)
  final double? total_amount_qarz_dolar;

  @HiveField(16)
  bool is_synced;

  @HiveField(17)
  DateTime? add_date; 

  FarmerProductModel({
    this.id = 0, 
    this.id_product,
    this.id_farmer_user,
    this.id_add_user,
    this.code_farmer,
    this.name_shop,
    this.name_product,
    this.number_product,
    this.price_product,
    this.total_amount,
    this.p_pay_type,
    this.p_many_type,
    this.total_amount_draw_iq = 0,
    this.total_amount_draw_dolar = 0,
    this.total_amount_qarz_iq = 0,
    this.total_amount_qarz_dolar = 0,
    this.is_synced = false,
    this.add_date,
  });

  // لۆژیکی toMap بە بێ دەستکاری ماوەتەوە بۆ سوپابەیس
  Map<String, dynamic> toMap() {
    return {
      'id_farmer_user': id_farmer_user,
      'id_add_user': id_add_user,
      'code_farmer': code_farmer,
      'name_shop': name_shop,
      'name_product': name_product,
      'number_product': number_product,
      'price_product': price_product,
      'total_amount': total_amount,
      'p_pay_type': p_pay_type,
      'p_many_type': p_many_type,
      'total_amount_draw_iq': total_amount_draw_iq,
      'total_amount_draw_dolar': total_amount_draw_dolar, 
      'total_amount_qarz_iq': total_amount_qarz_iq,
      'total_amount_qarz_dolar': total_amount_qarz_dolar, 
      'add_date': add_date?.toIso8601String(),
    };
  }
}