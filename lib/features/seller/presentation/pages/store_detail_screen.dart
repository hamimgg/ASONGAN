import 'package:asongan_app/core/theme/app_colors.dart';
import 'package:asongan_app/core/widgets/asongan_app_bar.dart';
import 'package:asongan_app/features/seller/model/store_summary_model.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';

class StoreDetailScreen extends StatelessWidget {
  const StoreDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        final Color scaffoldBg = AppColors.scaffoldBg(isDark);
        final Color cardBg = AppColors.cardBg(isDark);
        final Color cardBorder = AppColors.cardBorder(isDark);
        final Color textColor = AppColors.textPrimary(isDark);
        
        // Menggunakan data dummy yang sama dari model
        final data = dummyStoreSummary;

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: AsonganAppBar(
              title: "Detail Toko",
              isDark: isDark,
              showThemeToggle: true,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  "Menu Terlaris", 
                  Icons.local_fire_department_rounded, 
                  textColor,
                ),
                const SizedBox(height: 12),
                _buildListCard(
                  items: data.bestSellingMenu,
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  textColor: textColor,
                  icon: Icons.star_rounded,
                  iconColor: AppColors.accent,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  "Stok Menipis", 
                  Icons.warning_amber_rounded, 
                  textColor,
                ),
                const SizedBox(height: 12),
                _buildListCard(
                  items: data.lowStockMenu,
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  textColor: textColor,
                  icon: Icons.error_outline_rounded,
                  iconColor: AppColors.statusClosed,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: bold,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
      ],
    );
  }

  Widget _buildListCard({
    required List<String> items,
    required Color cardBg,
    required Color cardBorder,
    required Color textColor,
    required IconData icon,
    required Color iconColor,
  }) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
        ),
        child: Center(
          child: Text(
            "Tidak ada data.",
            style: TextStyle(
              color: AppColors.textSubtitle(false), // fallback
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => Divider(
          color: cardBorder,
          height: 1,
        ),
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(icon, color: iconColor, size: 20),
            title: Text(
              items[index],
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          );
        },
      ),
    );
  }
}

// Local variable needed because FontWeight.bold isn't imported from basic dart
const bold = FontWeight.bold;
