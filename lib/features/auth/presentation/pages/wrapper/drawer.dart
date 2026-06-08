import 'package:asongan_app/features/auth/data/auth_service.dart';
import 'package:asongan_app/features/auth/model/user_model_sql.dart';
import 'package:asongan_app/features/auth/presentation/pages/login_screen.dart';
import 'package:asongan_app/features/auth/presentation/pages/wrapper/main_wrapper.dart';
import 'package:asongan_app/features/settings/settings_screen.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  UserModelSql? _currentUser;
  String _activeMode = 'pembeli';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getUserSession();
    final mode = await AuthService.getActiveMode();
    setState(() {
      _currentUser = user;
      _activeMode = mode ?? 'pembeli';
    });
  }

  Future<void> _switchMode() async {
    final newMode = _activeMode == 'pembeli' ? 'pedagang' : 'pembeli';
    
    // Jika belum login, ke halaman login
    if (_currentUser == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    // Jika sudah login tapi role-nya pembeli dan mau ke pedagang, tolak
    if (newMode == 'pedagang' && _currentUser!.role == 'pembeli') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun Anda bukan akun pedagang!')),
      );
      return;
    }

    await AuthService.setActiveMode(newMode);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainWrapper()),
    );
  }

  Future<void> _logout() async {
    await AuthService.clearSession();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        final Color drawerBg = isDark ? const Color(0xff1c1c1e) : Colors.white;
        final Color textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
        final Color subtextColor = isDark ? Colors.white70 : const Color(0xFF7A7A7C);
        final Color headerBgColor = isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05);

        return Drawer(
          backgroundColor: drawerBg,
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: headerBgColor),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: isDark ? Colors.white24 : Colors.black12,
                      child: Icon(
                        Icons.person,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser?.nama ?? "Guest",
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _currentUser?.email ?? "Belum login",
                            style: TextStyle(
                              color: subtextColor,
                              fontSize: 12,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _drawerItem(
                icon: Icons.settings_rounded,
                label: "App Settings",
                textColor: textColor,
                onTap: () {
                  Navigator.pop(context); // tutup drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              // Dark/Light Theme Switcher Tile
              ListTile(
                leading: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: const Color(0xFFF5A623),
                ),
                title: Text(
                  isDark ? "Light Mode" : "Dark Mode",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                trailing: Switch(
                  value: isDark,
                  activeThumbColor: const Color(0xFFF5A623),
                  onChanged: (val) {
                    isDarkModeNotifier.value = val;
                  },
                ),
              ),
              const Spacer(),
              _drawerItem(
                icon: Icons.swap_horiz,
                label: _activeMode == 'pembeli' ? "Login sebagai pedagang" : "Mode Pembeli",
                textColor: textColor,
                onTap: _switchMode,
              ),
              _drawerItem(
                icon: Icons.logout,
                label: "Logout",
                textColor: Colors.red,
                color: Colors.red,
                onTap: _logout,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xffF5A623)),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? textColor ?? Colors.white,
          fontSize: 14,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: color ?? textColor?.withValues(alpha: 0.3) ?? Colors.white24,
        size: 18,
      ),
      onTap: onTap,
    );
  }
}
