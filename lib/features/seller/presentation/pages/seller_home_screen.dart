import 'package:asongan_app/core/theme/app_colors.dart';
import 'package:asongan_app/features/auth/data/auth_service.dart';
import 'package:asongan_app/features/auth/data/db_helper.dart';
import 'package:asongan_app/features/auth/model/user_model_sql.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModelSql? _user;
  String _activeMode = 'pembeli';
  int _totalMenu = 0;
  bool _isStoreOpen = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getUserSession();
    final mode = await AuthService.getActiveMode();
    int totalMenu = 0;
    bool storeOpen = false;

    if (user != null && user.id != null) {
      final latestUser = await DBHelper().getUserById(user.id!);
      if (latestUser != null) {
        storeOpen = latestUser.statusJualan ?? true;
      }
      final products = await DBHelper().getProductsByPedagang(user.id!);
      totalMenu = products.length;
    }

    if (mounted) {
      setState(() {
        _user = user;
        _activeMode = mode ?? 'pembeli';
        _totalMenu = totalMenu;
        _isStoreOpen = storeOpen;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        final Color textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
        final Color subtitleColor = isDark
            ? const Color(0xFF9A9A9A)
            : const Color(0xFF7A7A7C);
        final Color cardBg = isDark ? const Color(0xFF2A2A2C) : Colors.white;
        final Color cardBorder = isDark
            ? const Color(0xFF3A3A3C)
            : const Color(0xFFE2E8F0);
        return Scaffold(
          body: Column(
            children: [
              _buildAppBar(context, isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Halo,",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      Text(
                        _user?.nama ?? "User Name",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Berikut adalah ringkasan toko Anda.",
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 14,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              title: "Status Toko",
                              value: _isStoreOpen ? "Buka" : "Tutup",
                              icon: Icons.storefront_rounded,
                              valueColor: _isStoreOpen
                                  ? AppColors.statusActive
                                  : AppColors.statusClosed,
                              cardBg: cardBg,
                              cardBorder: cardBorder,
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              title: "Pengunjung",
                              value: "0",
                              icon: Icons.people_outline_rounded,
                              valueColor: textColor,
                              cardBg: cardBg,
                              cardBorder: cardBorder,
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              title: "Total Menu",
                              value: "$_totalMenu",
                              icon: Icons.restaurant_menu_rounded,
                              valueColor: textColor,
                              cardBg: cardBg,
                              cardBorder: cardBorder,
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Container()),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.accent,
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Cek Detail Toko",
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Lihat menu terlaris dan stok menipis di tab Detail Toko.",
                                    style: TextStyle(
                                      color: subtitleColor,
                                      fontSize: 13,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color valueColor,
    required Color cardBg,
    required Color cardBorder,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 13,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              Icon(icon, color: AppColors.accent, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    final Color bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color iconColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    return Container(
      color: bgColor,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 12,
        right: 12,
        bottom: 12,
      ),
      child: Row(
        children: [
          // SVG Logo
          SvgPicture.asset(
            "assets/images/logo_asongan.svg",
            width: 32,
            height: 32,
            semanticsLabel: "logo asongan",
          ),
          const SizedBox(width: 10),
          // Title section
          Text(
            'Temukan Pembeli',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const Spacer(),
          // IconButton(
          //   onPressed: () {
          //     isDarkModeNotifier.value = !isDarkModeNotifier.value;
          //   },
          //   icon: Icon(
          //     isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          //     color: iconColor,
          //     size: 22,
          //   ),
          // ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_none_rounded,
              color: iconColor,
              size: 22,
            ),
          ),
          IconButton(
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            icon: Icon(Icons.menu_rounded, color: iconColor, size: 22),
          ),
        ],
      ),
    );
  }
}
