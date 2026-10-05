import 'package:hive/hive.dart';

abstract final class AppointmentStatus {
  static const scheduled = 'scheduled';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
}

class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.serviceId,
    required this.serviceName,
    required this.dateTime,
    required this.status,
    required this.createdAt,
    this.clientPhone,
    this.value,
    this.notes,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String? clientPhone;
  final String serviceId;
  final String serviceName;
  final DateTime dateTime;
  final double? value;
  final String status;
  final String? notes;
  final DateTime createdAt;

  AppointmentModel copyWith({
    String? clientId,
    String? clientName,
    String? clientPhone,
    String? serviceId,
    String? serviceName,
    DateTime? dateTime,
    double? value,
    String? status,
    String? notes,
  }) {
    return AppointmentModel(
      id: id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      dateTime: dateTime ?? this.dateTime,
      value: value ?? this.value,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}

class AppointmentModelAdapter extends TypeAdapter<AppointmentModel> {
  @override
  final int typeId = 2;

  @override
  AppointmentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };
    return AppointmentModel(
      id: fields[0] as String,
      clientId: fields[1] as String,
      clientName: fields[2] as String,
      clientPhone: fields[3] as String?,
      serviceId: fields[4] as String,
      serviceName: fields[5] as String,
      dateTime: fields[6] as DateTime,
      value: fields[7] as double?,
      status: fields[8] as String,
      notes: fields[9] as String?,
      createdAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AppointmentModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.clientId)
      ..writeByte(2)
      ..write(obj.clientName)
      ..writeByte(3)
      ..write(obj.clientPhone)
      ..writeByte(4)
      ..write(obj.serviceId)
      ..writeByte(5)
      ..write(obj.serviceName)
      ..writeByte(6)
      ..write(obj.dateTime)
      ..writeByte(7)
      ..write(obj.value)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.createdAt);
  }
}
