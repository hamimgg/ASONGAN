import 'package:asongan_app/core/theme/app_colors.dart';
import 'package:asongan_app/features/auth/data/auth_service.dart';
import 'package:asongan_app/features/auth/presentation/pages/explore_screen.dart';
import 'package:asongan_app/features/auth/presentation/pages/home_screen.dart';
import 'package:asongan_app/features/auth/presentation/pages/order_screen.dart';
import 'package:asongan_app/features/auth/presentation/pages/profile_screen.dart';
import 'package:asongan_app/features/auth/presentation/pages/wrapper/drawer.dart';
import 'package:asongan_app/features/buyer/presentation/pages/buyer_home_screen.dart';
import 'package:asongan_app/features/seller/presentation/pages/seller_screen.dart';
import 'package:asongan_app/features/seller/presentation/pages/store_detail_screen.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _activeMode = 'pembeli';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveMode();
  }

  Future<void> _loadActiveMode() async {
    final mode = await AuthService.getActiveMode();
    if (mounted) {
      setState(() {
        _activeMode = mode ?? 'pembeli';
        _isLoading = false;
      });
    }
  }

  List<Widget> getPages(bool isDark) {
    if (_activeMode == 'pedagang') {
      return [
        const HomeScreen(),
        const KelolaDagangan(),
        const StoreDetailScreen(),
        const ProfileScreen(),
      ];
    } else {
      return [
        const BuyerHomeScreen(),
        const ExploreScreen(),
        const OrderScreen(), // Ini adalah halaman Toko/Detail Toko untuk pembeli
        const ProfileScreen(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBgPure(true),
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        final Color navBg = AppColors.scaffoldBgPure(isDark);
        final Color navBorderColor = AppColors.divider(isDark);

        final isPedagang = _activeMode == 'pedagang';

        return Scaffold(
          key: _scaffoldKey,
          endDrawer: MainDrawer(),
          body: IndexedStack(index: _currentIndex, children: getPages(isDark)),
          bottomNavigationBar: Container(
            height: 64 + MediaQuery.of(context).padding.bottom,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
              left: 8,
              right: 8,
            ),
            decoration: BoxDecoration(
              color: navBg,
              border: Border(top: BorderSide(color: navBorderColor, width: 1)),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildNavItem(
                    0,
                    "Home",
                    Icons.home_rounded,
                    Icons.home_outlined,
                    isDark,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    1,
                    isPedagang ? 'Dagangan' : 'Explore',
                    isPedagang ? Icons.store_rounded : Icons.explore_rounded,
                    isPedagang ? Icons.store_outlined : Icons.explore_outlined,
                    isDark,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    2,
                    isPedagang ? 'Detail Toko' : 'Toko',
                    isPedagang
                        ? Icons.analytics_rounded
                        : Icons.receipt_long_rounded,
                    isPedagang
                        ? Icons.analytics_outlined
                        : Icons.receipt_long_outlined,
                    isDark,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    3,
                    'Profil',
                    Icons.person_rounded,
                    Icons.person_outline_rounded,
                    isDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    int index,
    String label,
    IconData activeIcon,
    IconData inactiveIcon,
    bool isDark,
  ) {
    final bool isSelected = _currentIndex == index;
    final Color activeColor = Colors.white;
    final Color inactiveColor = AppColors.textSubtitle(isDark);

    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? activeColor : inactiveColor,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? activeColor : inactiveColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 10,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
