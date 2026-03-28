import 'package:objectbox/objectbox.dart';

@Entity() // گۆڕا بۆ Entity
class ShopTypeModel {
  @Id() 
  int id; // لێرە جۆری ئایدی دەبێت تەنها int بێت (نۆڵ نابێت)

  @Unique() // جێگرەوەی Index(unique: true) ی ئیسارە
  int? t_id_type; 

  int? t_id_farmer; 
  String? t_name_type; 
  
  bool is_synced; 

  ShopTypeModel({
    this.id = 0, // هەمیشە بە 0 دەست پێ دەکات
    this.t_id_type,
    this.t_id_farmer,
    this.t_name_type,
    this.is_synced = false,
  });

  // لۆژیکی fromMap وەک خۆی ماوەتەوە
  factory ShopTypeModel.fromMap(Map<String, dynamic> map) {
    return ShopTypeModel(
      t_id_type: map['t_id_type'],
      t_id_farmer: map['t_id_farmer'],
      t_name_type: map['t_name_type'],
      is_synced: true,
    );
  }

  // لۆژیکی toMap وەک خۆی ماوەتەوە
  Map<String, dynamic> toMap() {
    return {
      't_id_farmer': t_id_farmer,
      't_name_type': t_name_type,
    };
  }
}