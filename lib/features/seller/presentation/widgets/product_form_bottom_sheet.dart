import 'package:asongan_app/features/auth/data/db_helper.dart';
import 'package:asongan_app/features/seller/model/product_model_sql.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';

class ProductFormBottomSheet extends StatefulWidget {
  final int idPedagang;
  final ProductModelSql? productToEdit;
  final VoidCallback onSaved;

  const ProductFormBottomSheet({
    super.key,
    required this.idPedagang,
    this.productToEdit,
    required this.onSaved,
  });

  @override
  State<ProductFormBottomSheet> createState() => _ProductFormBottomSheetState();
}

class _ProductFormBottomSheetState extends State<ProductFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productToEdit?.namaProduk ?? '');
    _priceController = TextEditingController(text: widget.productToEdit?.harga.toString() ?? '');
    _descController = TextEditingController(text: widget.productToEdit?.deskripsi ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final product = ProductModelSql(
        id: widget.productToEdit?.id,
        idPedagang: widget.idPedagang,
        namaProduk: _nameController.text,
        harga: double.tryParse(_priceController.text) ?? 0,
        deskripsi: _descController.text,
        imagePath: widget.productToEdit?.imagePath ?? '', // placeholder image
      );

      bool success;
      if (widget.productToEdit == null) {
        success = await DBHelper().insertProduct(product);
      } else {
        success = await DBHelper().updateProduct(product);
      }

      if (success) {
        widget.onSaved();
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menyimpan produk')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        final Color textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
        final Color subtitleColor = isDark ? const Color(0xFF9A9A9A) : const Color(0xFF7A7A7C);
        final Color inputFill = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF1F5F9);
        final Color inputBorder = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE2E8F0);

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.productToEdit == null ? "Tambah Produk" : "Edit Produk",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameController,
                    label: "Nama Produk",
                    isDark: isDark,
                    fillColor: inputFill,
                    borderColor: inputBorder,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    validator: (val) => val == null || val.isEmpty ? "Harap diisi" : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _priceController,
                    label: "Harga",
                    isDark: isDark,
                    fillColor: inputFill,
                    borderColor: inputBorder,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.isEmpty ? "Harap diisi" : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _descController,
                    label: "Deskripsi",
                    isDark: isDark,
                    fillColor: inputFill,
                    borderColor: inputBorder,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5A623),
                        foregroundColor: const Color(0xFF1C1C1E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: _save,
                      child: const Text(
                        "Simpan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ),
                  ),
                  if (!isKeyboardOpen) const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
    required Color fillColor,
    required Color borderColor,
    required Color textColor,
    required Color subtitleColor,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontFamily: 'Plus Jakarta Sans',
      ),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? const Color(0xFF5A5A5C) : const Color(0xFF9E9E9E),
          fontSize: 14,
          fontFamily: 'Plus Jakarta Sans',
        ),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF5A623), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}
