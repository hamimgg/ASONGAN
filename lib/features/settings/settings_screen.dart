import 'package:asongan_app/core/theme/app_colors.dart';
import 'package:asongan_app/features/auth/data/auth_service.dart';
import 'package:asongan_app/features/auth/presentation/pages/login_screen.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _handleLogout() async {
    await AuthService.clearSession();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        final Color scaffoldBg = AppColors.scaffoldBg(isDark);
        final Color appBg = AppColors.appBarBg(isDark);
        final Color textColor = AppColors.textPrimary(isDark);
        final Color cardBorderColor = AppColors.cardBorder(isDark);

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            backgroundColor: appBg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Pengaturan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 18,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: cardBorderColor,
                height: 1,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Preferensi Aplikasi", isDark),
                const SizedBox(height: 8),
                _buildCardGroup(
                  isDark: isDark,
                  children: [
                    _buildSettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: "Notifikasi",
                      subtitle: "Dapatkan info penawaran & pedagang",
                      isDark: isDark,
                      trailing: Switch(
                        value: _notificationsEnabled,
                        activeThumbColor: AppColors.accent,
                        onChanged: _toggleNotifications,
                      ),
                    ),
                    _buildSettingsTile(
                      icon: Icons.translate_rounded,
                      title: "Bahasa",
                      subtitle: "Bahasa Indonesia",
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionHeader("Dukungan & Bantuan", isDark),
                const SizedBox(height: 8),
                _buildCardGroup(
                  isDark: isDark,
                  children: [
                    _buildSettingsTile(
                      icon: Icons.help_outline_rounded,
                      title: "Pusat Bantuan",
                      subtitle: "Pertanyaan umum & bantuan CS",
                      isDark: isDark,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pusat Bantuan akan segera hadir')),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: "Tentang Asongan",
                      subtitle: "Versi 1.0.0",
                      isDark: isDark,
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'ASONGAN',
                          applicationVersion: '1.0.0',
                          applicationLegalese: '© 2026 Asongan Team. All rights reserved.',
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                InkWell(
                  onTap: _handleLogout,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3D1E1E) : const Color(0xFFFFF0F0),
                      border: Border.all(
                        color: isDark ? const Color(0xFF6D2E2E) : const Color(0xFFFFC1C1),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: AppColors.statusClosed,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Keluar (Logout)",
                            style: TextStyle(
                              color: AppColors.statusClosed,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textSubtitle(isDark),
          letterSpacing: 0.5,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
  }

  Widget _buildCardGroup({required bool isDark, required List<Widget> children}) {
    final Color cardBg = AppColors.cardBg(isDark);
    final Color borderColor = AppColors.cardBorder(isDark);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          if (index == children.length - 1) {
            return children[index];
          }
          return Column(
            children: [
              children[index],
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.divider(isDark),
                indent: 56,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final Color textColor = AppColors.textPrimary(isDark);
    final Color subtitleColor = AppColors.textSubtitle(isDark);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isDark ? Colors.white : AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: subtitleColor,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.iconSecondary(isDark),
                  size: 14,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
