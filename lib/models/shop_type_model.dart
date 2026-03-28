import 'package:hive/hive.dart';

// فایلی یارمەتیدەر بۆ دروستکردنی ئەداپتەر
part 'shop_type_model.g.dart';

@HiveType(typeId: 4)
class ShopTypeModel extends HiveObject {
  
  @HiveField(0)
  int id; 

  @HiveField(1)
  int? t_id_type; 

  @HiveField(2)
  int? t_id_farmer; 

  @HiveField(3)
  String? t_name_type; 
  
  @HiveField(4)
  bool is_synced; 

  ShopTypeModel({
    this.id = 0, 
    this.t_id_type,
    this.t_id_farmer,
    this.t_name_type,
    this.is_synced = false,
  });

  // پاراستنی لۆجیکی fromMap بۆ وەرگرتنی داتا لە سوپابەیس
  factory ShopTypeModel.fromMap(Map<String, dynamic> map) {
    return ShopTypeModel(
      t_id_type: map['t_id_type'],
      t_id_farmer: map['t_id_farmer'],
      t_name_type: map['t_name_type'],
      is_synced: true,
    );
  }

  // پاراستنی لۆجیکی toMap بۆ ناردنی داتا بۆ سوپابەیس
  Map<String, dynamic> toMap() {
    return {
      't_id_farmer': t_id_farmer,
      't_name_type': t_name_type,
    };
  }
}