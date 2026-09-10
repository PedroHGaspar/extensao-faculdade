import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/service_model.dart';

class ServiceRepository extends ChangeNotifier {
  ServiceRepository(this._box) {
    _subscription = _box.watch().listen((_) => notifyListeners());
  }

  final Box<ServiceModel> _box;
  late final StreamSubscription<BoxEvent> _subscription;

  List<ServiceModel> get all {
    final items = _box.values.toList();
    items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return items;
  }

  ServiceModel? findById(String id) => _box.get(id);
  Future<void> save(ServiceModel service) => _box.put(service.id, service);
  Future<void> delete(String id) => _box.delete(id);
  Future<void> clear() => _box.clear();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
