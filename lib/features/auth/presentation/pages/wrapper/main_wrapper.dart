import 'package:asongan_app/features/auth/data/auth_service.dart';
import 'package:asongan_app/features/seller/presentation/pages/seller_home_screen.dart';
import 'package:asongan_app/features/auth/presentation/pages/chat_screen.dart';
import 'package:asongan_app/features/auth/presentation/pages/explore_screen.dart';
import 'package:asongan_app/features/auth/presentation/pages/order_screen.dart';
import 'package:asongan_app/features/auth/presentation/pages/wrapper/drawer.dart';
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

  List<Widget> get _pages => [
    _activeMode == 'pedagang' ? const SellerHomeScreen() : const HomeScreen(),
    const OrderScreen(),
    const ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xff1c1c1e),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: MainDrawer(),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Color(0xfff5a623),
        unselectedItemColor: Color(0xffffffff),
        backgroundColor: Color(0xff1c1c1e),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(_activeMode == 'pedagang' ? Icons.store : Icons.map),
            label: _activeMode == 'pedagang' ? 'Dagangan' : 'Explore',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      ),
    );
  }
}
