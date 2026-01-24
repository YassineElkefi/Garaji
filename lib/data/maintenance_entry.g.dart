// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaintenanceEntryAdapter extends TypeAdapter<MaintenanceEntry> {
  @override
  final int typeId = 1;

  @override
  MaintenanceEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaintenanceEntry(
      date: fields[0] as DateTime,
      title: fields[1] as String,
      description: fields[2] as String,
      mileage: fields[3] as int,
      cost: fields[4] as double,
      category: fields[5] as String,
      recommendations: fields[6] as String,
      vehicleKey: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MaintenanceEntry obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.mileage)
      ..writeByte(4)
      ..write(obj.cost)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.recommendations)
      ..writeByte(7)
      ..write(obj.vehicleKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaintenanceEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
