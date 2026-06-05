import 'package:asongan_app/features/auth/data/auth_service.dart';
import 'package:asongan_app/features/seller/presentation/widgets/product_form_bottom_sheet.dart';
import 'package:asongan_app/features/auth/data/db_helper.dart';
import 'package:asongan_app/features/auth/model/user_model_sql.dart';
import 'package:asongan_app/features/seller/model/product_model_sql.dart';
import 'package:flutter/material.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
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

  void _showFormBottomSheet({ProductModelSql? productToEdit}) {
    if (_currentUser == null || _currentUser!.id == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xff1c1c1e),
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff1c1c1e),
        title: Text(
          "Kelola Dagangan",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            icon: const Icon(Icons.menu_rounded, color: Color(0xffffffff)),
          ),
        ],
      ),
      backgroundColor: const Color(0xff1c1c1e),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada produk.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final p = _products[index];
                    return ListTile(
                      title: Text(p.namaProduk, style: TextStyle(color: Colors.white)),
                      subtitle: Text("Rp ${p.harga}", style: TextStyle(color: Colors.white70)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showFormBottomSheet(productToEdit: p),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              if (p.id != null) {
                                await DBHelper().deleteProduct(p.id!);
                                _loadData();
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xfff5a623),
        onPressed: () => _showFormBottomSheet(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
