import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/appointment_model.dart';
import '../../shared/widgets/appointment_card.dart';
import '../../shared/widgets/empty_state.dart';
import 'appointment_detail_page.dart';
import 'appointment_form_page.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  DateTime? _selectedDate = DateTime.now();

  Future<void> _openForm() async {
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
      MaterialPageRoute<void>(builder: (_) => const AppointmentFormPage()),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Filtrar por data',
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _openDetails(AppointmentModel appointment) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AppointmentDetailPage(appointmentId: appointment.id),
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    List<AppointmentModel> items,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 10),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppointmentCard(
              appointment: item,
              onTap: () => _openDetails(item),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).appointmentRepository;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agenda',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: AnimatedBuilder(
        animation: repository,
        builder: (context, _) {
          final appointments = _selectedDate == null
              ? repository.all
              : repository.onDate(_selectedDate!);
          final scheduled = appointments
              .where((item) => item.status == AppointmentStatus.scheduled)
              .toList();
          final completed = appointments
              .where((item) => item.status == AppointmentStatus.completed)
              .toList();
          final cancelled = appointments
              .where((item) => item.status == AppointmentStatus.cancelled)
              .toList();

          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Hoje'),
                      selected: _selectedDate != null &&
                          AppFormatters.isSameDay(
                            _selectedDate!,
                            DateTime.now(),
                          ),
                      onSelected: (_) =>
                          setState(() => _selectedDate = DateTime.now()),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Todos'),
                      selected: _selectedDate == null,
                      onSelected: (_) =>
                          setState(() => _selectedDate = null),
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(Icons.calendar_month_outlined, size: 18),
                      label: Text(
                        _selectedDate == null
                            ? 'Escolher data'
                            : AppFormatters.date(_selectedDate!),
                      ),
                      onPressed: _pickDate,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: appointments.isEmpty
                    ? EmptyState(
                        icon: Icons.event_busy_outlined,
                        title: 'Nenhum agendamento encontrado.',
                        message:
                            'Crie um agendamento para começar a organizar sua agenda.',
                        actionLabel: 'Novo agendamento',
                        onAction: _openForm,
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                        children: [
                          _section(context, 'Agendados', scheduled),
                          _section(context, 'Concluídos', completed),
                          _section(context, 'Cancelados', cancelled),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Agendar'),
      ),
    );
  }
}
