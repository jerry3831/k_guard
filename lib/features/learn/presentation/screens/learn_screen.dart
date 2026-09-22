import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context, isDark),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Detection Tips',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildTipsGrid(isDark),
                  const SizedBox(height: 28),
                  Text(
                    'Security Features',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildSecurityFeaturesList(isDark),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        activeIndex: 3,
        onTap: (i) => _onNavTap(context, i),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 30,
      ),
      decoration: isDark
          ? BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            )
          : const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryBlueDark, AppColors.primaryBlue],
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Learn & Verify',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Understand currency security features',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsGrid(bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.15,
      children: [
        _TipCard(
          icon: Icons.visibility_outlined,
          iconBgColor: isDark ? const Color(0xFFE3F2FD).withOpacity(0.1) : const Color(0xFFE3F2FD),
          iconColor: const Color(0xFF42A5F5),
          title: 'Look at the Watermark',
          description: 'Hold the note up to the light. A genuine note will have a watermark portrait visible from both sides.',
          isDark: isDark,
        ),
        _TipCard(
          icon: Icons.fingerprint,
          iconBgColor: isDark ? const Color(0xFFE8F5E9).withOpacity(0.1) : const Color(0xFFE8F5E9),
          iconColor: const Color(0xFF66BB6A),
          title: 'Feel the Texture',
          description: 'Genuine notes have a distinctive feel due to raised printing on areas like portraits and values.',
          isDark: isDark,
        ),
        _TipCard(
          icon: Icons.auto_awesome,
          iconBgColor: isDark ? const Color(0xFFE3F2FD).withOpacity(0.1) : const Color(0xFFE3F2FD),
          iconColor: const Color(0xFF42A5F5),
          title: 'Tilt the Note',
          description: 'Look for color-shifting ink or holograms that change appearance when you tilt the note.',
          isDark: isDark,
        ),
        _TipCard(
          icon: Icons.shield_outlined,
          iconBgColor: isDark ? const Color(0xFFFFF3E0).withOpacity(0.1) : const Color(0xFFFFF3E0),
          iconColor: const Color(0xFFFFA726),
          title: 'Check Security Thread',
          description: 'A security thread running through the note should be visible when held to light.',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSecurityFeaturesList(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FeatureItem(
          index: 1,
          title: 'Micromirror LEAD Foil',
          description: 'Found on the left side of higher-value notes (like K5,000). Features an animated sun, a portrait, and a 3-dimensional fish from Lake Malawi, demonstrating rainbow effects and depth.',
          isDark: isDark,
        ),
        _FeatureItem(
          index: 2,
          title: 'SPARK Live',
          description: 'An optically variable ink feature. On the K5,000 note, it is shaped like a fish; when tilted, the color shifts (e.g., red to green) and shows dynamic rolling effects.',
          isDark: isDark,
        ),
        _FeatureItem(
          index: 3,
          title: 'Galaxy Security Thread',
          description: 'An advanced micro-mirror security thread. When tilted, the thread exhibits dynamic 3D effects and color-shifting properties.',
          isDark: isDark,
        ),
        _FeatureItem(
          index: 4,
          title: 'Watermark',
          description: 'When held against the light, a clear watermark of Dr. Hastings Kamuzu Banda (or other prominent figures) and the note\'s value are visible.',
          isDark: isDark,
        ),
        _FeatureItem(
          index: 5,
          title: 'UV Light Feature',
          description: 'Fluorescent elements printed on the paper that become visible under ultraviolet light for secure authentication.',
          isDark: isDark,
        ),
        _FeatureItem(
          index: 6,
          title: 'Intaglio Printing',
          description: 'Raised, tactile ink that gives the banknote a distinct rough feel, particularly on the portraits and texts.',
          isDark: isDark,
        ),
        _FeatureItem(
          index: 7,
          title: 'Visually Impaired Features',
          description: 'Distinctive tactile patterns (geometric shapes and raised dots) on the front left/right of the notes that help blind and partially sighted individuals identify the values by touch.',
          isDark: isDark,
        ),
      ],
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
        Navigator.of(context).pushReplacementNamed('/history');
        break;
      case 3:
        break; // currently on learn
      case 4:
        Navigator.of(context).pushReplacementNamed('/settings');
        break;
    }
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String description;
  final bool isDark;

  const _TipCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final int index;
  final String title;
  final String description;
  final bool isDark;

  const _FeatureItem({
    required this.index,
    required this.title,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2), // Aligns badge visually with the text
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              index.toString(),
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
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
