import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/appointment_model.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../shared/widgets/status_chip.dart';
import 'appointment_form_page.dart';

class AppointmentDetailPage extends StatelessWidget {
  const AppointmentDetailPage({required this.appointmentId, super.key});

  final String appointmentId;

  Future<void> _changeStatus(BuildContext context, String status) async {
    final repository = AppScope.of(context).appointmentRepository;
    final appointment = repository.findById(appointmentId);
    if (appointment == null) return;
    await repository.save(appointment.copyWith(status: status));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == AppointmentStatus.completed
              ? 'Atendimento marcado como concluído.'
              : 'Agendamento cancelado.',
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Excluir agendamento?',
      message: 'Essa ação removerá o agendamento deste aparelho.',
    );
    if (!confirmed || !context.mounted) return;
    await AppScope.of(context).appointmentRepository.delete(appointmentId);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Agendamento excluído com sucesso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).appointmentRepository;
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        final appointment = repository.findById(appointmentId);
        if (appointment == null) {
          return const Scaffold(
            body: Center(child: Text('Agendamento não encontrado.')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes do agendamento'),
            actions: [
              IconButton(
                tooltip: 'Editar',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        AppointmentFormPage(appointment: appointment),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Excluir',
                onPressed: () => _delete(context),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              appointment.clientName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          StatusChip(status: appointment.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appointment.serviceName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Data e horário',
                value: AppFormatters.dateTime(appointment.dateTime),
              ),
              _DetailRow(
                icon: Icons.phone_outlined,
                label: 'Telefone',
                value: appointment.clientPhone ?? 'Não informado',
              ),
              _DetailRow(
                icon: Icons.payments_outlined,
                label: 'Valor',
                value: AppFormatters.currency(appointment.value),
              ),
              _DetailRow(
                icon: Icons.notes_rounded,
                label: 'Observações',
                value: appointment.notes ?? 'Nenhuma observação',
              ),
              const SizedBox(height: 22),
              if (appointment.status != AppointmentStatus.completed)
                FilledButton.icon(
                  onPressed: () =>
                      _changeStatus(context, AppointmentStatus.completed),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Marcar como concluído'),
                ),
              if (appointment.status != AppointmentStatus.cancelled) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () =>
                      _changeStatus(context, AppointmentStatus.cancelled),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancelar agendamento'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(value),
        ),
      ),
    );
  }
}
