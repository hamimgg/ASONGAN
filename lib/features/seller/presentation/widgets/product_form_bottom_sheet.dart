import 'dart:io';
import 'package:asongan_app/core/services/firebase_product_service.dart';
import 'package:asongan_app/features/seller/model/product_model_firebase.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductFormBottomSheet extends StatefulWidget {
  final String pedagangId;
  final ProductModelFirebase? productToEdit;
  final VoidCallback onSaved;

  const ProductFormBottomSheet({
    super.key,
    required this.pedagangId,
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
  late TextEditingController _stokController;
  late TextEditingController _kategoriController;
  late TextEditingController _variasiController;
  late bool _isTersedia;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productToEdit?.namaProduk ?? '');
    _priceController = TextEditingController(text: widget.productToEdit?.harga.toString() ?? '');
    _descController = TextEditingController(text: widget.productToEdit?.deskripsi ?? '');
    _stokController = TextEditingController(text: widget.productToEdit?.stok.toString() ?? '0');
    _kategoriController = TextEditingController(text: widget.productToEdit?.kategori ?? '');
    _variasiController = TextEditingController(text: widget.productToEdit?.variasi ?? '');
    _isTersedia = widget.productToEdit?.isTersedia ?? true;
    if (widget.productToEdit?.imagePath != null &&
        widget.productToEdit!.imagePath.isNotEmpty &&
        !widget.productToEdit!.imagePath.startsWith('assets/')) {
      _imageFile = File(widget.productToEdit!.imagePath);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _stokController.dispose();
    _kategoriController.dispose();
    _variasiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final product = ProductModelFirebase(
        id: widget.productToEdit?.id,
        pedagangId: widget.pedagangId,
        namaProduk: _nameController.text,
        harga: double.tryParse(_priceController.text) ?? 0,
        deskripsi: _descController.text,
        imagePath: _imageFile != null ? _imageFile!.path : (widget.productToEdit?.imagePath ?? ''),
        stok: int.tryParse(_stokController.text) ?? 0,
        isTersedia: _isTersedia,
        kategori: _kategoriController.text.isEmpty ? 'Umum' : _kategoriController.text,
        variasi: _variasiController.text,
      );

      String? errorMessage;
      if (widget.productToEdit == null) {
        errorMessage = await FirebaseProductService().addProduct(product);
      } else {
        errorMessage = await FirebaseProductService().updateProduct(product);
      }

      if (errorMessage == null) {
        widget.onSaved();
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan produk: $errorMessage'),
              backgroundColor: Colors.redAccent,
            ),
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
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: inputFill,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: inputBorder),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : (widget.productToEdit?.imagePath != null &&
                                    widget.productToEdit!.imagePath.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: widget.productToEdit!.imagePath.startsWith('assets/')
                                        ? Image.asset(
                                            widget.productToEdit!.imagePath,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(widget.productToEdit!.imagePath),
                                            fit: BoxFit.cover,
                                          ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_rounded,
                                        color: isDark ? const Color(0xFF5A5A5C) : const Color(0xFF9E9E9E),
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Unggah Foto",
                                        style: TextStyle(
                                          color: subtitleColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Plus Jakarta Sans',
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
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
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _kategoriController,
                    label: "Kategori Menu",
                    isDark: isDark,
                    fillColor: inputFill,
                    borderColor: inputBorder,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _variasiController,
                    label: "Variasi (Saus, Ukuran, dll)",
                    isDark: isDark,
                    fillColor: inputFill,
                    borderColor: inputBorder,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _stokController,
                    label: "Stok",
                    isDark: isDark,
                    fillColor: inputFill,
                    borderColor: inputBorder,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.isEmpty ? "Harap diisi" : null,
                  ),
                  const SizedBox(height: 16),
                  // Toggle Tersedia
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tersedia",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      Switch(
                        value: _isTersedia,
                        activeThumbColor: const Color(0xFFF5A623),
                        onChanged: (val) {
                          setState(() => _isTersedia = val);
                        },
                      ),
                    ],
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
