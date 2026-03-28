import 'package:objectbox/objectbox.dart';

@Entity() // گۆڕا لە Collection بۆ Entity
class Driver {
  @Id() // ئایدی ئۆتۆماتیکی لێرە بەم شێوەیە دەنووسرێت
  int id; 

  int? d_id_farmer; 
  int? id_farmer_user;
  int? id_add_user;
  String? code_farmer;
  String? d_name_farmer;
  String? d_phone_farmer;
  String? add_date;
  
  bool is_synced;

  Driver({
    this.id = 0, // لە ئۆبجێکت بۆکس دەبێت بە 0 دەستپێبکات بۆ ئەوەی خۆی زیادی بکات
    this.d_id_farmer,
    this.id_farmer_user,
    this.id_add_user,
    this.code_farmer,
    this.d_name_farmer,
    this.d_phone_farmer,
    this.add_date,
    this.is_synced = false,
  });

  // ئەم بەشە وەک خۆی ماوەتەوە بۆ ئەوەی پەیوەندییەکەت لەگەڵ سوپابەیس تێک نەچێت
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
}