import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../domain/entities/class_session.dart';
import '../cubit/class_sessions_cubit.dart';

/// Inline Add New Session form — Stitch Class Manager bottom card.
class ClassSessionFormPanel extends StatefulWidget {
  const ClassSessionFormPanel({
    super.key,
    required this.canWrite,
    required this.busy,
    required this.coaches,
    this.editing,
    this.draftStartsAt,
    this.draftEndsAt,
  });

  final bool canWrite;
  final bool busy;
  final List<ClassCoachOption> coaches;
  final ClassSession? editing;
  final DateTime? draftStartsAt;
  final DateTime? draftEndsAt;

  @override
  State<ClassSessionFormPanel> createState() => _ClassSessionFormPanelState();
}

class _ClassSessionFormPanelState extends State<ClassSessionFormPanel> {
  late final TextEditingController _titleController;
  late final TextEditingController _capacityController;
  String? _coachId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.editing?.title ?? '');
    _capacityController = TextEditingController(
      text: '${widget.editing?.capacity ?? 25}',
    );
    _coachId = widget.editing?.coachEmployeeId;
  }

  @override
  void didUpdateWidget(covariant ClassSessionFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editing?.id != oldWidget.editing?.id) {
      _titleController.text = widget.editing?.title ?? '';
      _capacityController.text = '${widget.editing?.capacity ?? 25}';
      _coachId = widget.editing?.coachEmployeeId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final enabled = widget.canWrite && !widget.busy;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: KineticTokens.zincGray.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: KineticTokens.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.event_note,
                    color: KineticTokens.primaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (widget.editing == null
                                ? 'classes.form.add_title'
                                : 'classes.form.edit_title')
                            .tr()
                            .toUpperCase(),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: KineticTokens.pureWhite,
                        ),
                      ),
                      Text(
                        'classes.form.subtitle'.tr().toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          color: const Color(0xFFC4C9AC),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.draftStartsAt != null)
                  Text(
                    DateFormat(
                      'EEE HH:mm',
                      context.locale.toString(),
                    ).format(widget.draftStartsAt!),
                    style: textTheme.labelSmall?.copyWith(
                      color: KineticTokens.electricLime,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 720;
                final fields = [
                  _LabeledField(
                    label: 'classes.form.class_type'.tr(),
                    child: TextField(
                      controller: _titleController,
                      enabled: enabled,
                      style: const TextStyle(color: KineticTokens.pureWhite),
                      decoration: _inputDecoration(
                        hint: 'classes.form.class_type_hint'.tr(),
                      ),
                    ),
                  ),
                  _LabeledField(
                    label: 'classes.form.instructor'.tr(),
                    child: DropdownButtonFormField<String?>(
                      // ignore: deprecated_member_use
                      value: _coachId,
                      dropdownColor: KineticTokens.surfaceContainerHigh,
                      style: const TextStyle(color: KineticTokens.pureWhite),
                      decoration: _inputDecoration(
                        hint: 'classes.form.instructor_hint'.tr(),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text('classes.form.instructor_hint'.tr()),
                        ),
                        for (final c in widget.coaches)
                          DropdownMenuItem<String?>(
                            value: c.id,
                            child: Text(c.name),
                          ),
                      ],
                      onChanged: enabled
                          ? (v) => setState(() => _coachId = v)
                          : null,
                    ),
                  ),
                  _LabeledField(
                    label: 'classes.form.max_capacity'.tr(),
                    child: TextField(
                      controller: _capacityController,
                      enabled: enabled,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: const TextStyle(color: KineticTokens.pureWhite),
                      decoration: _inputDecoration(hint: '25'),
                    ),
                  ),
                ];

                if (!wide) {
                  return Column(
                    children: [
                      for (final f in fields) ...[
                        f,
                        const SizedBox(height: 16),
                      ],
                      _CreateButton(
                        enabled: enabled,
                        busy: widget.busy,
                        onPressed: _submit,
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < fields.length; i++) ...[
                      Expanded(child: fields[i]),
                      const SizedBox(width: 16),
                    ],
                    _CreateButton(
                      enabled: enabled,
                      busy: widget.busy,
                      onPressed: _submit,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: KineticTokens.zincGray.withValues(alpha: 0.8),
      ),
      filled: true,
      fillColor: KineticTokens.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: KineticTokens.zincGray.withValues(alpha: 0.25),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: KineticTokens.zincGray.withValues(alpha: 0.25),
        ),
      ),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
    );
  }

  void _submit() {
    final capacity = int.tryParse(_capacityController.text.trim()) ?? 0;
    context.read<ClassSessionsCubit>().createOrUpdate(
      title: _titleController.text,
      capacity: capacity,
      coachEmployeeId: _coachId,
      startsAt: widget.editing?.startsAt ?? widget.draftStartsAt,
      endsAt: widget.editing?.endsAt ?? widget.draftEndsAt,
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: Color(0xFFC4C9AC),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({
    required this.enabled,
    required this.busy,
    required this.onPressed,
  });

  final bool enabled;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: KineticTokens.pureWhite,
          foregroundColor: Colors.black,
          disabledBackgroundColor: KineticTokens.surfaceContainerHigh,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                'classes.form.create'.tr().toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
      ),
    );
  }
}
