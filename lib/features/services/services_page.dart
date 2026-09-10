import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/service_model.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../shared/widgets/empty_state.dart';
import 'service_form_page.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  Future<void> _openForm(BuildContext context, [ServiceModel? service]) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ServiceFormPage(service: service),
      ),
    );
  }

  Future<void> _delete(BuildContext context, ServiceModel service) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Excluir serviço?',
      message:
          'O serviço ${service.name} será removido. Os agendamentos existentes manterão o histórico.',
    );
    if (!confirmed || !context.mounted) return;
    await AppScope.of(context).serviceRepository.delete(service.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Serviço excluído com sucesso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).serviceRepository;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Serviços',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: AnimatedBuilder(
        animation: repository,
        builder: (context, _) {
          final services = repository.all;
          if (services.isEmpty) {
            return EmptyState(
              icon: Icons.design_services_outlined,
              title: 'Nenhum serviço cadastrado ainda.',
              message: 'Adicione os serviços que você oferece.',
              actionLabel: 'Cadastrar serviço',
              onAction: () => _openForm(context),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final service = services[index];
              return Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.design_services_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  title: Text(
                    service.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      '${service.durationMinutes} min  •  '
                      '${AppFormatters.currency(service.price)}',
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _openForm(context, service);
                      } else {
                        _delete(context, service);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Editar')),
                      PopupMenuItem(value: 'delete', child: Text('Excluir')),
                    ],
                  ),
                  onTap: () => _openForm(context, service),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo serviço'),
      ),
    );
  }
}
