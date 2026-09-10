import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/models/appointment_model.dart';
import 'data/models/client_model.dart';
import 'data/models/service_model.dart';
import 'data/repositories/appointment_repository.dart';
import 'data/repositories/client_repository.dart';
import 'data/repositories/service_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive
    ..registerAdapter(ClientModelAdapter())
    ..registerAdapter(ServiceModelAdapter())
    ..registerAdapter(AppointmentModelAdapter());

  final clientsBox = await Hive.openBox<ClientModel>('clients');
  final servicesBox = await Hive.openBox<ServiceModel>('services');
  final appointmentsBox =
      await Hive.openBox<AppointmentModel>('appointments');

  runApp(
    GestaoSimplesApp(
      clientRepository: ClientRepository(clientsBox),
      serviceRepository: ServiceRepository(servicesBox),
      appointmentRepository: AppointmentRepository(appointmentsBox),
    ),
  );
}
