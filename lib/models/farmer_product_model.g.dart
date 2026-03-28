// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farmer_product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FarmerProductModelAdapter extends TypeAdapter<FarmerProductModel> {
  @override
  final int typeId = 3;

  @override
  FarmerProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FarmerProductModel(
      id: fields[0] as int,
      id_product: fields[1] as int?,
      id_farmer_user: fields[2] as int?,
      id_add_user: fields[3] as int?,
      code_farmer: fields[4] as String?,
      name_shop: fields[5] as String?,
      name_product: fields[6] as String?,
      number_product: fields[7] as double?,
      price_product: fields[8] as double?,
      total_amount: fields[9] as double?,
      p_pay_type: fields[10] as String?,
      p_many_type: fields[11] as String?,
      total_amount_draw_iq: fields[12] as double?,
      total_amount_draw_dolar: fields[13] as double?,
      total_amount_qarz_iq: fields[14] as double?,
      total_amount_qarz_dolar: fields[15] as double?,
      is_synced: fields[16] as bool,
      add_date: fields[17] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FarmerProductModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.id_product)
      ..writeByte(2)
      ..write(obj.id_farmer_user)
      ..writeByte(3)
      ..write(obj.id_add_user)
      ..writeByte(4)
      ..write(obj.code_farmer)
      ..writeByte(5)
      ..write(obj.name_shop)
      ..writeByte(6)
      ..write(obj.name_product)
      ..writeByte(7)
      ..write(obj.number_product)
      ..writeByte(8)
      ..write(obj.price_product)
      ..writeByte(9)
      ..write(obj.total_amount)
      ..writeByte(10)
      ..write(obj.p_pay_type)
      ..writeByte(11)
      ..write(obj.p_many_type)
      ..writeByte(12)
      ..write(obj.total_amount_draw_iq)
      ..writeByte(13)
      ..write(obj.total_amount_draw_dolar)
      ..writeByte(14)
      ..write(obj.total_amount_qarz_iq)
      ..writeByte(15)
      ..write(obj.total_amount_qarz_dolar)
      ..writeByte(16)
      ..write(obj.is_synced)
      ..writeByte(17)
      ..write(obj.add_date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FarmerProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
