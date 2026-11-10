import 'dart:convert';

/// Nisab standard. The default is 85 g of 24-carat gold (decision recorded in
/// ROADMAP_FITUR_BARU.md). More standards (e.g. BAZNAS' 14-carat reference for
/// income zakat) can be added later without touching the calculation.
class NisabStandard {
  final String id;
  final double goldGrams;
  const NisabStandard(this.id, this.goldGrams);

  static const gold24 = NisabStandard('gold24', 85);
}

const double kZakatRate = 0.025;

class ZakatMalInput {
  /// All zakatable wealth held for a full year (cash, savings, gold value,
  /// trade goods, receivables expected to be paid).
  final double wealth;

  /// Debts due now that the user must pay.
  final double debts;

  /// Gold price per gram (IDR), entered by the user or taken from config.
  final double goldPricePerGram;
  final NisabStandard standard;

  /// Whether the wealth has been held for one lunar year (haul).
  final bool haulReached;

  const ZakatMalInput({
    required this.wealth,
    this.debts = 0,
    required this.goldPricePerGram,
    this.standard = NisabStandard.gold24,
    this.haulReached = true,
  });
}

class ZakatMalResult {
  final double nisab;
  final double netWealth;
  final bool nisabReached;
  final bool haulReached;
  final double zakat;

  const ZakatMalResult({
    required this.nisab,
    required this.netWealth,
    required this.nisabReached,
    required this.haulReached,
    required this.zakat,
  });

  bool get obligatory => nisabReached && haulReached;
}

class ZakatCalculator {
  static double nisab(double goldPricePerGram, NisabStandard s) =>
      goldPricePerGram * s.goldGrams;

  static ZakatMalResult mal(ZakatMalInput i) {
    final nis = nisab(i.goldPricePerGram, i.standard);
    final net = (i.wealth - i.debts).clamp(0, double.infinity).toDouble();
    final reached = i.goldPricePerGram > 0 && net >= nis;
    final due = reached && i.haulReached;
    return ZakatMalResult(
      nisab: nis,
      netWealth: net,
      nisabReached: reached,
      haulReached: i.haulReached,
      zakat: due ? net * kZakatRate : 0,
    );
  }

  /// Zakat fitrah for [people] at a per-person cash [rate].
  static double fitrah({required int people, required double ratePerPerson}) =>
      people <= 0 ? 0 : people * ratePerPerson;
}

/// Fitrah configuration. Values are provisional and MUST be confirmed against
/// the official BAZNAS decree before release (see ROADMAP §4); regions differ.
class FitrahConfig {
  static const double riceKgPerPerson = 2.5;
  static const double defaultCashPerPerson = 50000;
  static const String sourceNote = 'BAZNAS 2026 (belum diverifikasi)';
}

class ZakatRecord {
  final DateTime at;
  final String type; // 'mal' | 'fitrah'
  final double amount;
  final double basis; // net wealth (mal) or people count (fitrah)

  const ZakatRecord({
    required this.at,
    required this.type,
    required this.amount,
    required this.basis,
  });

  Map<String, Object?> toJson() => {
    'at': at.toIso8601String(),
    'type': type,
    'amount': amount,
    'basis': basis,
  };

  factory ZakatRecord.fromJson(Map<String, dynamic> j) => ZakatRecord(
    at: DateTime.parse(j['at'] as String),
    type: j['type'] as String,
    amount: (j['amount'] as num).toDouble(),
    basis: (j['basis'] as num).toDouble(),
  );

  static List<ZakatRecord> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => ZakatRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static String encodeList(List<ZakatRecord> l, {int max = 50}) {
    final t = l.length > max ? l.sublist(l.length - max) : l;
    return jsonEncode(t.map((e) => e.toJson()).toList());
  }
}
