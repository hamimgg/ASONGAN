import 'dart:io';

import 'package:asongan_app/core/theme/app_colors.dart';
import 'package:asongan_app/features/auth/data/auth_service.dart';
import 'package:asongan_app/features/auth/data/db_helper.dart';
import 'package:asongan_app/features/auth/model/user_model_sql.dart';
import 'package:asongan_app/features/seller/model/product_model_sql.dart';
import 'package:asongan_app/features/seller/presentation/widgets/product_form_bottom_sheet.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class KelolaDagangan extends StatefulWidget {
  const KelolaDagangan({super.key});

  @override
  State<KelolaDagangan> createState() => _KelolaDaganganState();
}

class _KelolaDaganganState extends State<KelolaDagangan> {
  UserModelSql? _currentUser;
  List<ProductModelSql> _products = [];
  bool _isLoading = true;

  final formatCurrency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await AuthService.getUserSession();
    if (user != null && user.id != null) {
      final products = await DBHelper().getProductsByPedagang(user.id!);
      setState(() {
        _currentUser = user;
        _products = products;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _showFormBottomSheet(bool isDark, {ProductModelSql? productToEdit}) {
    if (_currentUser == null || _currentUser!.id == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xff1c1c1e) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ProductFormBottomSheet(
          idPedagang: _currentUser!.id!,
          productToEdit: productToEdit,
          onSaved: () => _loadData(),
        );
      },
    );
  }

  void _confirmDelete(ProductModelSql product, bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2A2A2C) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Hapus Produk",
            style: TextStyle(
              color: AppColors.textPrimary(isDark),
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          content: Text(
            "Yakin ingin menghapus \"${product.namaProduk}\"?",
            style: TextStyle(
              color: AppColors.textSubtitle(isDark),
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Batal",
                style: TextStyle(
                  color: AppColors.textSubtitle(isDark),
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (product.id != null) {
                  await DBHelper().deleteProduct(product.id!);
                  _loadData();
                }
              },
              child: const Text(
                "Hapus",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
              Expanded(child: _buildGroupedProductList(isDark)),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.accentDark,
            onPressed: () => _showFormBottomSheet(isDark),
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }

  Widget _buildGroupedProductList(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 64,
              color: AppColors.textSubtitle(isDark),
            ),
            const SizedBox(height: 16),
            Text(
              "Belum ada produk.",
              style: TextStyle(
                color: AppColors.textSubtitle(isDark),
                fontSize: 15,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tambahkan produk pertamamu!",
              style: TextStyle(
                color: AppColors.textSubtitle(isDark).withValues(alpha: 0.6),
                fontSize: 13,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ],
        ),
      );
    }

    Map<String, List<ProductModelSql>> groupedProducts = {};
    for (var p in _products) {
      if (!groupedProducts.containsKey(p.kategori)) {
        groupedProducts[p.kategori] = [];
      }
      groupedProducts[p.kategori]!.add(p);
    }

    final categories = groupedProducts.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryProducts = groupedProducts[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),

              // padding: const EdgeInsets.only(bottom: 12, top: index == 0 ? 0 : 16),
              child: Row(
                children: [
                  Icon(
                    Icons.restaurant_menu_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category,
                    style: TextStyle(
                      color: AppColors.textPrimary(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.58,
              ),
              itemCount: categoryProducts.length,
              itemBuilder: (context, pIndex) {
                final p = categoryProducts[pIndex];
                return _buildProductCard(p, isDark);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(ProductModelSql p, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto Produk
          Expanded(
            flex: 4,
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
                  child: p.imagePath.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: p.imagePath.startsWith('assets/')
                              ? Image.asset(
                                  p.imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.fastfood_rounded,
                                        color: AppColors.accent,
                                        size: 36,
                                      ),
                                    );
                                  },
                                )
                              : Image.file(
                                  File(p.imagePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.fastfood_rounded,
                                        color: AppColors.accent,
                                        size: 36,
                                      ),
                                    );
                                  },
                                ),
                        )
                      : Center(
                          child: Icon(
                            Icons.fastfood_rounded,
                            color: AppColors.accent,
                            size: 36,
                          ),
                        ),
                ),
                // Badge status
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: p.isTersedia
                          ? AppColors.statusActive
                          : AppColors.statusClosed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      p.isTersedia ? "Tersedia" : "Habis",
                      style: const TextStyle(
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

          // Info Produk
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Produk
                  Text(
                    p.namaProduk,
                    style: TextStyle(
                      color: AppColors.textPrimary(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Harga
                  Text(
                    formatCurrency.format(p.harga),
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Stok
                  Text(
                    "Stok: ${p.stok}",
                    style: TextStyle(
                      color: AppColors.textSubtitle(isDark),
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  if (p.variasi.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      p.variasi,
                      style: TextStyle(
                        color: AppColors.textSubtitle(
                          isDark,
                        ).withValues(alpha: 0.8),
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const Spacer(),
                  // Tombol Edit & Hapus
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              _showFormBottomSheet(isDark, productToEdit: p),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_rounded,
                                  color: Colors.blue,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Edit",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => _confirmDelete(p, isDark),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete_rounded,
                                  color: Colors.red,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Hapus",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                              ],
                            ),
                          ),
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
            'Kelola Dagangan',
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
}
