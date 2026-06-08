import 'package:asongan_app/features/auth/data/auth_service.dart';
import 'package:asongan_app/features/auth/data/db_helper.dart';
import 'package:asongan_app/features/auth/model/user_model_sql.dart';
import 'package:asongan_app/features/seller/model/product_model_sql.dart';
import 'package:asongan_app/features/seller/presentation/widgets/product_form_bottom_sheet.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class KelolaDagangan extends StatefulWidget {
  const KelolaDagangan({super.key});

  @override
  State<KelolaDagangan> createState() => _KelolaDaganganState();
}

class _KelolaDaganganState extends State<KelolaDagangan> {
  // final Color textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
  UserModelSql? _currentUser;
  List<ProductModelSql> _products = [];
  bool _isLoading = true;

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
          // appBar: _buildAppBar(context, isDark),
          // body: _buildTambahMenu(isDark),
          body: Column(
            children: [
              _buildAppBar(context, isDark),
              Expanded(child: _buildTambahMenu(isDark)),
            ],
          ),
          // appBar: AppBar(
          //   backgroundColor: appBg,
          //   // elevation: 0,
          // title: Text(
          //   "Kelola Dagangan",
          //   style: TextStyle(
          //     fontWeight: FontWeight.bold,
          //     color: textColor,
          //     fontSize: 17,
          //     fontFamily: 'Plus Jakarta Sans',
          //   ),
          // ),
          // actions: [
          //   IconButton(
          //     onPressed: () => Scaffold.of(context).openEndDrawer(),
          //     icon: Icon(Icons.menu_rounded, color: iconColor),
          //   ),
          // ],
          // bottom: PreferredSize(
          //   preferredSize: const Size.fromHeight(1),
          //   child: Container(
          //     color: cardBorderColor,
          //     height: 1,
          //     padding: EdgeInsets.only(
          //       top: MediaQuery.of(context).padding.top + 12,
          //       left: 12,
          //       right: 12,
          //       bottom: 12,
          //     ),
          //   ),
          // ),

          // ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFFF5A623),
            foregroundColor: const Color(0xFF1C1C1E),
            onPressed: () => _showFormBottomSheet(isDark),
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }

  Widget _buildTambahMenu(bool isDark) {
    // final Color chipBg = isDark ? const Color(0xFF2A2A2C) : Colors.white;
    //     final Color chipBorderColor = isDark
    //         ? const Color(0xFF3A3A3C)
    //         : const Color(0xFFE2E8F0);
    //     final Color inactiveTextColor = isDark
    //         ? const Color(0xFF9A9A9A)
    //         : const Color(0xFF7A7A7C);
    final Color subtitleColor = isDark
        ? const Color(0xFF9A9A9A)
        : const Color(0xFF7A7A7C);
    final Color cardBg = isDark ? const Color(0xFF2A2A2C) : Colors.white;
    final Color cardBorderColor = isDark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFFE2E8F0);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFF5A623)),
          )
        : _products.isEmpty
        ? Center(
            child: Text(
              "Belum ada produk.",
              style: TextStyle(
                color: subtitleColor,
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final p = _products[index];
              return Card(
                color: cardBg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: cardBorderColor),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1C1C1E)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.fastfood_rounded,
                          color: Color(0xFFF5A623),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.namaProduk,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Rp ${p.harga.toStringAsFixed(0)}",
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_rounded,
                              color: Colors.blue,
                            ),
                            onPressed: () =>
                                _showFormBottomSheet(isDark, productToEdit: p),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_rounded,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              if (p.id != null) {
                                await DBHelper().deleteProduct(p.id!);
                                _loadData();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
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
            'Kelola Dagangan',
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
}
