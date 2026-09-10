import 'package:hive/hive.dart';

class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.createdAt,
    this.price,
    this.description,
  });

  final String id;
  final String name;
  final int durationMinutes;
  final double? price;
  final String? description;
  final DateTime createdAt;

  ServiceModel copyWith({
    String? name,
    int? durationMinutes,
    double? price,
    String? description,
  }) {
    return ServiceModel(
      id: id,
      name: name ?? this.name,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price,
      description: description,
      createdAt: createdAt,
    );
  }
}

class ServiceModelAdapter extends TypeAdapter<ServiceModel> {
  @override
  final int typeId = 1;

  @override
  ServiceModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };
    return ServiceModel(
      id: fields[0] as String,
      name: fields[1] as String,
      durationMinutes: fields[2] as int,
      price: fields[3] as double?,
      description: fields[4] as String?,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ServiceModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.durationMinutes)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.createdAt);
  }
}
