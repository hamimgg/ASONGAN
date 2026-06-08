import 'package:asongan_app/core/theme/app_colors.dart';
import 'package:asongan_app/core/widgets/asongan_app_bar.dart';
import 'package:asongan_app/features/seller/model/store_summary_model.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        final Color scaffoldBg = AppColors.scaffoldBg(isDark);
        final Color cardBg = AppColors.cardBg(isDark);
        final Color cardBorder = AppColors.cardBorder(isDark);
        final Color textColor = AppColors.textPrimary(isDark);
        final Color subtitleColor = AppColors.textSubtitle(isDark);
        final data = dummyStoreSummary; // Data dummy

        return Scaffold(
          backgroundColor: scaffoldBg,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AsonganAppBar(
                title: "Ringkasan Hari Ini",
                isDark: isDark,
                showThemeToggle: true,
                showNotification: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Welcome Section
                Text(
                  "Halo, Pedagang!",
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

                // Summary Cards Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: "Status Toko",
                        value: data.isStoreOpen ? "Buka" : "Tutup",
                        icon: Icons.storefront_rounded,
                        valueColor: data.isStoreOpen
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
                        value: "${data.todayVisitors}",
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
                        value: "${data.totalMenu}",
                        icon: Icons.restaurant_menu_rounded,
                        valueColor: textColor,
                        cardBg: cardBg,
                        cardBorder: cardBorder,
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(), // Placeholder for grid alignment
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Quick Action / Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
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
}
