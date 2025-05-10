// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wish_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WishModelAdapter extends TypeAdapter<WishModel> {
  @override
  final int typeId = 1;

  @override
  WishModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WishModel(
      id: fields[0] as String,
      name: fields[1] as String,
      image: fields[2] as String?,
      price: fields[3] as String,
      pledgedBy: (fields[4] as Map?)?.cast<String, dynamic>(),
      associatedEvent: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WishModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.image)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.pledgedBy)
      ..writeByte(5)
      ..write(obj.associatedEvent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
