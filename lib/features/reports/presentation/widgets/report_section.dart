import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_notify.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/services/auth_service.dart';
import '../../models/report.dart';
import '../../models/report_condition.dart';
import '../../services/report_service.dart';

/// Condition reporting + history for a single point. Drop into a details sheet
/// with the point's id.
class ReportSection extends ConsumerStatefulWidget {
  const ReportSection({
    super.key,
    required this.pointId,
    this.horizontalInset = 0,
  });

  final int pointId;

  /// Padding re-applied to everything except the chip row, so the chips can
  /// scroll edge-to-edge while text/fields stay aligned.
  final double horizontalInset;

  @override
  ConsumerState<ReportSection> createState() => _ReportSectionState();
}

class _ReportSectionState extends ConsumerState<ReportSection> {
  ReportCondition? _selected;
  final _noteController = TextEditingController();
  bool _submitting = false;
  bool _historyExpanded = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final condition = _selected;
    if (condition == null || _submitting) return;
    final l10n = context.l10n;

    // Reporting requires an account — send guests to phone login.
    if (!ref.read(isSignedInProvider)) {
      final signedIn = await context.pushNamed<bool>(LoginPage.name);
      if (signedIn != true || !mounted) return;
    }

    setState(() => _submitting = true);
    try {
      await ref
          .read(reportServiceProvider)
          .submit(
            pointId: widget.pointId,
            condition: condition.value,
            description: _noteController.text,
          );
      ref.invalidate(reportsForPointProvider(widget.pointId));
      if (!mounted) return;
      setState(() {
        _selected = null;
        _submitting = false;
        _historyExpanded = true;
      });
      _noteController.clear();
      AppNotify.success(l10n.reportThanks);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      AppNotify.error(e is PostgrestException ? e.message : l10n.reportFailed);
    }
  }

  void _toggle(ReportCondition c) =>
      setState(() => _selected = _selected == c ? null : c);

  /// Lays the conditions out in 2 rows that scroll horizontally, with even
  /// gaps. Each column holds two conditions sized to the same width.
  List<Widget> _conditionColumns() {
    final all = ReportConditionX.all;
    final columns = <Widget>[];
    for (var i = 0; i < all.length; i += 2) {
      final top = all[i];
      final bottom = i + 1 < all.length ? all[i + 1] : null;
      final isLastColumn = i + 2 >= all.length;
      columns.add(
        Padding(
          padding: EdgeInsets.only(right: isLastColumn ? 0 : 10),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ConditionChip(
                  condition: top,
                  selected: _selected == top,
                  onTap: () => _toggle(top),
                ),
                if (bottom != null) ...[
                  const SizedBox(height: 10),
                  _ConditionChip(
                    condition: bottom,
                    selected: _selected == bottom,
                    onTap: () => _toggle(bottom),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
    return columns;
  }

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(reportsForPointProvider(widget.pointId));

    final inset = EdgeInsets.symmetric(horizontal: widget.horizontalInset);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: inset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 48, color: AppColors.border),
              Text(context.l10n.whatState, style: AppTextStyles.subtitle),
              const SizedBox(height: 4),
              Text(
                context.l10n.chooseStateHint,
                style: AppTextStyles.bodyMuted.copyWith(fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Full-bleed: chips scroll to the screen edge, with a leading inset so
        // the first column lines up with the text.
        SizedBox(
          height: 120,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: inset,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _conditionColumns(),
            ),
          ),
        ),
        Padding(
          padding: inset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              _NoWaterButton(onTap: () {}),
              if (_selected != null) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: _noteController,
                  style: AppTextStyles.body,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: context.l10n.detailsOptional,
                    hintStyle: AppTextStyles.bodyMuted,
                    filled: true,
                    fillColor: AppColors.surfaceMuted,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                AppButton(
                  label: context.l10n.reportState,
                  icon: Icons.send_rounded,
                  busy: _submitting,
                  onPressed: _submit,
                ),
              ],
              const SizedBox(height: 8),
              _HistoryHeader(
                count: reports.valueOrNull?.length ?? 0,
                expanded: _historyExpanded,
                onTap: () =>
                    setState(() => _historyExpanded = !_historyExpanded),
              ),
              if (_historyExpanded)
                reports.when(
                  data: (items) => _HistoryList(
                    reports: items,
                    currentUserId: ref
                        .read(authServiceProvider)
                        .currentUser
                        ?.id,
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      context.l10n.loadHistoryFailed,
                      style: AppTextStyles.bodyMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Subtle, low-emphasis action to flag that a point has no water. Greyish so it
/// doesn't compete with the primary condition chips above it.
class _NoWaterButton extends StatelessWidget {
  const _NoWaterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.outlined_flag_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.reportNoWater,
                  style: AppTextStyles.bodyMuted.copyWith(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  const _ConditionChip({
    required this.condition,
    required this.selected,
    required this.onTap,
  });

  final ReportCondition condition;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = condition.color;
    return Material(
      color: selected ? color : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : AppColors.border,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                condition.icon,
                size: 24,
                color: selected ? Colors.white : color,
              ),
              const SizedBox(width: 8),
              Text(
                condition.label(context.l10n),
                style: AppTextStyles.body.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({
    required this.count,
    required this.expanded,
    required this.onTap,
  });

  final int count;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.history_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.l10n.reportsHistory(count),
                style: AppTextStyles.subtitle,
              ),
            ),
            Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.reports, required this.currentUserId});

  final List<Report> reports;
  final String? currentUserId;

  static String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(context.l10n.noReportsYet, style: AppTextStyles.bodyMuted),
      );
    }
    return Column(
      children: reports.map((r) {
        final condition = ReportConditionX.fromValue(r.reportedCondition);
        final color = condition?.color ?? AppColors.textSecondary;
        final isMine = currentUserId != null && r.userId == currentUserId;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(condition?.icon ?? Icons.report_outlined, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ReportConditionX.labelForValue(
                        r.reportedCondition,
                        context.l10n,
                      ),
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    if (r.description != null && r.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(r.description!, style: AppTextStyles.body),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${isMine ? context.l10n.you : context.l10n.someUser} • ${_formatDate(r.createdAt)}',
                      style: AppTextStyles.bodyMuted.copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
