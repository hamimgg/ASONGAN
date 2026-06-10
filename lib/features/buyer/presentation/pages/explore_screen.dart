import 'dart:math' as math;

import 'package:asongan_app/features/auth/data/db_helper.dart';
import 'package:asongan_app/features/auth/model/user_model_sql.dart';
import 'package:asongan_app/features/buyer/presentation/pages/buyer_store_detail_screen.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Semua', 'Terdekat', 'Makanan', 'Minuman'];
  final PanelController _panelController = PanelController();
  List<UserModelSql> _pedagangList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await DBHelper().getAllPedagang();
    if (mounted) {
      setState(() {
        _pedagangList = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        final Color scaffoldBg = isDark
            ? const Color(0xFF1C1C1E)
            : Colors.white;
        final Color panelBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;

        return Scaffold(
          backgroundColor: scaffoldBg,
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFF5A623)),
                )
              : Column(
                  children: [
                    // Custom AppBar
                    _buildAppBar(context, isDark),
                    // Map + Sliding Panel
                    Expanded(
                      child: SlidingUpPanel(
                        controller: _panelController,
                        minHeight: 200,
                        maxHeight: 340,
                        color: panelBg,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        body: _buildMapArea(isDark),
                        panel: _buildSlidePanel(isDark),
                        parallaxEnabled: true,
                        parallaxOffset: 0.3,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  // --- AppBar with SVG logo ---
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
            'Temukan Pedagang',
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

  // --- Search bar ---
  Widget _buildSearchBar(bool isDark) {
    final Color searchBg = isDark ? const Color(0xFF2A2A2C) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final Color hintColor = isDark
        ? const Color(0xFF9A9A9A)
        : const Color(0xFF7A7A7C);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: searchBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF5A623), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search_rounded, color: hintColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                ),
                decoration: InputDecoration(
                  hintText: 'Cari pedagang atau produk...',
                  hintStyle: TextStyle(
                    color: hintColor,
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Filter chips ---
  Widget _buildFilterChips(bool isDark) {
    final Color chipBg = isDark ? const Color(0xFF2A2A2C) : Colors.white;
    final Color chipBorderColor = isDark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFFE2E8F0);
    final Color inactiveTextColor = isDark
        ? const Color(0xFF9A9A9A)
        : const Color(0xFF7A7A7C);

    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(_filters.length, (index) {
            final selected = _selectedFilter == index;
            final Color bg = selected ? const Color(0xFFF5A623) : chipBg;
            final Color border = selected
                ? const Color(0xFFF5A623)
                : chipBorderColor;
            final Color text = selected ? Colors.white : inactiveTextColor;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    _filters[index],
                    style: TextStyle(
                      color: text,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // --- Map area with markers ---
  Widget _buildMapArea(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE8EDF2),
          child: Stack(
            children: [
              // Map background image
              Positioned.fill(
                child: Image.asset(
                  "assets/images/map_jakarta_light.png",
                  fit: BoxFit.cover,
                  color: isDark ? Colors.black.withValues(alpha: 0.7) : null,
                  colorBlendMode: isDark ? BlendMode.darken : null,
                  errorBuilder: (c, e, s) {
                    // Fallback grid if image missing
                    return CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: _MapGridPainter(isDark: isDark),
                    );
                  },
                ),
              ),
              // Map markers
              ..._pedagangList.map((p) {
                final rand = math.Random(p.id ?? 0);
                final relX = 0.2 + (rand.nextDouble() * 0.6); // 0.2 to 0.8
                final relY = 0.3 + (rand.nextDouble() * 0.4); // 0.3 to 0.7
                return _buildMapMarker(
                  p.namaToko ?? p.nama ?? 'Pedagang',
                  relX,
                  relY,
                  constraints,
                  isDark,
                  p.statusJualan ?? true,
                  p.jenisProduk ?? '',
                  p,
                );
              }),

              // Floating Search Bar & Filter Chips at the top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSearchBar(isDark),
                    _buildFilterChips(isDark),
                  ],
                ),
              ),

              // My location button
              Positioned(
                right: 16,
                bottom: 220,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2C) : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.my_location_rounded,
                    color: Color(0xFFF5A623),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapMarker(
    String name,
    double relX,
    double relY,
    BoxConstraints constraints,
    bool isDark,
    bool isActive,
    String type,
    UserModelSql seller,
  ) {
    final Color markerColor = isActive
        ? const Color(0xFFF5A623)
        : (isDark ? const Color(0xFF3A3A3C) : const Color(0xFF9E9E9E));
    final Color textColor = Colors.white;

    IconData markerIcon = Icons.storefront_rounded;
    if (type.toLowerCase().contains('minuman'))
      markerIcon = Icons.local_drink_rounded;
    if (type.toLowerCase().contains('makanan') ||
        type.toLowerCase().contains('berat'))
      markerIcon = Icons.restaurant_rounded;

    return Positioned(
      left: relX * constraints.maxWidth - 50,
      top: relY * constraints.maxHeight - 50,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BuyerStoreDetailScreen(dbSeller: seller),
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: markerColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: markerColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(markerIcon, color: textColor, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    name,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ],
              ),
            ),
            // Triangle pointer under the speech bubble
            Transform.translate(
              offset: const Offset(0, -4),
              child: Icon(
                Icons.arrow_drop_down_rounded,
                color: markerColor,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Bottom sliding panel ---
  Widget _buildSlidePanel(bool isDark) {
    final Color panelBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color dragHandleColor = isDark
        ? const Color(0xFF5A5A5C)
        : const Color(0xFFE2E8F0);
    final Color headerColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    return Container(
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 14),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: dragHandleColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedagang Aktif (${_pedagangList.where((p) => p.statusJualan == true).length})',
                  style: TextStyle(
                    color: headerColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: Color(0xFFF5A623),
                      fontSize: 13,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Horizontal pedagang cards
          SizedBox(
            height: 80,
            child: _pedagangList.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada pedagang.',
                      style: TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  )
                : ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: _pedagangList
                        .where((p) => p.statusJualan == true)
                        .map((p) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BuyerStoreDetailScreen(dbSeller: p),
                                  ),
                                );
                              },
                              child: _buildPedagangCard(
                                name: p.namaToko ?? p.nama ?? 'Pedagang',
                                distance: p.lokasi != null && p.lokasi!.isNotEmpty
                                    ? p.lokasi!
                                    : 'Tidak ada lokasi',
                                imagePath:
                                    'assets/images/tukang_bubur.png', // Placeholder
                                isDark: isDark,
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPedagangCard({
    required String name,
    required String distance,
    required String imagePath,
    required bool isDark,
  }) {
    final Color cardBg = isDark ? const Color(0xFF2A2A2C) : Colors.white;
    final Color cardBorderColor = isDark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFFE2E8F0);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final Color distanceColor = isDark
        ? const Color(0xFF9A9A9A)
        : const Color(0xFF7A7A7C);

    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardBorderColor),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isDark
                      ? const Color(0xFF3A3A3C)
                      : const Color(0xFFF1F5F9),
                  child: ClipOval(
                    child: Image.asset(
                      imagePath,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.storefront_rounded,
                        color: Color(0xFFF5A623),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // Green online indicator dot
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CD964),
                      shape: BoxShape.circle,
                      border: Border.all(color: cardBg, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFFF5A623),
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          distance,
                          style: TextStyle(
                            color: distanceColor,
                            fontSize: 11,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Fallback grid painter for map
class _MapGridPainter extends CustomPainter {
  final bool isDark;
  _MapGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = isDark ? const Color(0xFF2E2E30) : const Color(0xFFD0D8E0)
      ..strokeWidth = 0.8;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
