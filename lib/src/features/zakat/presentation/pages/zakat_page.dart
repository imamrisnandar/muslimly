import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/presentation/widgets/gradient_page.dart';
import '../../../../core/utils/thousands_input_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/zakat_calculator.dart';

const _kGoldKey = 'zakat_gold_price_per_gram';
const _kHistoryKey = 'zakat_history';

/// Zakat calculator (mal + fitrah). All data stays on the device: nothing here
/// is sent to the server, analytics or crash reporting.
class ZakatPage extends StatefulWidget {
  const ZakatPage({super.key});

  @override
  State<ZakatPage> createState() => _ZakatPageState();
}

class _ZakatPageState extends State<ZakatPage> {
  final DatabaseService _db = getIt<DatabaseService>();
  final _gold = TextEditingController();
  final _wealth = TextEditingController();
  final _debts = TextEditingController();
  final _people = TextEditingController(text: '1');
  final _rate = TextEditingController(
    text: ThousandsInputFormatter.format(
      FitrahConfig.defaultCashPerPerson.toStringAsFixed(0),
    ),
  );
  bool _haul = true;
  List<ZakatRecord> _history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_gold, _wealth, _debts, _people, _rate]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final g = await _db.getSetting(_kGoldKey);
    final h = await _db.getSetting(_kHistoryKey);
    if (!mounted) return;
    setState(() {
      if (g != null && g.isNotEmpty) {
        _gold.text = ThousandsInputFormatter.format(g);
      }
      _history = ZakatRecord.decodeList(h);
    });
  }

  double _num(TextEditingController c) =>
      double.tryParse(ThousandsInputFormatter.digits(c.text)) ?? 0;

  Future<void> _record(String type, double amount, double basis) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    _history = [
      ..._history,
      ZakatRecord(at: DateTime.now(), type: type, amount: amount, basis: basis),
    ];
    await _db.saveSetting(_kHistoryKey, ZakatRecord.encodeList(_history));
    if (!mounted) return;
    setState(() {});
    messenger.showSnackBar(SnackBar(content: Text(l10n.zakatSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: GradientPage(
        title: l10n.zakatTitle,
        child: Column(
          children: [
            TabBar(
              labelColor: AppColors.accent,
              unselectedLabelColor: Colors.white70,
              indicatorColor: AppColors.accent,
              tabs: [
                Tab(text: l10n.zakatTabMal),
                Tab(text: l10n.zakatTabFitrah),
                Tab(text: l10n.zakatTabHistory),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [_malTab(l10n), _fitrahTab(l10n), _historyTab(l10n)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _money(
    TextEditingController c,
    String label, {
    VoidCallback? onChanged,
    String? helper,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        inputFormatters: const [ThousandsInputFormatter()],
        style: const TextStyle(color: Colors.white),
        onChanged: (_) => setState(() => onChanged?.call()),
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          helperMaxLines: 4,
          helperStyle: const TextStyle(color: Colors.white54),
          hintText: '0',
          hintStyle: const TextStyle(color: Colors.white24),
          prefixText: 'Rp ',
          labelStyle: const TextStyle(color: Colors.white60),
          prefixStyle: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  String _rp(double v) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(v);

  Widget _malTab(AppLocalizations l10n) {
    final res = ZakatCalculator.mal(
      ZakatMalInput(
        wealth: _num(_wealth),
        debts: _num(_debts),
        goldPricePerGram: _num(_gold),
        haulReached: _haul,
      ),
    );
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        _money(
          _gold,
          l10n.zakatGoldPrice,
          onChanged: () => _db.saveSetting(
            _kGoldKey,
            ThousandsInputFormatter.digits(_gold.text),
          ),
        ),
        Text(
          l10n.zakatGoldNote,
          style: TextStyle(color: Colors.white38, fontSize: 11.sp),
        ),
        SizedBox(height: 12.h),
        _money(_wealth, l10n.zakatWealth, helper: l10n.zakatWealthHelp),
        _money(_debts, l10n.zakatDebts, helper: l10n.zakatDebtsHelp),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            l10n.zakatHaul,
            style: const TextStyle(color: Colors.white),
          ),
          value: _haul,
          onChanged: (v) => setState(() => _haul = v),
        ),
        SizedBox(height: 8.h),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.zakatNisab(_rp(res.nisab)),
                style: TextStyle(color: Colors.white70, fontSize: 13.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                _num(_gold) <= 0
                    ? l10n.zakatNeedGold
                    : !res.nisabReached
                    ? l10n.zakatBelowNisab
                    : !res.haulReached
                    ? l10n.zakatNoHaul
                    : l10n.zakatDue(_rp(res.zakat)),
                style: TextStyle(
                  color: res.obligatory ? AppColors.accent : Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (res.obligatory)
          TextButton.icon(
            onPressed: () => _record('mal', res.zakat, res.netWealth),
            icon: const Icon(Icons.save_alt),
            label: Text(l10n.zakatSaveResult),
          ),
        SizedBox(height: 12.h),
        Text(
          l10n.zakatDisclaimer,
          style: TextStyle(color: Colors.white38, fontSize: 11.sp),
        ),
      ],
    );
  }

  Widget _fitrahTab(AppLocalizations l10n) {
    final people = int.tryParse(_people.text.trim()) ?? 0;
    final total = ZakatCalculator.fitrah(
      people: people,
      ratePerPerson: _num(_rate),
    );
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        TextField(
          controller: _people,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: Colors.white),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n.zakatPeople,
            labelStyle: const TextStyle(color: Colors.white60),
          ),
        ),
        SizedBox(height: 12.h),
        _money(_rate, l10n.zakatFitrahRate),
        Text(
          l10n.zakatFitrahNote(
            FitrahConfig.riceKgPerPerson.toString(),
            FitrahConfig.sourceNote,
          ),
          style: TextStyle(color: Colors.white38, fontSize: 11.sp),
        ),
        SizedBox(height: 12.h),
        GlassCard(
          child: Text(
            l10n.zakatDue(_rp(total)),
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (total > 0)
          TextButton.icon(
            onPressed: () => _record('fitrah', total, people.toDouble()),
            icon: const Icon(Icons.save_alt),
            label: Text(l10n.zakatSaveResult),
          ),
        SizedBox(height: 12.h),
        Text(
          l10n.zakatDisclaimer,
          style: TextStyle(color: Colors.white38, fontSize: 11.sp),
        ),
      ],
    );
  }

  Widget _historyTab(AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).toString();
    if (_history.isEmpty) {
      return Center(
        child: Text(
          l10n.zakatNoHistory,
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        for (final r in _history.reversed)
          ListTile(
            title: Text(
              _rp(r.amount),
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${r.type == 'mal' ? l10n.zakatTabMal : l10n.zakatTabFitrah}'
              ' · ${DateFormat.yMMMMd(locale).format(r.at)}',
              style: const TextStyle(color: Colors.white60),
            ),
          ),
        SizedBox(height: 8.h),
        Text(
          l10n.zakatLocalNote,
          style: TextStyle(color: Colors.white38, fontSize: 11.sp),
        ),
      ],
    );
  }
}
