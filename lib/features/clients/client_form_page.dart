import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/utils/id_generator.dart';
import '../../data/models/client_model.dart';

class ClientFormPage extends StatefulWidget {
  const ClientFormPage({this.client, super.key});

  final ClientModel? client;

  @override
  State<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends State<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client?.name);
    _phoneController = TextEditingController(text: widget.client?.phone);
    _notesController = TextEditingController(text: widget.client?.notes);
  }

  String? _optional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final existing = widget.client;
    final client = ClientModel(
      id: existing?.id ?? IdGenerator.create(),
      name: _nameController.text.trim(),
      phone: _optional(_phoneController.text),
      notes: _optional(_notesController.text),
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    await AppScope.of(context).clientRepository.save(client);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existing == null
              ? 'Cliente cadastrado com sucesso.'
              : 'Cliente atualizado com sucesso.',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client == null ? 'Novo cliente' : 'Editar cliente'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: widget.client == null,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nome *',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Informe o nome do cliente.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                hintText: '(00) 00000-0000',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
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
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              label: const Text('Salvar cliente'),
            ),
          ],
        ),
      ),
    );
  }
}
