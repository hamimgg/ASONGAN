import 'dart:io';

import 'package:asongan_app/core/theme/app_colors.dart';
import 'package:asongan_app/features/auth/data/firebase_auth_service.dart';
import 'package:asongan_app/features/auth/model/user_model_firebase.dart';
import 'package:asongan_app/features/buyer/presentation/pages/buyer_product_detail_screen.dart';
import 'package:asongan_app/features/seller/model/product_model_firebase.dart';
import 'package:asongan_app/core/services/firebase_product_service.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyerStoreDetailScreen extends StatefulWidget {
  final UserModelFirebase seller;

  const BuyerStoreDetailScreen({super.key, required this.seller});

  @override
  State<BuyerStoreDetailScreen> createState() => _BuyerStoreDetailScreenState();
}

class _BuyerStoreDetailScreenState extends State<BuyerStoreDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        final Color scaffoldBg = AppColors.scaffoldBg(isDark);
        final Color textColor = AppColors.textPrimary(isDark);
        final Color subtitleColor = AppColors.textSubtitle(isDark);
        final Color cardBg = AppColors.cardBg(isDark);
        final Color cardBorder = AppColors.cardBorder(isDark);

        return StreamBuilder<UserModelFirebase?>(
          stream: widget.seller.id != null
              ? FirebaseAuthService().streamUserById(widget.seller.id!)
              : const Stream.empty(),
          builder: (context, snapshot) {
            final seller = snapshot.data ?? widget.seller;

            final String storeName = (seller.namaToko != null &&
                      seller.namaToko!.isNotEmpty)
                  ? seller.namaToko!
                  : (seller.nama ?? 'Pedagang');

            final bool isSelling = seller.statusJualan == true;

            final String distance = (seller.lokasi != null &&
                      seller.lokasi!.isNotEmpty)
                  ? seller.lokasi!
                  : "Lokasi tidak diketahui";

            final double rating = 4.8;
            final String imagePath = seller.fotoToko ?? 'assets/images/tukang_bubur.png';
            final String? fotoToko = seller.fotoToko;

            // Fallback info
            const String since = "2024";
            const String aboutStore =
                "Toko keliling terpercaya, menyajikan jajanan enak dan bersih setiap harinya. Melayani pesanan di sekitar area ini dengan cepat.";

            return Scaffold(
              backgroundColor: scaffoldBg,
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 220.0,
                    pinned: true,
                    backgroundColor: scaffoldBg,
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          fotoToko != null && fotoToko.isNotEmpty
                              ? (fotoToko.startsWith('assets/')
                                  ? Image.asset(fotoToko, fit: BoxFit.cover)
                                  : Image.file(
                                      File(fotoToko),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/tukang_bubur.png',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ))
                              : Image.asset(imagePath, fit: BoxFit.cover),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  scaffoldBg.withValues(alpha: 0.8),
                                  scaffoldBg,
                                ],
                                stops: const [0.4, 0.8, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Store Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      storeName,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelling
                                                ? AppColors.statusActive.withValues(
                                                    alpha: 0.15,
                                                  )
                                                : AppColors.statusClosed.withValues(
                                                    alpha: 0.15,
                                                  ),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            isSelling ? "Buka" : "Tutup",
                                            style: TextStyle(
                                              color: isSelling
                                                  ? AppColors.statusActive
                                                  : AppColors.statusClosed,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Plus Jakarta Sans',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.star_rounded,
                                          color: AppColors.accent,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          rating.toString(),
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.access_time_rounded,
                                          color: subtitleColor,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Sejak $since",
                                          style: TextStyle(
                                            color: subtitleColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: subtitleColor,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  distance,
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: 13,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Tentang Toko",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            aboutStore,
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 13,
                              height: 1.5,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                String telepon = seller.telepon ?? '81234567890';
                                // Clean up phone number (remove leading 0 if present)
                                if (telepon.startsWith('0')) {
                                  telepon = telepon.substring(1);
                                } else if (telepon.startsWith('62')) {
                                  telepon = telepon.substring(2);
                                }
                                
                                final uri = Uri.parse("https://wa.me/62${telepon}?text=Halo, saya tertarik dengan dagangan Anda di Asongan!");
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                              icon: const Icon(Icons.chat_rounded),
                              label: const Text(
                                "Hubungi via WhatsApp",
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            "Menu Pilihan",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                          const SizedBox(height: 16),
                          StreamBuilder<List<ProductModelFirebase>>(
                            stream: seller.id != null
                                ? FirebaseProductService()
                                    .streamProductsByPedagang(seller.id!)
                                : const Stream.empty(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting &&
                                  !snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.accent,
                                  ),
                                );
                              }
                              final dbProducts = snapshot.data ?? [];
                              if (dbProducts.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 32.0),
                                    child: Text(
                                      "Toko ini belum memiliki menu.",
                                      style: TextStyle(color: subtitleColor),
                                    ),
                                  ),
                                );
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: dbProducts.length,
                                itemBuilder: (context, index) {
                                  final p = dbProducts[index];
                                final String pName = p.namaProduk;
                                final double pPrice = p.harga;
                                final String pImage = p.imagePath;
                                final bool pIsLocal =
                                    pImage.isNotEmpty &&
                                    !pImage.startsWith('assets/');
                                final bool pTersedia = p.isTersedia;

                                final formatCurrency = NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                );

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BuyerProductDetailScreen(
                                              product: p,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: cardBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            color: AppColors.inputFill(isDark),
                                          ),
                                          child: pImage.isNotEmpty
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: pIsLocal
                                                      ? Image.file(
                                                          File(pImage),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Image.asset(
                                                          pImage,
                                                          fit: BoxFit.cover,
                                                        ),
                                                )
                                              : Icon(
                                                  Icons.fastfood_rounded,
                                                  color: subtitleColor,
                                                  size: 30,
                                                ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                pName,
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Plus Jakarta Sans',
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                formatCurrency.format(pPrice),
                                                style: const TextStyle(
                                                  color: AppColors.accent,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Plus Jakarta Sans',
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              if (!pTersedia)
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.statusClosed
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                  ),
                                                  child: const Text(
                                                    "Habis",
                                                    style: TextStyle(
                                                      color: AppColors.statusClosed,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent.withValues(
                                              alpha: 0.1,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.add_rounded,
                                            color: AppColors.accent,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
