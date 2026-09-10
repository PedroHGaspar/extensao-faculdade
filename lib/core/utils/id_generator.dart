import 'dart:math';

abstract final class IdGenerator {
  static final Random _random = Random();

  static String create() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(999999)}';
}
