// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServiceReminderAdapter extends TypeAdapter<ServiceReminder> {
  @override
  final int typeId = 2;

  @override
  ServiceReminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServiceReminder(
      id: fields[0] as String,
      vehicleKey: fields[1] as int,
      title: fields[2] as String,
      description: fields[3] as String,
      reminderType: fields[4] as String,
      intervalDays: fields[5] as int?,
      intervalMileage: fields[6] as int?,
      lastServiceDate: fields[7] as DateTime?,
      lastServiceMileage: fields[8] as int?,
      nextDueDate: fields[9] as DateTime?,
      nextDueMileage: fields[10] as int?,
      isActive: fields[11] as bool,
      notificationId: fields[12] as int?,
      category: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ServiceReminder obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.vehicleKey)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.reminderType)
      ..writeByte(5)
      ..write(obj.intervalDays)
      ..writeByte(6)
      ..write(obj.intervalMileage)
      ..writeByte(7)
      ..write(obj.lastServiceDate)
      ..writeByte(8)
      ..write(obj.lastServiceMileage)
      ..writeByte(9)
      ..write(obj.nextDueDate)
      ..writeByte(10)
      ..write(obj.nextDueMileage)
      ..writeByte(11)
      ..write(obj.isActive)
      ..writeByte(12)
      ..write(obj.notificationId)
      ..writeByte(13)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
