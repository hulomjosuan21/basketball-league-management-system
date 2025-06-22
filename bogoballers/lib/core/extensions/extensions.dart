extension ToggleSet<T> on Set<T> {
  void toggle(T item, bool? state) {
    state == true ? add(item) : remove(item);
  }
}

extension NullableStringFallback on String? {
  String orNoData() => this?.trim().isNotEmpty == true ? this! : 'No data';
}

String orNoData = 'No data';
