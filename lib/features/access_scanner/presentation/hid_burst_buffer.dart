import 'package:flutter/services.dart';

/// HID gun burst: inter-character gap &lt; 50ms, terminated by Enter/Tab.
class HidBurstBuffer {
  HidBurstBuffer({
    this.maxGap = const Duration(milliseconds: 50),
    this.onBurst,
  });

  final Duration maxGap;
  final void Function(String payload)? onBurst;

  final StringBuffer _buffer = StringBuffer();
  DateTime? _last;

  bool handle(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.tab) {
      final payload = _buffer.toString();
      _buffer.clear();
      _last = null;
      if (payload.isEmpty) return false;
      onBurst?.call(payload);
      return true;
    }
    final char = event.character;
    if (char == null || char.isEmpty) return false;
    final now = DateTime.now();
    if (_last != null && now.difference(_last!) > maxGap) {
      _buffer.clear();
    }
    _buffer.write(char);
    _last = now;
    return true;
  }

  void reset() {
    _buffer.clear();
    _last = null;
  }
}
