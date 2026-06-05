import 'package:asongan_app/features/auth/data/auth_service.dart';
import 'package:asongan_app/features/auth/model/user_model_sql.dart';
import 'package:asongan_app/features/auth/presentation/pages/login_screen.dart';
import 'package:asongan_app/features/auth/presentation/pages/wrapper/main_wrapper.dart';
import 'package:asongan_app/features/settings/settings_screen.dart';
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
    return Drawer(
      backgroundColor: const Color(0xff1c1c1e),
      child: Column(
        children: [
          DrawerHeader(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 36),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser?.nama ?? "Guest",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _currentUser?.email ?? "Belum login",
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _drawerItem(
            icon: Icons.settings_rounded,
            label: "App Settings",
            onTap: () {
              Navigator.pop(context); // tutup drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const Spacer(),
          _drawerItem(
            icon: Icons.swap_horiz,
            label: _activeMode == 'pembeli' ? "Login sebagai pedagang" : "Mode Pembeli",
            onTap: _switchMode,
          ),
          _drawerItem(
            icon: Icons.logout,
            label: "Logout",
            color: Colors.red,
            onTap: _logout,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Color(0xffF5A623)),
      title: Text(
        label,
        style: TextStyle(color: color ?? Colors.white, fontSize: 14),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: color ?? Colors.white24,
        size: 18,
      ),
      onTap: onTap,
    );
  }
}
