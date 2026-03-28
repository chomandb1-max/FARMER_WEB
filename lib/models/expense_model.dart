import 'package:hive/hive.dart';

// ناوی فایلی دروستبوو (Generated)
part 'expense_model.g.dart';

@HiveType(typeId: 2)
class ExpenseModel extends HiveObject {
  
  @HiveField(0)
  int id; 

  @HiveField(1)
  final int? id_expense; 

  @HiveField(2)
  final int? id_add_user;    

  @HiveField(3)
  final int? id_farmer_user; 

  @HiveField(4)
  final String? name_farmer; 

  @HiveField(5)
  final String? code_farmer; 

  @HiveField(6)
  final String? name_expense; 

  @HiveField(7)
  final String? amount_expense; 

  @HiveField(8)
  final String? e_pay_type; 
  
  @HiveField(9)
  final String? total_expense_qarz; 

  @HiveField(10)
  final String? total_expense_draw; 
  
  @HiveField(11)
  bool is_synced;

  @HiveField(12)
  DateTime? add_date; 

  ExpenseModel({
    this.id = 0, 
    this.id_expense,
    this.id_add_user,
    this.id_farmer_user,
    this.name_farmer,
    this.code_farmer,
    this.name_expense,
    this.amount_expense,
    this.e_pay_type,
    this.total_expense_qarz,
    this.total_expense_draw,
    this.is_synced = false,
    this.add_date,
  });

  // لۆژیکی toMap وەک خۆی ماوەتەوە بۆ ئەوەی پەیوەندی سوپابەیس تێک نەچێت
  Map<String, dynamic> toMap() {
    return {
      'id_add_user': id_add_user,
      'id_farmer_user': id_farmer_user,
      'name_farmer': name_farmer,
      'code_farmer': code_farmer,
      'name_expense': name_expense,
      'amount_expense': amount_expense,
      'e_pay_type': e_pay_type,
      'total_expense_qarz': total_expense_qarz,
      'total_expense_draw': total_expense_draw,
      'add_date': add_date?.toIso8601String(), 
    };
  }
}