import 'dart:io';

import 'package:asongan_app/core/theme/app_colors.dart';
import 'package:asongan_app/features/auth/data/db_helper.dart';
import 'package:asongan_app/features/auth/model/user_model_sql.dart';
import 'package:asongan_app/features/buyer/model/buyer_dummy_data.dart';
import 'package:asongan_app/features/buyer/presentation/pages/buyer_product_detail_screen.dart';
import 'package:asongan_app/features/buyer/presentation/pages/buyer_store_detail_screen.dart';
import 'package:asongan_app/features/seller/model/product_model_sql.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  List<ProductModelSql> _dbProducts = [];
  List<UserModelSql> _dbSellers = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final products = await DBHelper().getAllProducts();
    final sellers = await DBHelper().getAllPedagang();
    setState(() {
      _dbProducts = products;
      _dbSellers = sellers;
      _isLoadingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        final Color scaffoldBg = AppColors.scaffoldBg(isDark);
        final Color textColor = AppColors.textPrimary(isDark);

        return Scaffold(
          backgroundColor: scaffoldBg,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context, isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBanner(context),
                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        'Pedagang Terdekat',
                        textColor,
                        hasSeeAll: true,
                      ),
                      const SizedBox(height: 12),
                      _buildNearbySellers(isDark),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Rekomendasi Produk', textColor),
                      const SizedBox(height: 12),
                      _buildRecommendedProducts(isDark),
                    ],
                  ),
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
            'Beranda',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const Spacer(),
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

  Widget _buildBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF1C1C1E),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/tukang_bubur.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Temukan Jajanan Favoritmu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Jelajahi pedagang asongan terdekat dari\nposisimu.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                      fontFamily: 'Plus Jakarta Sans',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    Color textColor, {
    bool hasSeeAll = false,
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          if (hasSeeAll)
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                "Lihat Semua",
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNearbySellers(bool isDark) {
    if (_isLoadingData) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    final totalCount = _dbSellers.length + dummyNearbySellers.length;

    return SizedBox(
      height: 200,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: totalCount,
        itemBuilder: (context, index) {
          String name;
          bool isSelling;
          String distance;
          double rating;

          String? fotoToko;

          if (index < _dbSellers.length) {
            final seller = _dbSellers[index];
            name = seller.namaToko ?? seller.nama ?? 'Pedagang';
            isSelling = seller.statusJualan == true;
            distance = seller.lokasi != null && seller.lokasi!.isNotEmpty
                ? seller.lokasi!
                : "Tidak ada lokasi";
            rating = 4.8; // Dummy value
            fotoToko = seller.fotoToko;
          } else {
            final dummyIndex = index - _dbSellers.length;
            final seller = dummyNearbySellers[dummyIndex];
            name = seller.name;
            isSelling = seller.isSelling;
            distance = seller.distance;
            rating = seller.rating;
            fotoToko = seller.imagePath;
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuyerStoreDetailScreen(
                    dbSeller: (index < _dbSellers.length)
                        ? _dbSellers[index]
                        : null,
                    dummySeller: (index >= _dbSellers.length)
                        ? dummyNearbySellers[index - _dbSellers.length]
                        : null,
                  ),
                ),
              );
            },
            child: Container(
              width: 240,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBg(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder(isDark)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Image with Status badge
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            color: AppColors.inputFill(isDark),
                          ),
                          width: double.infinity,
                          child: fotoToko != null && fotoToko.isNotEmpty
                              ? (fotoToko.startsWith('assets/')
                                  ? ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(15),
                                      ),
                                      child: Image.asset(
                                        fotoToko,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(15),
                                      ),
                                      child: Image.file(
                                        File(fotoToko),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            "assets/images/tukang_siomay.png",
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ))
                              : Image.asset(
                                  "assets/images/tukang_siomay.png",
                                  fit: BoxFit.cover,
                                ),
                        ),
                        if (isSelling)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.statusActive,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.white,
                                    size: 8,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Sedang Berjualan",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Bottom Info
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    color: AppColors.textPrimary(isDark),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.accent,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    rating.toString(),
                                    style: TextStyle(
                                      color: AppColors.textPrimary(isDark),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.near_me_rounded,
                                color: AppColors.textSubtitle(isDark),
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                distance,
                                style: TextStyle(
                                  color: AppColors.textSubtitle(isDark),
                                  fontSize: 11,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendedProducts(bool isDark) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    if (_isLoadingData) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    final totalCount = _dbProducts.length + dummyRecommendedProducts.length;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        String name;
        double price;
        bool isTersedia;
        String imagePath;
        bool isLocalImage;

        if (index < _dbProducts.length) {
          final product = _dbProducts[index];
          name = product.namaProduk;
          price = product.harga;
          isTersedia = product.isTersedia;
          imagePath = product.imagePath;
          isLocalImage =
              imagePath.isNotEmpty && !imagePath.startsWith('assets/');
        } else {
          final dummyIndex = index - _dbProducts.length;
          final product = dummyRecommendedProducts[dummyIndex];
          name = product.name;
          price = product.price.toDouble();
          isTersedia = true; // Dummy products are always available
          imagePath = product.imagePath; // Fallback dummy image
          isLocalImage = false;
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BuyerProductDetailScreen(
                  dbProduct: (index < _dbProducts.length)
                      ? _dbProducts[index]
                      : null,
                  dummyProduct: (index >= _dbProducts.length)
                      ? dummyRecommendedProducts[index - _dbProducts.length]
                      : null,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder(isDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          color: AppColors.inputFill(isDark),
                        ),
                        child: imagePath.isNotEmpty
                            ? ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: isLocalImage
                                    ? Image.file(
                                        File(imagePath),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Center(
                                                child: Icon(
                                                  Icons.fastfood_rounded,
                                                  size: 40,
                                                  color:
                                                      AppColors.iconSecondary(
                                                        isDark,
                                                      ),
                                                ),
                                              );
                                            },
                                      )
                                    : Image.asset(
                                        imagePath,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Center(
                                                child: Icon(
                                                  Icons.fastfood_rounded,
                                                  size: 40,
                                                  color:
                                                      AppColors.iconSecondary(
                                                        isDark,
                                                      ),
                                                ),
                                              );
                                            },
                                      ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.fastfood_rounded,
                                  size: 40,
                                  color: AppColors.iconSecondary(isDark),
                                ),
                              ),
                      ),
                      // Badge tersedia/habis
                      if (!isTersedia)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.statusClosed,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "Habis",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Product Info
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: AppColors.textPrimary(isDark),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatCurrency.format(price),
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
