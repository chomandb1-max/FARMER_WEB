// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_type_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShopTypeModelAdapter extends TypeAdapter<ShopTypeModel> {
  @override
  final int typeId = 4;

  @override
  ShopTypeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShopTypeModel(
      id: fields[0] as int,
      t_id_type: fields[1] as int?,
      t_id_farmer: fields[2] as int?,
      t_name_type: fields[3] as String?,
      is_synced: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ShopTypeModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.t_id_type)
      ..writeByte(2)
      ..write(obj.t_id_farmer)
      ..writeByte(3)
      ..write(obj.t_name_type)
      ..writeByte(4)
      ..write(obj.is_synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopTypeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
