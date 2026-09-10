T? firstWhereOrNull<T>(
  Iterable<T> items,
  bool Function(T item) test,
) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}
