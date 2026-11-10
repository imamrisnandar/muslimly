import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/presentation/widgets/gradient_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/tasbih_counter.dart';

const _kStateKey = 'tasbih_state';
const _kHistoryKey = 'tasbih_history';

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  final DatabaseService _db = getIt<DatabaseService>();
  TasbihCounter _c = const TasbihCounter();
  List<TasbihSession> _history = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await _db.getSetting(_kStateKey);
    final h = await _db.getSetting(_kHistoryKey);
    if (!mounted) return;
    setState(() {
      _c = TasbihCounter.decode(s);
      _history = TasbihSession.decodeList(h);
      _loaded = true;
    });
  }

  void _persist() => _db.saveSetting(_kStateKey, _c.encode());

  void _tap() {
    final r = _c.increment();
    setState(() => _c = r.state);
    if (r.roundCompleted) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    _persist();
  }

  void _undo() {
    setState(() => _c = _c.undo());
    _persist();
  }

  Future<void> _saveSession() async {
    final l10n = AppLocalizations.of(context)!;
    if (_c.total == 0) return;
    final messenger = ScaffoldMessenger.of(context);
    _history = [
      ..._history,
      TasbihSession(at: DateTime.now(), total: _c.total, target: _c.target),
    ];
    await _db.saveSetting(_kHistoryKey, TasbihSession.encodeList(_history));
    setState(() => _c = _c.reset());
    _persist();
    messenger.showSnackBar(SnackBar(content: Text(l10n.tasbihSaved)));
  }

  Future<void> _pickCustom() async {
    final l10n = AppLocalizations.of(context)!;
    final ctl = TextEditingController();
    final v = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.tasbihCustom),
        content: TextField(
          controller: ctl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(hintText: l10n.tasbihCustomHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.toolsCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(ctl.text)),
            child: Text(l10n.toolsSave),
          ),
        ],
      ),
    );
    if (v != null && v > 0 && v <= 100000) _setTarget(v);
  }

  void _setTarget(int t) {
    setState(() => _c = _c.withTarget(t));
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GradientPage(
      title: l10n.tasbihTitle,
      actions: [
        IconButton(
          tooltip: l10n.tasbihHistory,
          icon: const Icon(Icons.history, color: Colors.white),
          onPressed: _showHistory,
        ),
      ],
      child: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  Wrap(
                    spacing: 8.w,
                    children: [
                      for (final t in const [33, 99, 100])
                        ChoiceChip(
                          label: Text('$t'),
                          selected: _c.target == t,
                          onSelected: (_) => _setTarget(t),
                        ),
                      ChoiceChip(
                        label: Text(l10n.tasbihFree),
                        selected: _c.target == 0,
                        onSelected: (_) => _setTarget(0),
                      ),
                      ChoiceChip(
                        label: Text(
                          ![0, 33, 99, 100].contains(_c.target)
                              ? '${_c.target}'
                              : l10n.tasbihCustom,
                        ),
                        selected: ![0, 33, 99, 100].contains(_c.target),
                        onSelected: (_) => _pickCustom(),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Semantics(
                    button: true,
                    label: l10n.tasbihTitle,
                    child: GestureDetector(
                      onTap: _tap,
                      child: Container(
                        width: 240.r,
                        height: 240.r,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent.withValues(alpha: 0.12),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.6),
                            width: 3,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_c.count}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 72.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_c.target > 0)
                              Text(
                                '/ ${_c.target}',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 18.sp,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    [
                      if (_c.target > 0) l10n.tasbihRounds(_c.rounds),
                      l10n.tasbihTotal(_c.total),
                    ].join('  ·  '),
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _undo,
                        icon: const Icon(Icons.undo),
                        label: Text(l10n.tasbihUndo),
                      ),
                      SizedBox(width: 12.w),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _c = _c.reset());
                          _persist();
                        },
                        icon: const Icon(Icons.restart_alt),
                        label: Text(l10n.tasbihReset),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      foregroundColor: Colors.black87,
                    ),
                    onPressed: _c.total == 0 ? null : _saveSession,
                    icon: const Icon(Icons.check),
                    label: Text(l10n.tasbihSaveSession),
                  ),
                ],
              ),
            ),
    );
  }

  void _showHistory() {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: _history.isEmpty
            ? Padding(
                padding: EdgeInsets.all(24.r),
                child: Text(l10n.tasbihNoHistory),
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final s in _history.reversed)
                    ListTile(
                      title: Text(l10n.tasbihTotal(s.total)),
                      subtitle: Text(
                        DateFormat.yMMMMd(locale).add_Hm().format(s.at),
                      ),
                      trailing: s.target > 0 ? Text('× ${s.target}') : null,
                    ),
                ],
              ),
      ),
    );
  }
}
