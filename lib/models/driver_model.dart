import 'package:hive/hive.dart';

// ئەم دێڕە زۆر گرنگە بۆ دروستکردنی کۆدی ئۆتۆماتیکی دواتر
part 'driver_model.g.dart';

@HiveType(typeId: 0) // هەر مۆدێلێک دەبێت TypeId یەکی جیاوازی هەبێت
class Driver extends HiveObject {
  
  @HiveField(0)
  int id; 

  @HiveField(1)
  int? d_id_farmer; 

  @HiveField(2)
  int? id_farmer_user;

  @HiveField(3)
  int? id_add_user;

  @HiveField(4)
  String? code_farmer;

  @HiveField(5)
  String? d_name_farmer;

  @HiveField(6)
  String? d_phone_farmer;

  @HiveField(7)
  String? add_date;
  
  @HiveField(8)
  bool is_synced;

  Driver({
    this.id = 0, 
    this.d_id_farmer,
    this.id_farmer_user,
    this.id_add_user,
    this.code_farmer,
    this.d_name_farmer,
    this.d_phone_farmer,
    this.add_date,
    this.is_synced = false,
  });

  // ئەم بەشە وەک خۆی پارێزراوە بۆ پەیوەندی سوپابەیس
  Map<String, dynamic> toMap() {
    return {
      'id_farmer_user': id_farmer_user,
      'id_add_user': id_add_user,
      'code_farmer': code_farmer,
      'd_name_farmer': d_name_farmer,
      'd_phone_farmer': d_phone_farmer,
      'add_date': add_date,
    };
  }

  // ئەگەر ویستت لە سوپابەیسەوە داتا وەربگریتەوە
  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id_farmer_user: map['id_farmer_user'],
      id_add_user: map['id_add_user'],
      code_farmer: map['code_farmer'],
      d_name_farmer: map['d_name_farmer'],
      d_phone_farmer: map['d_phone_farmer'],
      add_date: map['add_date'],
      is_synced: true,
    );
  }
}