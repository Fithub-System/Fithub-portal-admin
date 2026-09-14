import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/theme/kinetic_tokens.dart';
import '../data/accounting_export_remote.dart';

/// FEAT-89 CSV export + FEAT-90 invoice lookup (Reports rail).
class AccountingReportsPanel extends StatefulWidget {
  const AccountingReportsPanel({super.key, required this.canAdmin});

  final bool canAdmin;

  @override
  State<AccountingReportsPanel> createState() => _AccountingReportsPanelState();
}

class _AccountingReportsPanelState extends State<AccountingReportsPanel> {
  final _remote = AccountingExportRemote();
  final _orderController = TextEditingController();
  String _dataset = 'payment_orders';
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().toUtc().subtract(const Duration(days: 30)),
    end: DateTime.now().toUtc(),
  );
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    if (!widget.canAdmin) {
      setState(() => _message = 'reports.accounting.admin_only'.tr());
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final csv = await _remote.exportCsv(
        dataset: _dataset,
        from: _range.start,
        to: _range.end,
      );
      await Clipboard.setData(ClipboardData(text: csv));
      final lines = csv.trim().split('\n').length;
      setState(() {
        _message = 'reports.accounting.export_ok'.tr(
          namedArgs: {'rows': '$lines'},
        );
      });
    } catch (_) {
      setState(() => _message = 'reports.accounting.export_fail'.tr());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _invoice() async {
    if (!widget.canAdmin) {
      setState(() => _message = 'reports.accounting.admin_only'.tr());
      return;
    }
    final id = _orderController.text.trim();
    if (id.isEmpty) {
      setState(() => _message = 'reports.invoice.order_required'.tr());
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final inv = await _remote.getInvoice(id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: KineticTokens.surfaceContainerLow,
          title: Text('reports.invoice.title'.tr()),
          content: SingleChildScrollView(
            child: Text(
              inv.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
              style: const TextStyle(
                color: KineticTokens.onSurface,
                fontFamily: 'Lexend',
                fontSize: 12,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('reports.invoice.close'.tr()),
            ),
          ],
        ),
      );
    } catch (_) {
      setState(() => _message = 'reports.invoice.fail'.tr());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'reports.accounting.title'.tr(),
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: KineticTokens.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'reports.accounting.subtitle'.tr(),
          style: const TextStyle(color: KineticTokens.zincGray, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final d in const [
              'payment_orders',
              'coach_ledger',
              'athlete_ledger',
            ])
              ChoiceChip(
                label: Text('reports.accounting.dataset.$d'.tr()),
                selected: _dataset == d,
                onSelected: _busy ? null : (_) => setState(() => _dataset = d),
              ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _busy
              ? null
              : () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                    initialDateRange: DateTimeRange(
                      start: _range.start.toLocal(),
                      end: _range.end.toLocal(),
                    ),
                  );
                  if (picked != null) {
                    setState(() => _range = picked);
                  }
                },
          child: Text(
            'reports.accounting.range'.tr(
              namedArgs: {
                'from': DateFormat.yMMMd().format(_range.start.toLocal()),
                'to': DateFormat.yMMMd().format(_range.end.toLocal()),
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _busy ? null : _export,
          style: FilledButton.styleFrom(
            backgroundColor: KineticTokens.electricLime,
            foregroundColor: KineticTokens.deepCharcoal,
          ),
          child: Text('reports.accounting.export_csv'.tr()),
        ),
        const SizedBox(height: 28),
        Text(
          'reports.invoice.section'.tr(),
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: KineticTokens.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _orderController,
          decoration: InputDecoration(
            labelText: 'reports.invoice.order_id'.tr(),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _busy ? null : _invoice,
          child: Text('reports.invoice.fetch'.tr()),
        ),
        if (_busy) ...[
          const SizedBox(height: 16),
          const LinearProgressIndicator(color: KineticTokens.electricLime),
        ],
        if (_message != null) ...[
          const SizedBox(height: 12),
          Text(
            _message!,
            style: const TextStyle(color: KineticTokens.zincGray, fontSize: 13),
          ),
        ],
      ],
    );
  }
}
