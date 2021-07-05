// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bike_activity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BikeActivityAdapter extends TypeAdapter<BikeActivity> {
  @override
  final int typeId = 0;

  @override
  BikeActivity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BikeActivity(
      startLocation: fields[0] as String?,
      endLocation: fields[1] as String?,
      activityDate: fields[2] as DateTime?,
      averageSpeed: fields[3] as double?,
      burnedCalories: fields[4] as double?,
      distance: fields[5] as double?,
      elevation: fields[6] as double?,
      duration: fields[7] as int?,
      weatherData: fields[8] as Weather?,
      coordinates: (fields[9] as List?)?.cast<LatLng>(),
      latLngBounds: fields[10] as LatLngBounds?,
    );
  }

  @override
  void write(BinaryWriter writer, BikeActivity obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.startLocation)
      ..writeByte(1)
      ..write(obj.endLocation)
      ..writeByte(2)
      ..write(obj.activityDate)
      ..writeByte(3)
      ..write(obj.averageSpeed)
      ..writeByte(4)
      ..write(obj.burnedCalories)
      ..writeByte(5)
      ..write(obj.distance)
      ..writeByte(6)
      ..write(obj.elevation)
      ..writeByte(7)
      ..write(obj.duration)
      ..writeByte(8)
      ..write(obj.weatherData)
      ..writeByte(9)
      ..write(obj.coordinates)
      ..writeByte(10)
      ..write(obj.latLngBounds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BikeActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeatherAdapter extends TypeAdapter<Weather> {
  @override
  final typeId = 2;

  @override
  Weather read(BinaryReader reader) {
    var json = jsonDecode(reader.readString());
    return Weather(json);
  }

  @override
  void write(BinaryWriter writer, Weather obj) {
    writer.writeString(jsonEncode(obj.toJson()));
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WeatherAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class LatLngAdapter extends TypeAdapter<LatLng?> {
  @override
  final typeId = 3;

  @override
  LatLng? read(BinaryReader reader) {
    var json = jsonDecode(reader.readString());
    return LatLng.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, LatLng? obj) {
    writer.writeString(jsonEncode(obj!.toJson()));
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LatLngAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class LatLngBoundsAdapter extends TypeAdapter<LatLngBounds> {
  @override
  final typeId = 4;

  @override
  LatLngBounds read(BinaryReader reader) {
    return LatLngBounds(
      southwest: LatLng.fromJson(jsonDecode(reader.readString()))!,
      northeast: LatLng.fromJson(jsonDecode(reader.readString()))!,
    );
  }

  @override
  void write(BinaryWriter writer, LatLngBounds obj) {
    writer.writeString(jsonEncode(obj.southwest.toJson()));
    writer.writeString(jsonEncode(obj.northeast.toJson()));
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LatLngBoundsAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}