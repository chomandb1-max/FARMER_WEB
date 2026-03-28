// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_work_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DriverWorkAdapter extends TypeAdapter<DriverWork> {
  @override
  final int typeId = 1;

  @override
  DriverWork read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DriverWork(
      w_id_driver: fields[1] as int?,
      id: fields[0] as int,
      d_id_farmer: fields[2] as int?,
      d_name_farmer: fields[3] as String?,
      type_work: fields[4] as String?,
      name_place_work: fields[5] as String?,
      time_work_hours: fields[6] as String?,
      time_work_minutes: fields[7] as String?,
      count_work: fields[8] as String?,
      price_work: fields[9] as String?,
      pay_type_work: fields[10] as String?,
      is_synced: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DriverWork obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.w_id_driver)
      ..writeByte(2)
      ..write(obj.d_id_farmer)
      ..writeByte(3)
      ..write(obj.d_name_farmer)
      ..writeByte(4)
      ..write(obj.type_work)
      ..writeByte(5)
      ..write(obj.name_place_work)
      ..writeByte(6)
      ..write(obj.time_work_hours)
      ..writeByte(7)
      ..write(obj.time_work_minutes)
      ..writeByte(8)
      ..write(obj.count_work)
      ..writeByte(9)
      ..write(obj.price_work)
      ..writeByte(10)
      ..write(obj.pay_type_work)
      ..writeByte(11)
      ..write(obj.is_synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverWorkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
