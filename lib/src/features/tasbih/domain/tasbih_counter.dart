import 'dart:convert';

/// Pure tasbih counter state. A `target` of 0 means "no target" (free count).
class TasbihCounter {
  final int count; // within the current round
  final int target;
  final int rounds; // completed rounds

  const TasbihCounter({this.count = 0, this.target = 33, this.rounds = 0});

  /// Everything counted in this session across rounds.
  int get total => target > 0 ? rounds * target + count : count;

  /// Result of a tap: the new state and whether it just completed a round.
  ({TasbihCounter state, bool roundCompleted}) increment() {
    final next = count + 1;
    if (target > 0 && next >= target) {
      return (
        state: TasbihCounter(count: 0, target: target, rounds: rounds + 1),
        roundCompleted: true,
      );
    }
    return (
      state: TasbihCounter(count: next, target: target, rounds: rounds),
      roundCompleted: false,
    );
  }

  TasbihCounter undo() {
    if (count > 0) {
      return TasbihCounter(count: count - 1, target: target, rounds: rounds);
    }
    if (target > 0 && rounds > 0) {
      return TasbihCounter(
        count: target - 1,
        target: target,
        rounds: rounds - 1,
      );
    }
    return this;
  }

  /// Changing the target restarts the session (counts under another target
  /// would be meaningless).
  TasbihCounter withTarget(int newTarget) =>
      TasbihCounter(target: newTarget < 0 ? 0 : newTarget);

  TasbihCounter reset() => TasbihCounter(target: target);

  Map<String, Object?> toJson() => {
    'count': count,
    'target': target,
    'rounds': rounds,
  };

  factory TasbihCounter.fromJson(Map<String, dynamic> j) => TasbihCounter(
    count: (j['count'] as num?)?.toInt() ?? 0,
    target: (j['target'] as num?)?.toInt() ?? 33,
    rounds: (j['rounds'] as num?)?.toInt() ?? 0,
  );

  static TasbihCounter decode(String? raw) {
    if (raw == null || raw.isEmpty) return const TasbihCounter();
    try {
      return TasbihCounter.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const TasbihCounter();
    }
  }

  String encode() => jsonEncode(toJson());
}

/// One finished session kept in the local history.
class TasbihSession {
  final DateTime at;
  final int total;
  final int target;

  const TasbihSession({
    required this.at,
    required this.total,
    required this.target,
  });

  Map<String, Object?> toJson() => {
    'at': at.toIso8601String(),
    'total': total,
    'target': target,
  };

  factory TasbihSession.fromJson(Map<String, dynamic> j) => TasbihSession(
    at: DateTime.parse(j['at'] as String),
    total: (j['total'] as num).toInt(),
    target: (j['target'] as num).toInt(),
  );

  /// History is capped so the settings row stays small.
  static List<TasbihSession> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => TasbihSession.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static String encodeList(List<TasbihSession> l, {int max = 30}) {
    final trimmed = l.length > max ? l.sublist(l.length - max) : l;
    return jsonEncode(trimmed.map((e) => e.toJson()).toList());
  }
}
