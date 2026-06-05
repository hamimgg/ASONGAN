import 'package:asongan_app/features/auth/data/db_helper.dart';
import 'package:asongan_app/features/seller/model/product_model_sql.dart';
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
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Nama Produk",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF2C2C2E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? "Harap diisi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Harga",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF2C2C2E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? "Harap diisi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Deskripsi",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF2C2C2E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xfff5a623),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _save,
                  child: const Text("Simpan", style: TextStyle(color: Colors.white)),
                ),
              ),
              if (!isKeyboardOpen) const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
