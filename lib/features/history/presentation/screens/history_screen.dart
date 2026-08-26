import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../providers/history_bloc.dart';
import '../providers/history_event.dart';
import '../providers/history_state.dart';
import '../widgets/history_filter_tabs.dart';
import '../../../scanner/domain/entities/currency_note.dart';
import '../../../../core/theme/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<HistoryBloc>().add(const HistoryLoaded());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).cardColor,
            onRefresh: () async {
              context.read<HistoryBloc>().add(const HistoryRefreshed());
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                    child: _buildHeader(context, state)),

                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SearchBarDelegate(
                    controller: _searchController,
                    onChanged: (q) => context
                        .read<HistoryBloc>()
                        .add(HistorySearchChanged(q)),
                  ),
                ),

                if (state is HistoryLoadSuccess)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 6, bottom: 2),
                      child: HistoryFilterTabs(
                        activeFilter: state.activeFilter,
                        onFilterSelected: (f) => context
                            .read<HistoryBloc>()
                            .add(HistoryFilterChanged(f)),
                      ),
                    ),
                  ),

                _buildList(context, state),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _BottomNav(
        activeIndex: 2,
        onTap: (i) => _onNavTap(context, i),
      ),
    );
  }


  Widget _buildHeader(BuildContext context, HistoryState state) {
    final isLoaded = state is HistoryLoadSuccess;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      color: isDark ? Theme.of(context).colorScheme.surface : AppColors.dashboardBlue,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scan History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'View all your previous scans',
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _StatChip(
                  label: 'Total',
                  value: isLoaded
                      ? (state as HistoryLoadSuccess).totalCount.toString()
                      : '0',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  label: 'Valid',
                  value: isLoaded
                      ? (state as HistoryLoadSuccess).validCount.toString()
                      : '0',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  label: 'Suspect',
                  value: isLoaded
                      ? (state as HistoryLoadSuccess).suspectCount.toString()
                      : '0',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  label: 'Fake',
                  value: isLoaded
                      ? (state as HistoryLoadSuccess).fakeCount.toString()
                      : '0',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildList(BuildContext context, HistoryState state) {
    if (state is HistoryLoading || state is HistoryInitial) {
      return SliverToBoxAdapter(child: _buildSkeletonList(context));
    }

    if (state is HistoryLoadFailure) {
      return SliverFillRemaining(
        child: _ErrorView(
          message: state.message,
          onRetry: () =>
              context.read<HistoryBloc>().add(const HistoryLoaded()),
        ),
      );
    }

    if (state is HistoryLoadSuccess) {
      if (state.displayedScans.isEmpty) {
        return SliverFillRemaining(
          child: _EmptyView(
            isFiltered: state.activeFilter != HistoryFilter.all ||
                state.searchQuery.isNotEmpty,
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final note = state.displayedScans[index];
            return _HistoryRow(
              key: ValueKey(note.id),
              note: note,
              onTap: () => Navigator.of(context)
                  .pushNamed('/scan-result', arguments: note),
              onDismissed: () => context
                  .read<HistoryBloc>()
                  .add(HistoryScanDeleted(note.id)),
            );
          },
          childCount: state.displayedScans.length,
        ),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  Widget _buildSkeletonList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: List.generate(
        4,
        (_) => Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: isDark ? Theme.of(context).cardColor : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/scan');
        break;
      case 2:
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/learn');
        break;
      case 4:
        Navigator.of(context).pushReplacementNamed('/settings');
        break;
    }
  }
}


class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}


class _HistoryRow extends StatelessWidget {
  final CurrencyNote note;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _HistoryRow({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final color = _verdictColor(note.verdict);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = GestureDetector(
      onTap: onTap,
      child: Container(
        margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_verdictIcon(note.verdict),
                      color: color, size: 20),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MWK ${note.denomination}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        note.serialNumber,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                _VerdictBadge(verdict: note.verdict),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 11, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  DateFormat('yyyy-MM-dd   HH:mm a')
                      .format(note.timestamp),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
                const Spacer(),
                SizedBox(
                  width: 56,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: note.confidenceScore,
                      backgroundColor:
                          Colors.grey.withOpacity(0.15),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  note.confidenceLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.counterfeit,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 24),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: const Text('Delete scan?'),
                content: Text(
                    'Remove MWK ${note.denomination} from history?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.counterfeit),
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDismissed(),
      child: card,
    );
  }

  Color _verdictColor(ScanVerdict v) {
    switch (v) {
      case ScanVerdict.authentic:
        return AppColors.authentic;
      case ScanVerdict.suspicious:
        return AppColors.suspicious;
      case ScanVerdict.counterfeit:
        return AppColors.counterfeit;
      case ScanVerdict.invalid:
        return Colors.grey.shade700;
    }
  }

  IconData _verdictIcon(ScanVerdict v) {
    switch (v) {
      case ScanVerdict.authentic:
        return Icons.check_circle_rounded;
      case ScanVerdict.suspicious:
        return Icons.warning_amber_rounded;
      case ScanVerdict.counterfeit:
        return Icons.cancel_rounded;
      case ScanVerdict.invalid:
        return Icons.block_rounded;
    }
  }
}


class _VerdictBadge extends StatelessWidget {
  final ScanVerdict verdict;
  const _VerdictBadge({required this.verdict});

  @override
  Widget build(BuildContext context) {
    final color = _color(verdict);
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        verdict.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _color(ScanVerdict v) {
    switch (v) {
      case ScanVerdict.authentic:
        return AppColors.authentic;
      case ScanVerdict.suspicious:
        return AppColors.suspicious;
      case ScanVerdict.counterfeit:
        return AppColors.counterfeit;
      case ScanVerdict.invalid:
        return Colors.grey.shade700;
    }
  }
}


class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBarDelegate(
      {required this.controller, required this.onChanged});

  @override
  double get minExtent => 62;
  @override
  double get maxExtent => 62;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
            fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search by currency or serial number...',
          hintStyle: TextStyle(
              color: isDark ? Colors.white54 : AppColors.textSecondary, fontSize: 13),
          prefixIcon: Icon(Icons.search,
              color: isDark ? Colors.white54 : AppColors.textSecondary, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: Icon(Icons.close,
                      color: isDark ? Colors.white54 : AppColors.textSecondary, size: 18),
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: AppColors.divider.withOpacity(0.5), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarDelegate old) =>
      old.controller != controller;
}


class _EmptyView extends StatelessWidget {
  final bool isFiltered;
  const _EmptyView({required this.isFiltered});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFiltered
                  ? Icons.search_off_rounded
                  : Icons.document_scanner_outlined,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              isFiltered ? 'No scans match' : 'No scans yet',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary),
            ),
            if (!isFiltered) ...[
              const SizedBox(height: 6),
              const Text(
                'Tap "Scan Currency" on the home screen to start.',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 44, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(message,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: onRetry,
              child: const Text('Retry',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}


class _BottomNav extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.activeIndex, required this.onTap});

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined),
    (Icons.camera_alt_rounded, Icons.camera_alt_outlined),
    (Icons.history, Icons.history),
    (Icons.menu_book_rounded, Icons.menu_book_outlined),
    (Icons.settings_rounded, Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (i) {
            final active = i == activeIndex;
            final color = active 
                ? Theme.of(context).colorScheme.primary 
                : (isDark ? Colors.white54 : AppColors.textSecondary);
            final item = _items[i];
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? item.$1 : item.$2,
                        color: color,
                        size: 26,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: active ? color : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
