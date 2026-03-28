import 'package:objectbox/objectbox.dart';

@Entity() // گۆڕا بۆ Entity
class ExpenseModel {
  @Id() 
  int id; // گۆڕا لە isarId بۆ id بە جۆری int

  final int? id_expense; 
  final int? id_add_user;    
  final int? id_farmer_user; 
  final String? name_farmer; 
  final String? code_farmer; 
  final String? name_expense; 

  final String? amount_expense; 
  final String? e_pay_type; 
  
  final String? total_expense_qarz; 
  final String? total_expense_draw; 
  
  bool is_synced;
  @Property(type: PropertyType.date) // تەنها لێرە دایبنێ، لە سەرووی ناوی گۆڕدراوەکە
  DateTime? add_date; 

  ExpenseModel({
    this.id = 0, // هەمیشە وەک 0 دەستپێدەکات بۆ ئەوەی خۆی زیادی بکات
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