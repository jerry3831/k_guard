import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../providers/home_bloc.dart';
import '../providers/home_event.dart';
import '../providers/home_state.dart';
import '../../../auth/presentation/providers/auth_bloc.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../scanner/domain/entities/currency_note.dart';
import '../../../settings/presentation/providers/settings_bloc.dart';
import '../../../settings/presentation/providers/settings_event.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/recent_scan_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _headerBlue = AppColors.dashboardBlue;
  static const Color _scanButtonGold = AppColors.scanButtonGold;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeLoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerColor = isDark ? Theme.of(context).scaffoldBackgroundColor : AppColors.dashboardBlue;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).cardColor,
            onRefresh: () async {
              context.read<HomeBloc>().add(const HomeRefreshed());
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeaderWithCards(
                    context,
                    state,
                    topPad,
                    headerColor,
                    isDark,
                  ),
                ),

                SliverToBoxAdapter(
                  child: _buildRecentScans(context, state, isDark),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _BottomNav(
        activeIndex: 0,
        onTap: (i) => _onNavTap(context, i),
      ),
    );
  }

  Widget _buildHeaderWithCards(
    BuildContext context,
    HomeState state,
    double topPad,
    Color headerColor,
    bool isDark,
  ) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 120, // Ends around the middle of the first card row
          child: Container(
            decoration: BoxDecoration(
              color: headerColor,
            ),
          ),
        ),
        Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: topPad + 16,
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(context),
                  const SizedBox(height: 24),
                  _buildScanButton(context, isDark),
                  const SizedBox(height: 28),
                ],
              ),
            ),
            _buildStatCards(state, isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final fullName = authState is AuthAuthenticated
            ? authState.user.fullName
            : 'there';
        final name = fullName.split(' ').first;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? AppColors.goldAccent : AppColors.primaryBlueDark,
                  size: 20,
                ),
                onPressed: () {
                  context.read<SettingsBloc>().add(SettingsDarkModeToggled(!isDark));
                },
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScanButton(BuildContext context, bool isDark) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.primaryBlue : AppColors.primaryBlueDark,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: AppColors.primaryBlueDark.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'READY TO VERIFY',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Scan a Kwacha Note',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/scan'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.goldAccent.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.crop_free_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Start Scanning',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  }

  Widget _buildStatCards(HomeState state, bool isDark) {
    final isLoaded = state is HomeLoaded;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.crop_free_rounded,
                  iconColor: const Color(0xFF3BAEA0),
                  iconBgColor: isDark ? const Color(0xFFE4F6F5).withOpacity(0.1) : const Color(0xFFE4F6F5),
                  label: 'Total Scans',
                  value: isLoaded
                      ? NumberFormat('#,###').format((state as HomeLoaded).stats.totalScans)
                      : '0',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: const Color(0xFF4CAF50),
                  iconBgColor: isDark ? const Color(0xFFE8F6EF).withOpacity(0.1) : const Color(0xFFE8F6EF),
                  label: 'Authentic',
                  value: isLoaded
                      ? NumberFormat('#,###').format((state as HomeLoaded).stats.authenticCount)
                      : '0',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.warning_amber_rounded,
                  iconColor: const Color(0xFFFF9800),
                  iconBgColor: isDark ? const Color(0xFFFFF4E5).withOpacity(0.1) : const Color(0xFFFFF4E5),
                  label: 'Suspicious',
                  value: isLoaded
                      ? NumberFormat('#,###').format((state as HomeLoaded).stats.suspiciousCount)
                      : '0',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up_rounded,
                  iconColor: const Color(0xFF2196F3),
                  iconBgColor: isDark ? const Color(0xFFEBF3FF).withOpacity(0.1) : const Color(0xFFEBF3FF),
                  label: 'This Week',
                  value: isLoaded
                      ? NumberFormat('#,###').format((state as HomeLoaded).stats.thisWeekCount)
                      : '0',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScans(BuildContext context, HomeState state, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Scans',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/history'),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3BAEA0),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (state is HomeError)
            _AutoHidingErrorBanner(message: state.message),

          if (state is HomeLoaded && state.recentScans.isNotEmpty)
            ...state.recentScans.map(
              (note) => RecentScanItem(
                note: note,
                onTap: () => Navigator.of(context).pushNamed(
                  '/scan-result',
                  arguments: note,
                ),
              ),
            )
          else if (state is HomeLoading || state is HomeInitial)
            ..._buildScanSkeletons(context)
          else
            const _EmptyRecentScans(),
        ],
      ),
    );
  }

  List<Widget> _buildScanSkeletons(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return List.generate(
      3,
      (_) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDark ? Theme.of(context).cardColor : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        break; // already on home
      case 1:
        Navigator.of(context).pushReplacementNamed('/scan');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/history');
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
class _EmptyRecentScans extends StatelessWidget {
  const _EmptyRecentScans();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.document_scanner_outlined,
                size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            const Text(
              'No scans yet',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13),
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

extension _StringX on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

class _AutoHidingErrorBanner extends StatefulWidget {
  final String message;
  const _AutoHidingErrorBanner({required this.message});

  @override
  State<_AutoHidingErrorBanner> createState() => _AutoHidingErrorBannerState();
}

class _AutoHidingErrorBannerState extends State<_AutoHidingErrorBanner> {
  Timer? _timer;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(_AutoHidingErrorBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) {
      setState(() => _visible = true);
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.counterfeit.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.counterfeit.withOpacity(0.25),
          ),
        ),
        child: Text(
          widget.message,
          style: const TextStyle(
            color: AppColors.counterfeit,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
