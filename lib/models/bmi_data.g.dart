// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bmi_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BMIDataAdapter extends TypeAdapter<BMIData> {
  @override
  final int typeId = 1;

  @override
  BMIData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BMIData(
      weightInKg: fields[0] as double,
      heightInCm: fields[1] as double,
      bmi: fields[2] as double,
      date: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BMIData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.weightInKg)
      ..writeByte(1)
      ..write(obj.heightInCm)
      ..writeByte(2)
      ..write(obj.bmi)
      ..writeByte(3)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BMIDataAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
