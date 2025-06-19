extension ToggleSet<T> on Set<T> {
  void toggle(T item, bool? state) {
    state == true ? add(item) : remove(item);
  }
}
