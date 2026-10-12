String _two(int n) => n.toString().padLeft(2, '0');

/// 18:44
String formatTime(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';

/// 11/10 · 18:44
String formatDateTime(DateTime t) =>
    '${_two(t.day)}/${_two(t.month)} · ${formatTime(t)}';
