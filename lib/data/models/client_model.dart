import 'package:hive/hive.dart';

class ClientModel {
  const ClientModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.phone,
    this.notes,
  });

  final String id;
  final String name;
  final String? phone;
  final String? notes;
  final DateTime createdAt;

  ClientModel copyWith({
    String? name,
    String? phone,
    String? notes,
  }) {
    return ClientModel(
      id: id,
      name: name ?? this.name,
      phone: phone,
      notes: notes,
      createdAt: createdAt,
    );
  }
}

class ClientModelAdapter extends TypeAdapter<ClientModel> {
  @override
  final int typeId = 0;

  @override
  ClientModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };
    return ClientModel(
      id: fields[0] as String,
      name: fields[1] as String,
      phone: fields[2] as String?,
      notes: fields[3] as String?,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ClientModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.createdAt);
  }
}
