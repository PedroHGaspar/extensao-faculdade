import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/id_generator.dart';
import '../../core/utils/iterable_utils.dart';
import '../../data/models/appointment_model.dart';
import '../../data/models/client_model.dart';
import '../../data/models/service_model.dart';

class AppointmentFormPage extends StatefulWidget {
  const AppointmentFormPage({this.appointment, super.key});

  final AppointmentModel? appointment;

  @override
  State<AppointmentFormPage> createState() => _AppointmentFormPageState();
}

class _AppointmentFormPageState extends State<AppointmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _valueController;
  late final TextEditingController _notesController;
  String? _clientId;
  String? _serviceId;
  late DateTime _date;
  late TimeOfDay _time;
  late String _status;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final appointment = widget.appointment;
    _clientId = appointment?.clientId;
    _serviceId = appointment?.serviceId;
    final initialDate = appointment?.dateTime ?? DateTime.now();
    _date = DateTime(initialDate.year, initialDate.month, initialDate.day);
    _time = TimeOfDay.fromDateTime(
      appointment?.dateTime ?? DateTime.now().add(const Duration(hours: 1)),
    );
    _status = appointment?.status ?? AppointmentStatus.scheduled;
    _valueController = TextEditingController(
      text: appointment?.value?.toStringAsFixed(2).replaceAll('.', ','),
    );
    _notesController = TextEditingController(text: appointment?.notes);
  }

  String? _optional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Escolha a data',
      cancelText: 'Voltar',
      confirmText: 'Selecionar',
    );
    if (selected != null) setState(() => _date = selected);
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _time,
      helpText: 'Escolha o horário',
      cancelText: 'Voltar',
      confirmText: 'Selecionar',
    );
    if (selected != null) setState(() => _time = selected);
  }

  void _onServiceChanged(String? id, List<ServiceModel> services) {
    setState(() {
      _serviceId = id;
      final service =
          firstWhereOrNull(services, (item) => item.id == id);
      if (service?.price != null) {
        _valueController.text =
            service!.price!.toStringAsFixed(2).replaceAll('.', ',');
      }
    });
  }

  Future<void> _save(
    List<ClientModel> clients,
    List<ServiceModel> services,
  ) async {
    if (!_formKey.currentState!.validate()) return;
    final client =
        firstWhereOrNull(clients, (item) => item.id == _clientId);
    final service =
        firstWhereOrNull(services, (item) => item.id == _serviceId);
    if (client == null || service == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um cliente e um serviço.')),
      );
      return;
    }

    setState(() => _saving = true);
    final existing = widget.appointment;
    final appointment = AppointmentModel(
      id: existing?.id ?? IdGenerator.create(),
      clientId: client.id,
      clientName: client.name,
      clientPhone: client.phone,
      serviceId: service.id,
      serviceName: service.name,
      dateTime: DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      ),
      value: AppFormatters.parseCurrency(_valueController.text),
      status: _status,
      notes: _optional(_notesController.text),
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    await AppScope.of(context).appointmentRepository.save(appointment);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existing == null
              ? 'Agendamento criado com sucesso.'
              : 'Agendamento atualizado com sucesso.',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final clients = scope.clientRepository.all;
    final services = scope.serviceRepository.all;
    final validClientId =
        clients.any((item) => item.id == _clientId) ? _clientId : null;
    final validServiceId =
        services.any((item) => item.id == _serviceId) ? _serviceId : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.appointment == null
              ? 'Novo agendamento'
              : 'Editar agendamento',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<String>(
              value: validClientId,
              decoration: const InputDecoration(
                labelText: 'Cliente *',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              items: clients
                  .map(
                    (client) => DropdownMenuItem(
                      value: client.id,
                      child: Text(
                        client.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _clientId = value),
              validator: (value) =>
                  value == null ? 'Selecione um cliente.' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: validServiceId,
              decoration: const InputDecoration(
                labelText: 'Serviço *',
                prefixIcon: Icon(Icons.design_services_outlined),
              ),
              items: services
                  .map(
                    (service) => DropdownMenuItem(
                      value: service.id,
                      child: Text(
                        service.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => _onServiceChanged(value, services),
              validator: (value) =>
                  value == null ? 'Selecione um serviço.' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(14),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data *',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(AppFormatters.date(_date)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(14),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Horário *',
                        prefixIcon: Icon(Icons.schedule_rounded),
                      ),
                      child: Text(_time.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valueController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor',
                prefixIcon: Icon(Icons.payments_outlined),
                prefixText: 'R\$ ',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final price = AppFormatters.parseCurrency(value);
                return price == null || price < 0
                    ? 'Informe um valor válido.'
                    : null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: const [
                DropdownMenuItem(
                  value: AppointmentStatus.scheduled,
                  child: Text('Agendado'),
                ),
                DropdownMenuItem(
                  value: AppointmentStatus.completed,
                  child: Text('Concluído'),
                ),
                DropdownMenuItem(
                  value: AppointmentStatus.cancelled,
                  child: Text('Cancelado'),
                ),
              ],
              onChanged: (value) => setState(() => _status = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Observações',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed:
                  _saving ? null : () => _save(clients, services),
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              label: const Text('Salvar agendamento'),
            ),
          ],
        ),
      ),
    );
  }
}
