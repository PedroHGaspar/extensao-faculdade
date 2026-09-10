import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/appointment_repository.dart';
import 'data/repositories/client_repository.dart';
import 'data/repositories/service_repository.dart';
import 'features/appointments/appointment_form_page.dart';
import 'features/appointments/appointments_page.dart';
import 'features/clients/clients_page.dart';
import 'features/home/home_page.dart';
import 'features/services/services_page.dart';
import 'features/settings/settings_page.dart';

class GestaoSimplesApp extends StatelessWidget {
  const GestaoSimplesApp({
    required this.clientRepository,
    required this.serviceRepository,
    required this.appointmentRepository,
    super.key,
  });

  final ClientRepository clientRepository;
  final ServiceRepository serviceRepository;
  final AppointmentRepository appointmentRepository;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      clientRepository: clientRepository,
      serviceRepository: serviceRepository,
      appointmentRepository: appointmentRepository,
      child: MaterialApp(
        title: 'Gestão Simples',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const MainShell(),
      ),
    );
  }
}

class AppScope extends InheritedWidget {
  const AppScope({
    required this.clientRepository,
    required this.serviceRepository,
    required this.appointmentRepository,
    required super.child,
    super.key,
  });

  final ClientRepository clientRepository;
  final ServiceRepository serviceRepository;
  final AppointmentRepository appointmentRepository;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  Future<void> _openAppointmentForm() async {
    final scope = AppScope.of(context);
    if (scope.clientRepository.all.isEmpty ||
        scope.serviceRepository.all.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cadastre ao menos um cliente e um serviço antes de agendar.',
          ),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AppointmentFormPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onNewAppointment: _openAppointmentForm),
      const AppointmentsPage(),
      const ClientsPage(),
      const ServicesPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Clientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.design_services_outlined),
            selectedIcon: Icon(Icons.design_services_rounded),
            label: 'Serviços',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline_rounded),
            selectedIcon: Icon(Icons.info_rounded),
            label: 'Sobre',
          ),
        ],
      ),
    );
  }
}
