import 'package:flutter/material.dart';

import '../../app.dart';
import '../../shared/widgets/confirmation_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _clearData(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Limpar todos os dados?',
      message:
          'Clientes, serviços e agendamentos serão excluídos definitivamente deste aparelho.',
      confirmLabel: 'Limpar dados',
    );
    if (!confirmed || !context.mounted) return;

    final scope = AppScope.of(context);
    await scope.appointmentRepository.clear();
    await scope.clientRepository.clear();
    await scope.serviceRepository.clear();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todos os dados foram removidos.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sobre',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      Icons.business_center_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 31,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gestão Simples',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Versão 1.0.0',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _AboutCard(
            icon: Icons.school_outlined,
            title: 'Protótipo acadêmico',
            text:
                'Desenvolvido para apoiar pequenos negócios locais na organização de clientes, serviços e atendimentos.',
          ),
          const SizedBox(height: 12),
          const _AboutCard(
            icon: Icons.smartphone_outlined,
            title: 'Privacidade e acesso',
            text:
                'Dados salvos apenas neste aparelho. O aplicativo funciona sem login e sem conexão com a internet.',
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            onPressed: () => _clearData(context),
            icon: const Icon(Icons.delete_sweep_outlined),
            label: const Text('Limpar todos os dados'),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    text,
                    style: TextStyle(
                      height: 1.45,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
