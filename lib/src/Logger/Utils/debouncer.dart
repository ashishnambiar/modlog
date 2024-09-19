import 'dart:async';
import 'dart:ui';

class Debouncer {
  Debouncer({
    this.debounceInterval = const Duration(seconds: 1),
  });
  final Duration debounceInterval;

  Timer? timer;

  void dispose() {
    timer?.cancel();
    timer = null;
  }

  void call(
    VoidCallback callback, {
    VoidCallback? onInterrupted,
  }) {
    if (timer?.isActive ?? false) {
      onInterrupted?.call();
      dispose();
    }
    timer = Timer(debounceInterval, callback);
  }
}
