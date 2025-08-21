// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PropertyModelAdapter extends TypeAdapter<PropertyModel> {
  @override
  final int typeId = 2;

  @override
  PropertyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PropertyModel(
      id: fields[0] as String,
      address: fields[1] as String,
      rentAmount: fields[2] as double,
      dueDate: fields[3] as DateTime,
      tenantId: fields[4] as String?,
      leaseStart: fields[5] as DateTime?,
      leaseEnd: fields[6] as DateTime?,
      agreementFilePath: fields[7] as String?,
      pics: (fields[8] as List?)?.cast<String>(),
      name: fields[9] as String?,
      isOccupied: (fields[10] as bool?) ?? false,
      propertyType: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PropertyModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.rentAmount)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.tenantId)
      ..writeByte(5)
      ..write(obj.leaseStart)
      ..writeByte(6)
      ..write(obj.leaseEnd)
      ..writeByte(7)
      ..write(obj.agreementFilePath)
      ..writeByte(8)
      ..write(obj.pics)
      ..writeByte(9)
      ..write(obj.name)
      ..writeByte(10)
      ..write(obj.isOccupied)
      ..writeByte(11)
      ..write(obj.propertyType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
