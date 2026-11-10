import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslimly/src/features/khatam/domain/khatam_plan.dart';
import 'package:muslimly/src/features/tasbih/domain/dhikr_content.dart';
import 'package:muslimly/src/features/tasbih/domain/tasbih_counter.dart';
import 'package:muslimly/src/features/zakat/domain/zakat_calculator.dart';

void main() {
  group('TasbihCounter', () {
    test('completes a round at the target and restarts', () {
      var c = const TasbihCounter(target: 3);
      var r = c.increment();
      c = r.state;
      expect(r.roundCompleted, isFalse);
      c = c.increment().state;
      r = c.increment();
      expect(r.roundCompleted, isTrue);
      expect(r.state.count, 0);
      expect(r.state.rounds, 1);
      expect(r.state.total, 3);
    });

    test('undo steps back across a round boundary', () {
      final c = const TasbihCounter(count: 0, target: 33, rounds: 2);
      final u = c.undo();
      expect(u.count, 32);
      expect(u.rounds, 1);
      expect(const TasbihCounter(target: 33).undo().count, 0);
    });

    test('free mode never completes a round', () {
      var c = const TasbihCounter(target: 0);
      for (var i = 0; i < 500; i++) {
        final r = c.increment();
        expect(r.roundCompleted, isFalse);
        c = r.state;
      }
      expect(c.total, 500);
    });

    test('changing the target restarts the session', () {
      final c = const TasbihCounter(count: 10, target: 33, rounds: 1);
      expect(c.withTarget(99).total, 0);
      expect(c.withTarget(-5).target, 0);
    });

    test('json round trip and bad data fallback', () {
      const c = TasbihCounter(count: 5, target: 99, rounds: 2);
      expect(TasbihCounter.decode(c.encode()).total, c.total);
      expect(TasbihCounter.decode('not json').target, 33);
      expect(TasbihCounter.decode(null).count, 0);
    });

    test('session history keeps only the newest entries', () {
      final l = List.generate(
        40,
        (i) => TasbihSession(
          at: DateTime(2026, 1, 1 + i % 20),
          total: i,
          target: 33,
        ),
      );
      final back = TasbihSession.decodeList(TasbihSession.encodeList(l));
      expect(back.length, 30);
      expect(back.last.total, 39);
    });
  });

  group('bundled content', () {
    test('Asmaul Husna has 99 sequentially numbered, complete entries', () {
      final j = jsonDecode(
        File('assets/quran/json/asmaul_husna.json').readAsStringSync(),
      );
      final names = (j['names'] as List)
          .map((e) => AsmaulHusnaName.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(names.length, 99);
      for (var i = 0; i < 99; i++) {
        expect(names[i].number, i + 1);
        expect(names[i].arabic.trim(), isNotEmpty);
        expect(names[i].transliteration.trim(), isNotEmpty);
        expect(names[i].meaningId.trim(), isNotEmpty);
        expect(names[i].meaningEn.trim(), isNotEmpty);
      }
    });

    test('hadiths are complete, unique, and rotate daily', () {
      final j = jsonDecode(
        File('assets/quran/json/hadith_daily.json').readAsStringSync(),
      );
      final all = (j['hadiths'] as List)
          .map((e) => Hadith.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(all.map((h) => h.id).toSet().length, all.length);
      for (final h in all) {
        expect(h.arabic, isNotEmpty);
        expect(h.textId, isNotEmpty);
        expect(h.textEn, isNotEmpty);
        expect(h.source, isNotEmpty);
      }
      final d = DateTime(2026, 11, 10);
      expect(hadithOfDay(all, d).id, hadithOfDay(all, d).id);
      expect(
        hadithOfDay(all, d).id ==
            hadithOfDay(all, d.add(const Duration(days: 1))).id,
        isFalse,
      );
    });
  });

  group('KhatamCalculator', () {
    final plan = KhatamPlan(
      start: DateTime(2027, 2, 1),
      target: DateTime(2027, 3, 2), // 30 days inclusive
    );

    test('one khatam in 30 days is about 21 pages a day', () {
      final p = KhatamCalculator.compute(
        plan: plan,
        pagesRead: 0,
        today: DateTime(2027, 2, 1),
      );
      expect(p.remainingReadingDays, 30);
      expect(p.dailyTarget, 21); // ceil(604/30)
      expect(p.pagesPerPrayer, 5);
      expect(p.behindBy, 0);
    });

    test('behind schedule raises the daily target and reports the gap', () {
      final p = KhatamCalculator.compute(
        plan: plan,
        pagesRead: 100,
        today: DateTime(2027, 2, 11), // 10 days elapsed, expected ~201
      );
      expect(p.behindBy, 101);
      expect(p.remainingReadingDays, 20);
      expect(p.dailyTarget, 26); // ceil(504/20)
    });

    test('ahead of schedule is not "behind"', () {
      final p = KhatamCalculator.compute(
        plan: plan,
        pagesRead: 400,
        today: DateTime(2027, 2, 11),
      );
      expect(p.behindBy, 0);
    });

    test('off weekdays are excluded from the reading days', () {
      final off = KhatamPlan(
        start: DateTime(2027, 2, 1), // a Monday
        target: DateTime(2027, 2, 7),
        offWeekdays: {DateTime.friday},
      );
      expect(
        KhatamCalculator.readingDays(off.start, off.target, off.offWeekdays),
        6,
      );
    });

    test('finished, not started and overdue states', () {
      expect(
        KhatamCalculator.compute(
          plan: plan,
          pagesRead: 9999,
          today: DateTime(2027, 2, 5),
        ).finished,
        isTrue,
      );
      final early = KhatamCalculator.compute(
        plan: plan,
        pagesRead: 0,
        today: DateTime(2027, 1, 20),
      );
      expect(early.notStarted, isTrue);
      expect(early.remainingReadingDays, 30);
      final late = KhatamCalculator.compute(
        plan: plan,
        pagesRead: 500,
        today: DateTime(2027, 3, 10),
      );
      expect(late.overdue, isTrue);
      expect(late.dailyTarget, 104); // everything left, no days remain
    });

    test('multiple khatams scale the total', () {
      final p = KhatamCalculator.compute(
        plan: KhatamPlan(
          start: plan.start,
          target: plan.target,
          khatamCount: 2,
        ),
        pagesRead: 0,
        today: plan.start,
      );
      expect(p.totalPages, 1208);
    });

    test('next Ramadan falls in Feb 2027 and honours the day shift', () {
      final r = KhatamCalculator.nextRamadan(DateTime(2026, 11, 10));
      expect(r.start.year, 2027);
      expect(r.start.month, anyOf(1, 2));
      expect(r.end.difference(r.start).inDays, 28);
      final shifted = KhatamCalculator.nextRamadan(
        DateTime(2026, 11, 10),
        adjustDays: 1,
      );
      expect(shifted.start.difference(r.start).inDays, 1);
    });

    test('plan json round trip', () {
      final p = KhatamPlan(
        start: DateTime(2027, 2, 1),
        target: DateTime(2027, 3, 2),
        khatamCount: 2,
        offWeekdays: {5},
      );
      final q = KhatamPlan.decode(p.encode())!;
      expect(q.khatamCount, 2);
      expect(q.offWeekdays, {5});
      expect(KhatamPlan.decode('garbage'), isNull);
      expect(KhatamPlan.decode(''), isNull);
    });
  });

  group('ZakatCalculator', () {
    test('nisab is 85 g of gold', () {
      expect(ZakatCalculator.nisab(1500000, NisabStandard.gold24), 127500000);
    });

    test('mal: at nisab with haul owes 2.5%', () {
      final r = ZakatCalculator.mal(
        const ZakatMalInput(wealth: 127500000, goldPricePerGram: 1500000),
      );
      expect(r.obligatory, isTrue);
      expect(r.zakat, closeTo(3187500, 0.01));
    });

    test('mal: just below nisab owes nothing', () {
      final r = ZakatCalculator.mal(
        const ZakatMalInput(wealth: 127499999, goldPricePerGram: 1500000),
      );
      expect(r.nisabReached, isFalse);
      expect(r.zakat, 0);
    });

    test('mal: debts reduce the base, no haul means no zakat yet', () {
      final r = ZakatCalculator.mal(
        const ZakatMalInput(
          wealth: 150000000,
          debts: 30000000,
          goldPricePerGram: 1500000,
        ),
      );
      expect(r.netWealth, 120000000);
      expect(r.nisabReached, isFalse);
      final noHaul = ZakatCalculator.mal(
        const ZakatMalInput(
          wealth: 200000000,
          goldPricePerGram: 1500000,
          haulReached: false,
        ),
      );
      expect(noHaul.nisabReached, isTrue);
      expect(noHaul.zakat, 0);
    });

    test('mal: missing gold price never reports obligation', () {
      final r = ZakatCalculator.mal(
        const ZakatMalInput(wealth: 999999999, goldPricePerGram: 0),
      );
      expect(r.obligatory, isFalse);
      expect(r.zakat, 0);
    });

    test('debts larger than wealth clamp to zero', () {
      final r = ZakatCalculator.mal(
        const ZakatMalInput(wealth: 10, debts: 50, goldPricePerGram: 1500000),
      );
      expect(r.netWealth, 0);
    });

    test('fitrah multiplies per person; non-positive people is zero', () {
      expect(ZakatCalculator.fitrah(people: 4, ratePerPerson: 50000), 200000);
      expect(ZakatCalculator.fitrah(people: 0, ratePerPerson: 50000), 0);
    });

    test('record history json round trip and cap', () {
      final l = List.generate(
        60,
        (i) => ZakatRecord(
          at: DateTime(2027, 1, 1),
          type: 'mal',
          amount: i.toDouble(),
          basis: 1,
        ),
      );
      final back = ZakatRecord.decodeList(ZakatRecord.encodeList(l));
      expect(back.length, 50);
      expect(back.last.amount, 59);
      expect(ZakatRecord.decodeList('bad'), isEmpty);
    });
  });
}
