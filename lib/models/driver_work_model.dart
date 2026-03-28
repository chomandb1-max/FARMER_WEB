import 'package:hive/hive.dart';

// ئەم دێڕە بۆ دروستکردنی فایلی یارمەتیدەرە، دەستی لێ مەدە
part 'driver_work_model.g.dart';

@HiveType(typeId: 1)
class DriverWork extends HiveObject {
  
  @HiveField(0)
  int id;

  @HiveField(1)
  final int? w_id_driver;

  @HiveField(2)
  final int? d_id_farmer;

  @HiveField(3)
  final String? d_name_farmer;

  @HiveField(4)
  final String? type_work;

  @HiveField(5)
  final String? name_place_work;

  @HiveField(6)
  final String? time_work_hours;

  @HiveField(7)
  final String? time_work_minutes;

  @HiveField(8)
  final String? count_work;

  @HiveField(9)
  final String? price_work;

  @HiveField(10)
  final String? pay_type_work;

  @HiveField(11)
  final bool is_synced;

  DriverWork({
    this.w_id_driver,
    this.id = 0, 
    this.d_id_farmer,
    this.d_name_farmer,
    this.type_work,
    this.name_place_work,
    this.time_work_hours,
    this.time_work_minutes,
    this.count_work,
    this.price_work,
    this.pay_type_work,
    this.is_synced = false,
  });

  // پاراستنی لۆجیکی گۆڕینی داتا بۆ سوپابەیس بە هەمان ناوەکان
  Map<String, dynamic> toMap() {
    return {
      'w_id_driver': w_id_driver,
      'd_id_farmer': d_id_farmer,
      'd_name_farmer': d_name_farmer,
      'type_work': type_work,
      'name_place_work': name_place_work,
      'time_work_hours': int.tryParse(time_work_hours ?? '0') ?? 0,
      'time_work_minutes': int.tryParse(time_work_minutes ?? '0') ?? 0,
      'count_work': double.tryParse(count_work ?? '0') ?? 0,
      'price_work': double.tryParse(price_work ?? '0') ?? 0.0,
      'pay_type_work': pay_type_work == "قەرز" ? "قەرز" : (pay_type_work ?? "دراوە"),
    };
  }
}