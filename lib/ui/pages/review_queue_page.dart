import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/services/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/metadata_field.dart';
import 'package:radiologist_helper/ui/molecules/review_status_chip.dart';
import 'package:radiologist_helper/ui/organisms/app_nav_bar.dart';
import 'package:radiologist_helper/ui/organisms/image_review_table.dart';
import 'package:radiologist_helper/ui/organisms/menu_rail.dart';
import 'package:radiologist_helper/ui/organisms/primary_nav_drawer.dart';
import 'package:radiologist_helper/ui/organisms/study_info_card.dart';
import 'package:radiologist_helper/ui/pages/image_review_page.dart';
import 'package:radiologist_helper/ui/pages/primary_destinations.dart';
import 'package:radiologist_helper/ui/templates/case_list_template.dart';

List<StudyMetadataField> _cardFields(ReviewQueueItem item) {
  final recorded = item.review.image.recorded;
  return [
    StudyMetadataField(
      label: 'Status',
      value: ReviewStatusChip.labelFor(item.review.status),
    ),
    StudyMetadataField(label: 'Patient', value: item.caseSummary.patient),
    StudyMetadataField(label: 'Reason', value: item.review.reason.label),
    StudyMetadataField(
      label: 'Recorded',
      value: '${recorded.viewPosition?.code ?? '—'} · '
          '${recorded.orientation?.label ?? '—'}',
      valueKind: MetadataValueKind.identifier,
    ),
  ];
}

/// The images the pipeline flagged, needs review first -- the Review
/// primary destination. Composes `CaseListTemplate` as Similar Cases does:
/// cards at compact and medium, the dense table from `threePaneMinWidth`.
class ReviewQueuePage extends ConsumerWidget {
  const ReviewQueuePage({super.key});

  static const _destination = 3;

  static final _appBar = AppBar(title: const Text('Review'));

  void _openReview(BuildContext context, ImageReview review) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ImageReviewPage(reviewId: review.id)),
    );
  }

  Widget _navBar(BuildContext context, int pendingReviewCount) =>
      AppNavBar(
        selectedIndex: _destination,
        onDestinationSelected: (i) =>
            openPrimaryDestination(context, i, current: _destination),
        pendingReviewCount: pendingReviewCount,
      );

  Widget _primaryNavDrawer(BuildContext context, int pendingReviewCount) =>
      PrimaryNavDrawer(
        selectedIndex: _destination,
        onDestinationSelected: (i) =>
            openPrimaryDestination(context, i, current: _destination),
        pendingReviewCount: pendingReviewCount,
      );

  /// Builder-wrapped so Scaffold.of(context) resolves to the Scaffold this
  /// ends up inside once CaseListTemplate places it, not this page's own
  /// context, which sits above it.
  Widget _menuRail(BuildContext context) => Builder(
        builder: (context) => MenuRail(
          onMenuTap: () => Scaffold.of(context).openDrawer(),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingReviewCount = ref.watch(pendingReviewCountProvider);
    return ref.watch(reviewQueueProvider).when(
          data: (items) => CaseListTemplate(
            appBar: _appBar,
            caseSlots: [
              for (final item in items)
                StudyInfoCard(
                  title: item.caseSummary.title,
                  fields: _cardFields(item),
                  thumbnailUrl: item.review.image.url,
                  onTap: () => _openReview(context, item.review),
                ),
            ],
            worklistTable: ImageReviewTable(
              items: items,
              onReviewTap: (review) => _openReview(context, review),
            ),
            emptyState:
                const AppText('No images have been flagged for review.'),
            navBar: _navBar(context, pendingReviewCount),
            primaryNavDrawer: _primaryNavDrawer(context, pendingReviewCount),
            menuRail: _menuRail(context),
          ),
          loading: () => CaseListTemplate(
            appBar: _appBar,
            caseSlots: const [],
            worklistTable: const SizedBox.shrink(),
            emptyState: const AppLoadingIndicator(),
            navBar: _navBar(context, pendingReviewCount),
            primaryNavDrawer: _primaryNavDrawer(context, pendingReviewCount),
            menuRail: _menuRail(context),
          ),
          error: (error, stackTrace) => CaseListTemplate(
            appBar: _appBar,
            caseSlots: const [],
            worklistTable: const SizedBox.shrink(),
            emptyState: AppText('Could not load the review queue: $error'),
            navBar: _navBar(context, pendingReviewCount),
            primaryNavDrawer: _primaryNavDrawer(context, pendingReviewCount),
            menuRail: _menuRail(context),
          ),
        );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'narrow', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewReviewQueuePageNarrow() => const ReviewQueuePage();

@Preview(name: 'expanded', size: Size(1200, 700), wrapper: previewWrapperFull)
Widget previewReviewQueuePageExpanded() => const ReviewQueuePage();
