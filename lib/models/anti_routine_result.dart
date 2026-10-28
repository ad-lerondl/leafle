enum AntiRoutineStatus {
  recorded,
  noChange,
}

class AntiRoutineResult {
  final AntiRoutineStatus status;
  final int previousValue;
  final int newValue;
  final String message;

  const AntiRoutineResult({
    required this.status,
    required this.previousValue,
    required this.newValue,
    required this.message,
  });

  bool get isNoChange => previousValue == newValue;
}
