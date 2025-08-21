// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TenantModelAdapter extends TypeAdapter<TenantModel> {
  @override
  final int typeId = 3;

  @override
  TenantModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TenantModel(
      id: fields[0] as String,
      name: fields[1] as String,
      contact: fields[2] as String,
      email: fields[3] as String?,
      propertyId: fields[4] as String?,
      moveInDate: fields[5] as DateTime?,
      emergencyContact: fields[6] as String?,
      occupation: fields[7] as String?,
      securityDeposit: (fields[8] as num?)?.toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, TenantModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.contact)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.propertyId)
      ..writeByte(5)
      ..write(obj.moveInDate)
      ..writeByte(6)
      ..write(obj.emergencyContact)
      ..writeByte(7)
      ..write(obj.occupation)
      ..writeByte(8)
      ..write(obj.securityDeposit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TenantModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
