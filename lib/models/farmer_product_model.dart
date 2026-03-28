import 'package:objectbox/objectbox.dart';

@Entity() // گۆڕا بۆ Entity
class FarmerProductModel {
  @Id() 
  int id; // گۆڕا لە isarId بۆ id

  final int? id_product;
  final int? id_farmer_user; 
  final int? id_add_user;    
  final String? code_farmer; 
  final String? name_shop;
  final String? name_product;
  final double? number_product;
  final double? price_product;
  final double? total_amount;
  final String? p_pay_type; 
  final String? p_many_type;

  final double? total_amount_draw_iq;
  final double? total_amount_draw_dolar; 
  final double? total_amount_qarz_iq;
  final double? total_amount_qarz_dolar;

  bool is_synced;
  @Property(type: PropertyType.date) // تەنها لێرە دایبنێ، لە سەرووی ناوی گۆڕدراوەکە
  DateTime? add_date; 

  FarmerProductModel({
    this.id = 0, // دەستپێک وەک هەمیشە 0
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

  // لۆژیکی toMap بە بێ دەستکاری ماوەتەوە
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