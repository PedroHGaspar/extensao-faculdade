import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../core/utils/formatters.dart';
import '../models/appointment_model.dart';

class AppointmentRepository extends ChangeNotifier {
  AppointmentRepository(this._box) {
    _subscription = _box.watch().listen((_) => notifyListeners());
  }

  final Box<AppointmentModel> _box;
  late final StreamSubscription<BoxEvent> _subscription;

  List<AppointmentModel> get all {
    final items = _box.values.toList();
    items.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return items;
  }

  List<AppointmentModel> onDate(DateTime date) =>
      all.where((item) => AppFormatters.isSameDay(item.dateTime, date)).toList();

  List<AppointmentModel> get upcoming => all
      .where(
        (item) =>
            item.status == AppointmentStatus.scheduled &&
            item.dateTime.isAfter(DateTime.now()),
      )
      .toList();

  AppointmentModel? findById(String id) => _box.get(id);
  Future<void> save(AppointmentModel appointment) =>
      _box.put(appointment.id, appointment);
  Future<void> delete(String id) => _box.delete(id);
  Future<void> clear() => _box.clear();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
