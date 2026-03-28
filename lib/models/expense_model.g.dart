// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseModelAdapter extends TypeAdapter<ExpenseModel> {
  @override
  final int typeId = 2;

  @override
  ExpenseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseModel(
      id: fields[0] as int,
      id_expense: fields[1] as int?,
      id_add_user: fields[2] as int?,
      id_farmer_user: fields[3] as int?,
      name_farmer: fields[4] as String?,
      code_farmer: fields[5] as String?,
      name_expense: fields[6] as String?,
      amount_expense: fields[7] as String?,
      e_pay_type: fields[8] as String?,
      total_expense_qarz: fields[9] as String?,
      total_expense_draw: fields[10] as String?,
      is_synced: fields[11] as bool,
      add_date: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.id_expense)
      ..writeByte(2)
      ..write(obj.id_add_user)
      ..writeByte(3)
      ..write(obj.id_farmer_user)
      ..writeByte(4)
      ..write(obj.name_farmer)
      ..writeByte(5)
      ..write(obj.code_farmer)
      ..writeByte(6)
      ..write(obj.name_expense)
      ..writeByte(7)
      ..write(obj.amount_expense)
      ..writeByte(8)
      ..write(obj.e_pay_type)
      ..writeByte(9)
      ..write(obj.total_expense_qarz)
      ..writeByte(10)
      ..write(obj.total_expense_draw)
      ..writeByte(11)
      ..write(obj.is_synced)
      ..writeByte(12)
      ..write(obj.add_date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
