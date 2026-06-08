import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DummyPedagang {
  final String namaToko;
  final String jenisProduk;
  final String namaMakanan;
  final int stokAwal;
  final int sisaStok;
  final bool isBerjualan;

  DummyPedagang({
    required this.namaToko,
    required this.jenisProduk,
    required this.namaMakanan,
    required this.stokAwal,
    required this.sisaStok,
    required this.isBerjualan,
  });
}

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final List<DummyPedagang> dummyData = [
    DummyPedagang(
      namaToko: "Siomay Hoki",
      jenisProduk: "Makanan Berat",
      namaMakanan: "Siomay & Batagor",
      stokAwal: 100,
      sisaStok: 25,
      isBerjualan: true,
    ),
    DummyPedagang(
      namaToko: "Bubur Ayam 77",
      jenisProduk: "Makanan Berat",
      namaMakanan: "Bubur Ayam",
      stokAwal: 200,
      sisaStok: 150,
      isBerjualan: true,
    ),
    DummyPedagang(
      namaToko: "Cimol Bojot Neng Putri",
      jenisProduk: "Makanan Ringan",
      namaMakanan: "Cimol & Basreng",
      stokAwal: 80,
      sisaStok: 0,
      isBerjualan: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        final Color scaffoldBg = isDark
            ? const Color(0xFF1C1C1E)
            : const Color(0xFFF8F9FA);
        final Color appBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;

        final Color iconColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

        return Scaffold(
          backgroundColor: scaffoldBg,
          body: Column(
            children: [
              _buildAppBar(context, isDark),
              Expanded(child: _builderTambahMenu(isDark)),
            ],
          ),
        );
      },
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
            'Detail Toko',
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

  Widget _builderTambahMenu(bool isDark) {
    final Color cardBg = isDark ? const Color(0xFF2A2A2C) : Colors.white;
    final Color cardBorderColor = isDark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFFE2E8F0);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final Color subtitleColor = isDark
        ? const Color(0xFF9A9A9A)
        : const Color(0xFF7A7A7C);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: dummyData.length,
      itemBuilder: (context, index) {
        final pedagang = dummyData[index];
        return Card(
          color: cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cardBorderColor),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        pedagang.namaToko,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: pedagang.isBerjualan
                            ? const Color(0xFF4CD964).withValues(alpha: 0.15)
                            : const Color(0xFFFF3B30).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        pedagang.isBerjualan ? "Berjualan" : "Tutup",
                        style: TextStyle(
                          color: pedagang.isBerjualan
                              ? const Color(0xFF4CD964)
                              : const Color(0xFFFF3B30),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  pedagang.namaMakanan,
                  style: const TextStyle(
                    color: Color(0xFFF5A623),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Jenis: ${pedagang.jenisProduk}",
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Stok",
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 11,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${pedagang.stokAwal}",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Sisa Stok",
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 11,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${pedagang.sisaStok}",
                          style: TextStyle(
                            color: pedagang.sisaStok > 10
                                ? textColor
                                : const Color(0xFFFF3B30),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: pedagang.stokAwal > 0
                      ? pedagang.sisaStok / pedagang.stokAwal
                      : 0,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    pedagang.sisaStok > 10
                        ? const Color(0xFFF5A623)
                        : const Color(0xFFFF3B30),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  minHeight: 6,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
