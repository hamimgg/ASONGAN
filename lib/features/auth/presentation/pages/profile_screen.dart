import 'package:asongan_app/core/theme/app_colors.dart';
import 'package:asongan_app/features/auth/data/auth_service.dart';
import 'package:asongan_app/features/auth/model/user_model_sql.dart';
import 'package:asongan_app/features/auth/presentation/pages/login_screen.dart';
import 'package:asongan_app/features/auth/presentation/pages/wrapper/main_wrapper.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModelSql? _user;
  String _activeMode = 'pembeli';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getUserSession();
    final mode = await AuthService.getActiveMode();
    if (mounted) {
      setState(() {
        _user = user;
        _activeMode = mode ?? 'pembeli';
      });
    }
  }

  Future<void> _switchRole() async {
    final newMode = _activeMode == 'pembeli' ? 'pedagang' : 'pembeli';
    await AuthService.setActiveMode(newMode);

    if (mounted) {
      // Navigate to MainWrapper which will reload based on new active mode
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainWrapper()),
      );
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.clearSession();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

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

        return Scaffold(
          backgroundColor: scaffoldBg,
          // appBar: PreferredSize(
          //   preferredSize: const Size.fromHeight(80),
          //   child: AsonganAppBar(
          //     title: "Profil Anda",
          //     isDark: isDark,
          //     showThemeToggle: true,
          //   ),
          // ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.accent.withValues(
                          alpha: 0.2,
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 40,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _user?.nama ?? "User Name",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _user?.email ?? "email@example.com",
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 14,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill(isDark),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Mode: ${_activeMode.toUpperCase()}",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                _buildActionItem(
                  icon: Icons.swap_horiz_rounded,
                  title: "Ganti Role (Switch Mode)",
                  subtitle: "Ubah mode antara Pembeli dan Pedagang",
                  iconColor: AppColors.accent,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  onTap: _switchRole,
                ),
                const SizedBox(height: 12),
                _buildActionItem(
                  icon: Icons.settings_rounded,
                  title: "Pengaturan",
                  subtitle: "Atur preferensi aplikasi Anda",
                  iconColor: textColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  onTap: () {
                    // Navigate to settings (if exists)
                  },
                ),
                const SizedBox(height: 12),
                _buildActionItem(
                  icon: Icons.logout_rounded,
                  title: "Keluar (Logout)",
                  subtitle: "Akhiri sesi Anda",
                  iconColor: AppColors.statusClosed,
                  textColor: AppColors.statusClosed,
                  subtitleColor: subtitleColor,
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  onTap: _handleLogout,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color textColor,
    required Color subtitleColor,
    required Color cardBg,
    required Color cardBorder,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: subtitleColor),
          ],
        ),
      ),
    );
  }
}
