import 'dart:io';

import 'package:asongan_app/core/theme/app_colors.dart';
import 'package:asongan_app/features/seller/model/product_model_firebase.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BuyerProductDetailScreen extends StatefulWidget {
  final ProductModelFirebase product;

  const BuyerProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<BuyerProductDetailScreen> createState() => _BuyerProductDetailScreenState();
}

class _BuyerProductDetailScreenState extends State<BuyerProductDetailScreen> {
  bool _isFavorited = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        final Color scaffoldBg = AppColors.scaffoldBgPure(isDark);
        final Color textColor = AppColors.textPrimary(isDark);
        final Color subtitleColor = AppColors.textSubtitle(isDark);
        final Color cardBorder = AppColors.divider(isDark);

        final String pName = widget.product.namaProduk;
        final double pPrice = widget.product.harga;
        final String pImage = widget.product.imagePath;
        final bool pIsLocal =
            pImage.isNotEmpty && !pImage.startsWith('assets/');
        final String pDesc = widget.product.deskripsi.isNotEmpty
            ? widget.product.deskripsi
            : "Tidak ada deskripsi.";

        final String pKategori = widget.product.kategori.isNotEmpty
            ? widget.product.kategori
            : "Umum";
        final String pVariasi = widget.product.variasi.isNotEmpty
            ? widget.product.variasi
            : "Tidak ada variasi";
        final bool isAvailable = widget.product.isTersedia;

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
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isFavorited = !_isFavorited;
                      });
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isFavorited
                                ? '$pName ditambahkan ke favorit!'
                                : '$pName dihapus dari favorit!',
                          ),
                          backgroundColor: _isFavorited
                              ? const Color(0xFFFF2D55)
                              : AppColors.textSubtitle(isDark),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _isFavorited ? const Color(0xFFFF2D55) : AppColors.accent,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: _isFavorited ? const Color(0xFFFF2D55) : AppColors.accent,
                    ),
                    child: Icon(
                      _isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isFavorited ? const Color(0xFFFF2D55) : AppColors.accent,
                    ),
                  ),
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
