import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/client_model.dart';

class ClientRepository extends ChangeNotifier {
  ClientRepository(this._box) {
    _subscription = _box.watch().listen((_) => notifyListeners());
  }

  final Box<ClientModel> _box;
  late final StreamSubscription<BoxEvent> _subscription;

  List<ClientModel> get all {
    final items = _box.values.toList();
    items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return items;
  }

  ClientModel? findById(String id) => _box.get(id);
  Future<void> save(ClientModel client) => _box.put(client.id, client);
  Future<void> delete(String id) => _box.delete(id);
  Future<void> clear() => _box.clear();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
