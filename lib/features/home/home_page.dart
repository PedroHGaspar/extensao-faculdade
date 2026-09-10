import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/iterable_utils.dart';
import '../../data/models/appointment_model.dart';
import '../../shared/widgets/appointment_card.dart';
import '../../shared/widgets/info_card.dart';
import '../appointments/appointment_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.onNewAppointment, super.key});

  final VoidCallback onNewAppointment;

  void _openDetails(BuildContext context, AppointmentModel appointment) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AppointmentDetailPage(appointmentId: appointment.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final listenable = Listenable.merge([
      scope.clientRepository,
      scope.serviceRepository,
      scope.appointmentRepository,
    ]);

    return Scaffold(
      body: AnimatedBuilder(
        animation: listenable,
        builder: (context, _) {
          final clientsCount = scope.clientRepository.all.length;
          final servicesCount = scope.serviceRepository.all.length;
          final todayCount =
              scope.appointmentRepository.onDate(DateTime.now()).length;
          final upcoming = scope.appointmentRepository.upcoming;
          final next = firstWhereOrNull(upcoming, (_) => true);
          final shortList = upcoming.take(3).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gestão Simples',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Seu negócio organizado, de um jeito fácil.',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 22),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.18,
                        children: [
                          InfoCard(
                            icon: Icons.people_rounded,
                            label: 'Clientes',
                            value: '$clientsCount',
                            color: AppTheme.primary,
                          ),
                          InfoCard(
                            icon: Icons.design_services_rounded,
                            label: 'Serviços',
                            value: '$servicesCount',
                            color: AppTheme.secondary,
                          ),
                          InfoCard(
                            icon: Icons.today_rounded,
                            label: 'Atendimentos hoje',
                            value: '$todayCount',
                            color: const Color(0xFFE08A45),
                          ),
                          InfoCard(
                            icon: Icons.upcoming_rounded,
                            label: 'Próximo horário',
                            value: next == null
                                ? '--:--'
                                : AppFormatters.time(next.dateTime),
                            color: const Color(0xFF8A62C7),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Card(
                        color: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: InkWell(
                          onTap: onNewAppointment,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Novo agendamento',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        'Organize seu próximo atendimento',
                                        style: TextStyle(
                                          color: Color(0xFFE7E9FF),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        'Próximos agendamentos',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 12),
                      if (shortList.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.event_available_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Text(
                                    'Sua agenda está livre. Crie um agendamento quando precisar.',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...shortList.map(
                          (appointment) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AppointmentCard(
                              appointment: appointment,
                              onTap: () =>
                                  _openDetails(context, appointment),
                            ),
                          ),
                        ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
