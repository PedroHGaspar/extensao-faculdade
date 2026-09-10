import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import 'client_form_page.dart';

class ClientDetailPage extends StatelessWidget {
  const ClientDetailPage({required this.clientId, super.key});

  final String clientId;

  Future<void> _delete(BuildContext context, String name) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Excluir cliente?',
      message:
          'O cliente $name será removido. Os agendamentos existentes manterão o histórico.',
    );
    if (!confirmed || !context.mounted) return;
    await AppScope.of(context).clientRepository.delete(clientId);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Cliente excluído com sucesso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).clientRepository;
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        final client = repository.findById(clientId);
        if (client == null) {
          return const Scaffold(
            body: Center(child: Text('Cliente não encontrado.')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes do cliente'),
            actions: [
              IconButton(
                tooltip: 'Editar',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ClientFormPage(client: client),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Excluir',
                onPressed: () => _delete(context, client.name),
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
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          client.name.substring(0, 1).toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        client.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _DetailTile(
                icon: Icons.phone_outlined,
                label: 'Telefone',
                value: client.phone ?? 'Não informado',
              ),
              _DetailTile(
                icon: Icons.notes_rounded,
                label: 'Observações',
                value: client.notes ?? 'Nenhuma observação',
              ),
              _DetailTile(
                icon: Icons.calendar_today_outlined,
                label: 'Cliente desde',
                value: AppFormatters.date(client.createdAt),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
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
