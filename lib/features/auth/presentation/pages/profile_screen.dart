import 'package:asongan_app/core/theme/app_colors.dart';
import 'package:asongan_app/features/auth/data/auth_service.dart';
import 'package:asongan_app/features/auth/data/db_helper.dart';
import 'package:asongan_app/features/auth/model/user_model_sql.dart';
import 'package:asongan_app/features/auth/presentation/pages/login_screen.dart';
import 'package:asongan_app/features/auth/presentation/pages/wrapper/main_wrapper.dart';
import 'package:asongan_app/features/settings/settings_screen.dart';
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

    // Jika user pindah ke mode pedagang dan belum memiliki role pedagang di database, perbarui role-nya
    if (newMode == 'pedagang' && _user != null) {
      if (_user!.role == 'pembeli') {
        final updatedUser = UserModelSql(
          id: _user!.id,
          email: _user!.email,
          password: _user!.password,
          nama: _user!.nama,
          telepon: _user!.telepon,
          role: 'pedagang_dan_pembeli',
          namaToko: _user!.namaToko ?? _user!.nama,
          jenisProduk: _user!.jenisProduk,
          namaMakanan: _user!.namaMakanan,
          statusJualan: _user!.statusJualan,
          jamOperasional: _user!.jamOperasional,
          lokasi: _user!.lokasi,
        );
        await DBHelper().updateUser(updatedUser);
        await AuthService.saveUserSession(updatedUser);
        setState(() {
          _user = updatedUser;
        });
      }
    }

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

  Future<void> _showEditProfileDialog() async {
    final Color scaffoldBg = AppColors.scaffoldBg(isDarkModeNotifier.value);
    if (_user == null) return;

    final TextEditingController nameController = TextEditingController(
      text: _user!.nama,
    );
    final TextEditingController emailController = TextEditingController(
      text: _user!.email,
    );
    final TextEditingController phoneController = TextEditingController(
      text: _user!.telepon,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: scaffoldBg,
          title: const Text(
            'Edit Profil',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                  // style: const TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  // style: const TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                  // style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFf5a623),
              ),
              onPressed: () async {
                final updatedUser = UserModelSql(
                  id: _user!.id,
                  email: emailController.text,
                  password: _user!.password,
                  nama: nameController.text,
                  telepon: phoneController.text,
                  role: _user!.role,
                  namaToko: _user!.namaToko,
                  jenisProduk: _user!.jenisProduk,
                  namaMakanan: _user!.namaMakanan,
                  statusJualan: _user!.statusJualan,
                  jamOperasional: _user!.jamOperasional,
                  lokasi: _user!.lokasi,
                );
                final success = await DBHelper().updateUser(updatedUser);
                if (success) {
                  await AuthService.saveUserSession(updatedUser);
                  setState(() {
                    _user = updatedUser;
                  });
                  if (context.mounted) Navigator.pop(context);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gagal memperbarui profil')),
                    );
                  }
                }
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
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
                  icon: Icons.edit_rounded,
                  title: "Edit Profil",
                  subtitle: "Ubah nama, email, atau telepon",
                  iconColor: AppColors.accent,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  onTap: _showEditProfileDialog,
                ),
                const SizedBox(height: 12),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
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
