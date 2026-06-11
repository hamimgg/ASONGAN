import 'dart:io';

import 'package:asongan_app/core/theme/app_colors.dart';
import 'package:asongan_app/features/buyer/model/buyer_dummy_data.dart';
import 'package:asongan_app/features/seller/model/product_model_sql.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BuyerProductDetailScreen extends StatelessWidget {
  final ProductModelSql? dbProduct;
  final RecommendedProduct? dummyProduct;

  const BuyerProductDetailScreen({
    super.key,
    this.dbProduct,
    this.dummyProduct,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        final Color scaffoldBg = AppColors.scaffoldBgPure(isDark);
        final Color textColor = AppColors.textPrimary(isDark);
        final Color subtitleColor = AppColors.textSubtitle(isDark);
        final Color cardBorder = AppColors.divider(isDark);

        final bool isReal = dbProduct != null;

        final String pName = isReal
            ? dbProduct!.namaProduk
            : dummyProduct!.name;
        final double pPrice = isReal
            ? dbProduct!.harga
            : dummyProduct!.price.toDouble();
        final String pImage = isReal
            ? dbProduct!.imagePath
            : dummyProduct!.imagePath;
        final bool pIsLocal =
            isReal && pImage.isNotEmpty && !pImage.startsWith('assets/');
        final String pDesc = isReal
            ? (dbProduct!.deskripsi ?? "Tidak ada deskripsi.")
            : "Nikmati jajanan khas yang lezat ini. Dibuat dengan bahan-bahan pilihan yang segar.";

        final String pKategori = isReal
            ? (dbProduct!.kategori ?? "Umum")
            : "Makanan ringan";
        final String pVariasi = isReal
            ? (dbProduct!.variasi ?? "Tidak ada variasi")
            : "Standar";
        final bool isAvailable = isReal ? dbProduct!.isTersedia : true;

        final formatCurrency = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            backgroundColor: scaffoldBg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: textColor,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Detail Produk",
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Container(
                        width: double.infinity,
                        height: 280,
                        color: AppColors.inputFill(isDark),
                        child: pImage.isNotEmpty
                            ? (pIsLocal
                                  ? Image.file(File(pImage), fit: BoxFit.cover)
                                  : Image.asset(pImage, fit: BoxFit.cover))
                            : Icon(
                                Icons.fastfood_rounded,
                                color: subtitleColor,
                                size: 80,
                              ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    pName,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                  ),
                                ),
                                if (!isAvailable)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.statusClosed.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      "Habis",
                                      style: TextStyle(
                                        color: AppColors.statusClosed,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatCurrency.format(pPrice),
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Info Tags
                            Row(
                              children: [
                                _buildInfoTag(
                                  Icons.category_rounded,
                                  pKategori,
                                  isDark,
                                ),
                                const SizedBox(width: 12),
                                _buildInfoTag(
                                  Icons.tune_rounded,
                                  pVariasi,
                                  isDark,
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                            Text(
                              "Deskripsi",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              pDesc,
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 14,
                                height: 1.5,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar
              Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                ),
                decoration: BoxDecoration(
                  color: scaffoldBg,
                  border: Border(top: BorderSide(color: cardBorder)),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.accent),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.favorite_border_rounded,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isAvailable
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '$pName berhasil ditambahkan ke pesanan!',
                                      ),
                                      backgroundColor: const Color(0xFF4CD964),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: subtitleColor.withValues(
                              alpha: 0.3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Tambah ke Pesanan",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTag(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder(isDark)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSubtitle(isDark)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textPrimary(isDark),
              fontSize: 12,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ],
      ),
    );
  }
}
