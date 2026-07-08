import 'dart:io';
import 'package:asongan_app/core/theme/app_colors.dart';
import 'package:asongan_app/features/auth/data/firebase_auth_service.dart';
import 'package:asongan_app/features/auth/model/user_model_firebase.dart';
import 'package:asongan_app/core/services/firebase_product_service.dart';
import 'package:asongan_app/features/seller/model/product_model_firebase.dart';
import 'package:asongan_app/features/buyer/presentation/pages/buyer_store_detail_screen.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        final Color scaffoldBg = AppColors.scaffoldBg(isDark);

        return Scaffold(
          backgroundColor: scaffoldBg,
          body: Column(
            children: [
              _buildAppBar(context, isDark),
              Expanded(
                // Realtime: daftar pedagang + total produk masing-masing toko
                child: StreamBuilder<List<UserModelFirebase>>(
                  stream: FirebaseAuthService().streamAllPedagang(),
                  builder: (context, pedagangSnap) {
                    if (pedagangSnap.connectionState ==
                            ConnectionState.waiting &&
                        !pedagangSnap.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFF5A623),
                        ),
                      );
                    }
                    final pedagangList = pedagangSnap.data ?? [];

                    return StreamBuilder<List<ProductModelFirebase>>(
                      stream: FirebaseProductService().streamAllProducts(),
                      builder: (context, productSnap) {
                        final allProducts = productSnap.data ?? [];
                        final Map<String, int> stokMap = {};
                        for (final prod in allProducts) {
                          stokMap[prod.pedagangId] =
                              (stokMap[prod.pedagangId] ?? 0) + prod.stok;
                        }
                        return _builderTambahMenu(
                          isDark,
                          pedagangList,
                          stokMap,
                        );
                      },
                    );
                  },
                ),
              ),
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
          SvgPicture.asset(
            "assets/images/logo_asongan.svg",
            width: 32,
            height: 32,
            semanticsLabel: "logo asongan",
          ),
          const SizedBox(width: 10),
          Text(
            'Toko Pedagang',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const Spacer(),

          IconButton(
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            icon: Icon(Icons.menu_rounded, color: iconColor, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _builderTambahMenu(
    bool isDark,
    List<UserModelFirebase> pedagangList,
    Map<String, int> totalStokMap,
  ) {
    final Color cardBg = isDark ? const Color(0xFF2A2A2C) : Colors.white;
    final Color cardBorderColor = isDark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFFE2E8F0);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final Color subtitleColor = isDark
        ? const Color(0xFF9A9A9A)
        : const Color(0xFF7A7A7C);

    final totalCount = pedagangList.length;

    if (totalCount == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 64, color: subtitleColor),
            const SizedBox(height: 16),
            Text(
              "Belum ada pedagang terdaftar.",
              style: TextStyle(
                color: subtitleColor,
                fontSize: 15,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        final pedagang = pedagangList[index];
        final String name = pedagang.namaToko ?? pedagang.nama ?? 'Toko Asongan';
        final bool isBerjualan = pedagang.statusJualan ?? true;
        final String? fotoToko = pedagang.fotoToko;
        final String jamOperasional = pedagang.jamOperasional == null || pedagang.jamOperasional!.isEmpty ? 'Tidak ditentukan' : pedagang.jamOperasional!;
        final String lokasi = pedagang.lokasi ?? '';
        final String jenisProduk = pedagang.namaMakanan ?? pedagang.jenisProduk ?? 'Makanan & Minuman';
        final int totalStok = totalStokMap[pedagang.id] ?? 0;

        return Card(
          color: cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cardBorderColor),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuyerStoreDetailScreen(
                    seller: pedagang,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store Photo
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cardBorderColor),
                        ),
                        child: fotoToko != null && fotoToko.isNotEmpty
                            ? (fotoToko.startsWith('assets/')
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(11),
                                    child: Image.asset(
                                      fotoToko,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(11),
                                    child: Image.file(
                                      File(fotoToko),
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => const Icon(
                                        Icons.storefront_rounded,
                                        color: AppColors.accent,
                                        size: 30,
                                      ),
                                    ),
                                  ))
                            : const Icon(
                                Icons.storefront_rounded,
                                color: AppColors.accent,
                                size: 30,
                              ),
                      ),
                      const SizedBox(width: 16),
                      // Store Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
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
                                    color: isBerjualan
                                        ? const Color(0xFF4CD964).withValues(alpha: 0.15)
                                        : const Color(0xFFFF3B30).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isBerjualan ? "Berjualan" : "Tutup",
                                    style: TextStyle(
                                      color: isBerjualan
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
                              jenisProduk,
                              style: const TextStyle(
                                color: Color(0xFFF5A623),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: subtitleColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Jam Operasional: $jamOperasional",
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ],
                  ),
                  if (lokasi.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.pin_drop_rounded,
                          color: subtitleColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Lokasi: $lokasi",
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 12,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Produk",
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 11,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "$totalStok",
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
                            "Status Toko",
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 11,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isBerjualan ? "Buka" : "Tutup",
                            style: TextStyle(
                              color: isBerjualan
                                  ? const Color(0xFF4CD964)
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
