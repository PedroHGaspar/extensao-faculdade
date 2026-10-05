import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_simples/data/models/appointment_model.dart';
import 'package:gestao_simples/data/models/client_model.dart';
import 'package:gestao_simples/data/models/service_model.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    Hive
      ..registerAdapter(ClientModelAdapter())
      ..registerAdapter(ServiceModelAdapter())
      ..registerAdapter(AppointmentModelAdapter());
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('gestao_simples_test');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('cliente é salvo e lido novamente após reabrir o box', () async {
    final createdAt = DateTime(2026, 9, 1, 10);
    var box = await Hive.openBox<ClientModel>('clients');
    await box.put(
      'c1',
      ClientModel(
        id: 'c1',
        name: 'Maria Souza',
        phone: '(48) 99999-0000',
        notes: 'Prefere horários pela manhã',
        createdAt: createdAt,
      ),
    );
    await box.close();

    box = await Hive.openBox<ClientModel>('clients');
    final client = box.get('c1')!;
    expect(client.name, 'Maria Souza');
    expect(client.phone, '(48) 99999-0000');
    expect(client.notes, 'Prefere horários pela manhã');
    expect(client.createdAt, createdAt);
  });

  test('serviço é salvo e lido novamente após reabrir o box', () async {
    var box = await Hive.openBox<ServiceModel>('services');
    await box.put(
      's1',
      ServiceModel(
        id: 's1',
        name: 'Corte masculino',
        durationMinutes: 40,
        price: 45,
        description: 'Corte com máquina e tesoura',
        createdAt: DateTime(2026, 9, 1),
      ),
    );
    await box.close();

    box = await Hive.openBox<ServiceModel>('services');
    final service = box.get('s1')!;
    expect(service.name, 'Corte masculino');
    expect(service.durationMinutes, 40);
    expect(service.price, 45);
    expect(service.description, 'Corte com máquina e tesoura');
  });

  test('agendamento é salvo e lido novamente após reabrir o box', () async {
    final dateTime = DateTime(2026, 9, 10, 14, 30);
    var box = await Hive.openBox<AppointmentModel>('appointments');
    await box.put(
      'a1',
      AppointmentModel(
        id: 'a1',
        clientId: 'c1',
        clientName: 'Maria Souza',
        clientPhone: '(48) 99999-0000',
        serviceId: 's1',
        serviceName: 'Manicure',
        dateTime: dateTime,
        value: 35,
        status: AppointmentStatus.scheduled,
        notes: 'Trazer esmalte próprio',
        createdAt: DateTime(2026, 9, 1),
      ),
    );
    await box.close();

    box = await Hive.openBox<AppointmentModel>('appointments');
    final appointment = box.get('a1')!;
    expect(appointment.clientName, 'Maria Souza');
    expect(appointment.serviceName, 'Manicure');
    expect(appointment.dateTime, dateTime);
    expect(appointment.value, 35);
    expect(appointment.status, AppointmentStatus.scheduled);
    expect(appointment.notes, 'Trazer esmalte próprio');
  });
}
