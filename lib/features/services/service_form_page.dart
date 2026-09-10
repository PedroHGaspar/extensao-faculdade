import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/id_generator.dart';
import '../../data/models/service_model.dart';

class ServiceFormPage extends StatefulWidget {
  const ServiceFormPage({this.service, super.key});

  final ServiceModel? service;

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _durationController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final service = widget.service;
    _nameController = TextEditingController(text: service?.name);
    _durationController = TextEditingController(
      text: service?.durationMinutes.toString(),
    );
    _priceController = TextEditingController(
      text: service?.price?.toStringAsFixed(2).replaceAll('.', ','),
    );
    _descriptionController =
        TextEditingController(text: service?.description);
  }

  String? _optional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final existing = widget.service;
    final service = ServiceModel(
      id: existing?.id ?? IdGenerator.create(),
      name: _nameController.text.trim(),
      durationMinutes: int.parse(_durationController.text),
      price: AppFormatters.parseCurrency(_priceController.text),
      description: _optional(_descriptionController.text),
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    await AppScope.of(context).serviceRepository.save(service);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existing == null
              ? 'Serviço cadastrado com sucesso.'
              : 'Serviço atualizado com sucesso.',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.service == null ? 'Novo serviço' : 'Editar serviço'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: widget.service == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nome do serviço *',
                prefixIcon: Icon(Icons.design_services_outlined),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Informe o nome do serviço.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Duração em minutos *',
                prefixIcon: Icon(Icons.timer_outlined),
                suffixText: 'min',
              ),
              validator: (value) {
                final duration = int.tryParse(value ?? '');
                return duration == null || duration <= 0
                    ? 'Informe uma duração maior que zero.'
                    : null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Preço',
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
            TextFormField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              label: const Text('Salvar serviço'),
            ),
          ],
        ),
      ),
    );
  }
}
