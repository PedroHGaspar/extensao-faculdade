import 'package:flutter/material.dart';

import '../../app.dart';
import '../../data/models/client_model.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../shared/widgets/empty_state.dart';
import 'client_detail_page.dart';
import 'client_form_page.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  Future<void> _openForm(BuildContext context, [ClientModel? client]) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClientFormPage(client: client),
      ),
    );
  }

  Future<void> _delete(BuildContext context, ClientModel client) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Excluir cliente?',
      message:
          'O cliente ${client.name} será removido. Os agendamentos existentes manterão o histórico.',
    );
    if (!confirmed || !context.mounted) return;
    await AppScope.of(context).clientRepository.delete(client.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cliente excluído com sucesso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).clientRepository;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clientes',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: AnimatedBuilder(
        animation: repository,
        builder: (context, _) {
          final clients = repository.all;
          if (clients.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline_rounded,
              title: 'Nenhum cliente cadastrado ainda.',
              message:
                  'Cadastre seus clientes para organizar melhor seus atendimentos.',
              actionLabel: 'Cadastrar cliente',
              onAction: () => _openForm(context),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: clients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final client = clients[index];
              return Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      client.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  title: Text(
                    client.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    client.phone?.isNotEmpty == true
                        ? client.phone!
                        : 'Telefone não informado',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _openForm(context, client);
                      } else {
                        _delete(context, client);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Editar')),
                      PopupMenuItem(value: 'delete', child: Text('Excluir')),
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ClientDetailPage(clientId: client.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Novo cliente'),
      ),
    );
  }
}
