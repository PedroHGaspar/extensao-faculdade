import 'package:flutter/material.dart';

import '../../data/models/appointment_model.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      AppointmentStatus.completed => (
          'Concluído',
          const Color(0xFF2E8B68),
          Icons.check_circle_outline_rounded,
        ),
      AppointmentStatus.cancelled => (
          'Cancelado',
          const Color(0xFFB85C62),
          Icons.cancel_outlined,
        ),
      _ => (
          'Agendado',
          const Color(0xFF5367D8),
          Icons.schedule_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
