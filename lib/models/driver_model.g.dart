// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DriverAdapter extends TypeAdapter<Driver> {
  @override
  final int typeId = 0;

  @override
  Driver read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Driver(
      id: fields[0] as int,
      d_id_farmer: fields[1] as int?,
      id_farmer_user: fields[2] as int?,
      id_add_user: fields[3] as int?,
      code_farmer: fields[4] as String?,
      d_name_farmer: fields[5] as String?,
      d_phone_farmer: fields[6] as String?,
      add_date: fields[7] as String?,
      is_synced: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Driver obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.d_id_farmer)
      ..writeByte(2)
      ..write(obj.id_farmer_user)
      ..writeByte(3)
      ..write(obj.id_add_user)
      ..writeByte(4)
      ..write(obj.code_farmer)
      ..writeByte(5)
      ..write(obj.d_name_farmer)
      ..writeByte(6)
      ..write(obj.d_phone_farmer)
      ..writeByte(7)
      ..write(obj.add_date)
      ..writeByte(8)
      ..write(obj.is_synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
