// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VehicleAdapter extends TypeAdapter<Vehicle> {
  @override
  final int typeId = 0;

  @override
  Vehicle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vehicle(
      brand: fields[0] as String,
      model: fields[1] as String,
      year: fields[2] as int,
      mileage: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Vehicle obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.brand)
      ..writeByte(1)
      ..write(obj.model)
      ..writeByte(2)
      ..write(obj.year)
      ..writeByte(3)
      ..write(obj.mileage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
