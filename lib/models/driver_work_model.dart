import 'package:objectbox/objectbox.dart';

@Entity() // گۆڕا بۆ Entity
class DriverWork {
  @Id() // ئایدی سەرەکی لێرە جێگیر دەبێت
  int id;
  final int? w_id_driver; // ئایدی سایەقەکە
  final int? d_id_farmer;
  final String? d_name_farmer;
  final String? type_work;
  final String? name_place_work;
  final String? time_work_hours;
  final String? time_work_minutes;
  final String? count_work;
  final String? price_work;
  final String? pay_type_work;
  final bool is_synced;

  DriverWork({
    this.w_id_driver,
    this.id = 0, // هەمیشە وەک 0 دەستی پێ بکە بۆ ئەوەی خۆی ئۆتۆ ئینکرێمێنت بێت
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

  // لۆژیکی toMap وەک خۆی ماوەتەوە بۆ ئەوەی پەیوەندی سوپابەیس تێک نەچێت
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