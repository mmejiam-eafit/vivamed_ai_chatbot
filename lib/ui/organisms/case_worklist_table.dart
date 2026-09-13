import 'package:flutter/material.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/severity_chip.dart';

enum _SortColumn { patient, modality, date, confidence, severity }

String _formatDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String _formatConfidence(double confidence) =>
    '${(confidence * 100).round()}%';

/// The dense, sortable worklist table DT §9.5 specifies for Case List at
/// expanded and up. Built on Flutter's own `DataTable` rather than hand-rolled
/// rows: `dataRowMaxHeight: double.infinity` lets a wrapped cell grow its row
/// instead of clipping it, and an explicit `FlexColumnWidth` per column keeps
/// the table within the available width with no horizontal scroll — the two
/// settings that make `DataTable` compatible with D-010's reflow requirement
/// (verified against the Flutter SDK source, not assumed from the widget's
/// reputation for fixed-height, horizontally-scrolling rows).
class CaseWorklistTable extends StatefulWidget {
  const CaseWorklistTable({super.key, required this.cases, this.onCaseTap});

  final List<CaseSummary> cases;
  final ValueChanged<CaseSummary>? onCaseTap;

  @override
  State<CaseWorklistTable> createState() => _CaseWorklistTableState();
}

class _CaseWorklistTableState extends State<CaseWorklistTable> {
  // Null until the user picks a column — no column sorts by default, so a
  // first tap always means "ascending by this column," never a silent flip.
  int? _sortColumnIndex;
  bool _ascending = true;

  static const _sortColumns = _SortColumn.values;

  int _compare(CaseSummary a, CaseSummary b) {
    final result = switch (_sortColumns[_sortColumnIndex!]) {
      _SortColumn.patient => a.patient.compareTo(b.patient),
      _SortColumn.modality => a.modality.compareTo(b.modality),
      _SortColumn.date => a.date.compareTo(b.date),
      _SortColumn.confidence => a.confidence.compareTo(b.confidence),
      _SortColumn.severity => a.severity.index.compareTo(b.severity.index),
    };
    return _ascending ? result : -result;
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _ascending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sorted = [...widget.cases];
    if (_sortColumnIndex != null) sorted.sort(_compare);

    Widget cellText(String text, {TextStyle? style}) => AppText(
          text,
          style: style ?? AppTypography.bodyMd,
          color: colors.textPrimary,
        );

    return Theme(
      // DataTable's row divider takes its color from the ambient Theme --
      // dividerThickness is a DataTable parameter, divider color isn't.
      data: Theme.of(context).copyWith(dividerColor: colors.borderSubdued),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _ascending,
          dataRowMinHeight: AppInteraction.minTouchTarget,
          dataRowMaxHeight: double.infinity,
          showCheckboxColumn: false,
          headingTextStyle:
              AppTypography.labelMd.copyWith(color: colors.textSecondary),
          headingRowColor: WidgetStateProperty.all(colors.surfaceSubdued),
          columns: [
            // DataColumn's own doc: the label sits in a Row with the sort
            // indicator, and overflows a narrow column unless given an
            // Expanded/Flexible to shrink within -- exactly this table's
            // case, since every column here is proportionally narrow.
            DataColumn(
              label: const Expanded(child: Text('Patient')),
              columnWidth: const FlexColumnWidth(2),
              onSort: _onSort,
            ),
            DataColumn(
              label: const Expanded(child: Text('Modality')),
              columnWidth: const FlexColumnWidth(1),
              onSort: _onSort,
            ),
            DataColumn(
              label: const Expanded(child: Text('Date')),
              columnWidth: const FlexColumnWidth(1.2),
              onSort: _onSort,
            ),
            DataColumn(
              label: const Expanded(child: Text('Confidence')),
              columnWidth: const FlexColumnWidth(1),
              numeric: true,
              onSort: _onSort,
            ),
            DataColumn(
              label: const Expanded(child: Text('Severity')),
              columnWidth: const FlexColumnWidth(1.2),
              onSort: _onSort,
            ),
          ],
          rows: [
            for (final item in sorted)
              DataRow(
                onSelectChanged: widget.onCaseTap == null
                    ? null
                    : (_) => widget.onCaseTap!(item),
                cells: [
                  DataCell(cellText(item.patient)),
                  DataCell(cellText(item.modality)),
                  DataCell(cellText(_formatDate(item.date),
                      style: AppTypography.numeric)),
                  DataCell(cellText(_formatConfidence(item.confidence),
                      style: AppTypography.numeric)),
                  DataCell(SeverityChip(severity: item.severity)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
