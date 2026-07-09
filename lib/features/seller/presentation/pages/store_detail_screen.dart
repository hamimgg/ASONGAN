import 'dart:io';
import 'package:asongan_app/core/services/firebase_product_service.dart';
import 'package:asongan_app/core/theme/app_colors.dart';
import 'package:asongan_app/features/auth/data/auth_service.dart';
import 'package:asongan_app/features/auth/data/firebase_auth_service.dart';
import 'package:asongan_app/features/auth/model/user_model_firebase.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class StoreDetailScreen extends StatefulWidget {
  const StoreDetailScreen({super.key});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  UserModelFirebase? _currentUser;
  bool _isLoading = true;

  // Form states
  File? _storeImageFile;
  final ImagePicker _picker = ImagePicker();

  bool _statusJualan = true;
  final TextEditingController _jamController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _namaTokoController = TextEditingController();

  List<String> _bestSellingMenu = [];
  List<String> _lowStockMenu = [];

  @override
  void initState() {
    super.initState();
    _loadStoreDetails();
  }

  @override
  void dispose() {
    _jamController.dispose();
    _lokasiController.dispose();
    _namaTokoController.dispose();
    super.dispose();
  }

  Future<void> _loadStoreDetails() async {
    final session = await AuthService.getUserSession();
    if (session != null && session.id != null) {
      // Ambil data terbaru dari Firestore (fallback ke session bila belum ada)
      final fbUser =
          await FirebaseAuthService().getUserById(session.id!) ?? session;

      final products =
          await FirebaseProductService().getProductsByPedagang(fbUser.id!);

      List<String> bestSelling = [];
      for (int i = 0; i < products.length && i < 3; i++) {
        bestSelling.add(products[i].namaProduk);
      }

      List<String> lowStock = [];
      for (var p in products) {
        if (p.stok < 5) {
          lowStock.add("${p.namaProduk} (Sisa ${p.stok})");
        }
      }

      File? imgFile;
      if (fbUser.fotoToko != null && fbUser.fotoToko!.isNotEmpty) {
        imgFile = File(fbUser.fotoToko!);
      }

      setState(() {
        _currentUser = fbUser;
        _statusJualan = fbUser.statusJualan ?? true;
        _jamController.text = fbUser.jamOperasional ?? '';
        _lokasiController.text = fbUser.lokasi ?? '';
        _namaTokoController.text = fbUser.namaToko ?? fbUser.nama ?? '';
        _bestSellingMenu = bestSelling;
        _lowStockMenu = lowStock;
        _storeImageFile = imgFile;
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Layanan lokasi dinonaktifkan. Silakan aktifkan GPS Anda.')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin lokasi ditolak.')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin lokasi ditolak secara permanen.')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(position.latitude, position.longitude);
      String address = "Lokasi terdeteksi";
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        final street = place.street ?? '';
        final subLocality = place.subLocality ?? '';
        final locality = place.locality ?? '';
        address = "$street, $subLocality, $locality".trim();
        address = address.replaceAll(RegExp(r'^,\s*|,\s*$'), '');
      } else {
        address = "${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}";
      }

      setState(() {
        _lokasiController.text = address;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lokasi berhasil diperbarui: $address'),
            backgroundColor: const Color(0xFF4CD964),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendapatkan lokasi: $e')),
        );
      }
    }
  }

  Future<void> _pickStoreImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _storeImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_currentUser == null) return;

    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
    );

    final updatedUser = UserModelFirebase(
      id: _currentUser!.id,
      email: _currentUser!.email,
      password: _currentUser!.password,
      telepon: _currentUser!.telepon,
      nama: _currentUser!.nama,
      role: _currentUser!.role,
      namaToko: _namaTokoController.text,
      jenisProduk: _currentUser!.jenisProduk,
      namaMakanan: _currentUser!.namaMakanan,
      statusJualan: _statusJualan,
      jamOperasional: _jamController.text,
      lokasi: _lokasiController.text,
      fotoToko: _storeImageFile != null ? _storeImageFile!.path : (_currentUser!.fotoToko ?? ''),
    );

    // Simpan pengaturan toko langsung ke Firestore (realtime untuk pembeli)
    final bool success = await FirebaseAuthService().updateUser(updatedUser);

    // Tutup loading dialog
    if (mounted) Navigator.pop(context);

    if (success) {
      await AuthService.saveUserSession(updatedUser);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaturan toko berhasil disimpan!'),
            backgroundColor: Color(0xFF4CD964),
          ),
        );
      }
      _loadStoreDetails();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan pengaturan toko'),
            backgroundColor: Color(0xFFFF3B30),
          ),
        );
      }
    }
  }

  Future<void> _selectTimeRange(BuildContext context) async {
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      helpText: 'Pilih Jam Buka',
    );

    if (startTime != null && mounted) {
      final TimeOfDay? endTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 22, minute: 0),
        helpText: 'Pilih Jam Tutup',
      );

      if (endTime != null) {
        final startFormat =
            '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
        final endFormat =
            '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
        setState(() {
          _jamController.text = '$startFormat - $endFormat';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        final Color scaffoldBg = AppColors.scaffoldBg(isDark);
        final Color cardBg = AppColors.cardBg(isDark);
        final Color cardBorder = AppColors.cardBorder(isDark);
        final Color textColor = AppColors.textPrimary(isDark);
        final Color subtitleColor = AppColors.textSubtitle(isDark);
        final Color inputFill = isDark
            ? const Color(0xFF1C1C1E)
            : const Color(0xFFF1F5F9);
        final Color inputBorder = isDark
            ? const Color(0xFF3A3A3C)
            : const Color(0xFFE2E8F0);

        return Scaffold(
          backgroundColor: scaffoldBg,
          body: Column(
            children: [
              _buildAppBar(context, isDark),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Pengaturan Toko (CRUD)
                            _buildSettingsCard(
                              isDark,
                              cardBg,
                              cardBorder,
                              textColor,
                              subtitleColor,
                              inputFill,
                              inputBorder,
                            ),
                            const SizedBox(height: 24),

                            // Menu Terlaris
                            _buildSectionHeader(
                              "Menu Terlaris",
                              Icons.local_fire_department_rounded,
                              textColor,
                            ),
                            const SizedBox(height: 12),
                            _buildListCard(
                              items: _bestSellingMenu,
                              cardBg: cardBg,
                              cardBorder: cardBorder,
                              textColor: textColor,
                              icon: Icons.star_rounded,
                              iconColor: AppColors.accent,
                            ),
                            const SizedBox(height: 24),

                            // Stok Menipis
                            _buildSectionHeader(
                              "Stok Menipis",
                              Icons.warning_amber_rounded,
                              textColor,
                            ),
                            const SizedBox(height: 12),
                            _buildListCard(
                              items: _lowStockMenu,
                              cardBg: cardBg,
                              cardBorder: cardBorder,
                              textColor: textColor,
                              icon: Icons.error_outline_rounded,
                              iconColor: AppColors.statusClosed,
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
  }

  Widget _buildSettingsCard(
    bool isDark,
    Color cardBg,
    Color cardBorder,
    Color textColor,
    Color subtitleColor,
    Color inputFill,
    Color inputBorder,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.store_rounded,
                color: AppColors.accent,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                "Pengaturan Toko",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Foto Toko Uploader UI
          Center(
            child: GestureDetector(
              onTap: _pickStoreImage,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: inputFill,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: inputBorder),
                ),
                child: _storeImageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          _storeImageFile!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : (_currentUser?.fotoToko != null && _currentUser!.fotoToko!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              File(_currentUser!.fotoToko!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.storefront_rounded,
                                      color: AppColors.accent,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Ubah Foto",
                                      style: TextStyle(
                                        color: subtitleColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                  ],
                                );
                              },
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
                                "Foto Toko",
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

          // Nama Toko
          Text(
            "Nama Toko",
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _namaTokoController,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
            ),
            decoration: InputDecoration(
              hintText: "Contoh: Warung Berkah",
              hintStyle: TextStyle(
                color: subtitleColor.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              filled: true,
              fillColor: inputFill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Switch Status Jualan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Status Jualan",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: _statusJualan
                            ? const Color(0xFF4CD964)
                            : const Color(0xFFFF3B30),
                        size: 10,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _statusJualan ? "Sedang Berjualan" : "Tutup",
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: _statusJualan,
                activeThumbColor: const Color(0xFF4CD964),
                activeTrackColor: const Color(
                  0xFF4CD964,
                ).withValues(alpha: 0.3),
                inactiveThumbColor: const Color(0xFFFF3B30),
                inactiveTrackColor: const Color(
                  0xFFFF3B30,
                ).withValues(alpha: 0.3),
                onChanged: (val) {
                  setState(() => _statusJualan = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Jam Operasional
          Text(
            "Jam Operasional",
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectTimeRange(context),
            borderRadius: BorderRadius.circular(12),
            child: IgnorePointer(
              child: TextField(
                controller: _jamController,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                ),
                decoration: InputDecoration(
                  hintText: "Contoh: 17:00 - 23:00",
                  hintStyle: TextStyle(
                    color: subtitleColor.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: inputFill,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: Icon(
                    Icons.access_time_rounded,
                    color: subtitleColor,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Lokasi Saat Ini
          Text(
            "Lokasi Saat Ini",
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _lokasiController,
            readOnly: true,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
            ),
            decoration: InputDecoration(
              hintText: "Lokasi GPS belum aktif",
              hintStyle: TextStyle(
                color: subtitleColor.withValues(alpha: 0.4),
                fontSize: 14,
              ),
              filled: true,
              fillColor: inputFill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.my_location_rounded,
                  color: AppColors.accent,
                ),
                onPressed: _updateCurrentLocation,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tombol Simpan
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.accentDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _saveSettings,
              child: const Text(
                "Simpan Pengaturan",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                ),
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
            'Detail Toko',
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

  Widget _buildSectionHeader(String title, IconData icon, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
      ],
    );
  }

  Widget _buildListCard({
    required List<String> items,
    required Color cardBg,
    required Color cardBorder,
    required Color textColor,
    required IconData icon,
    required Color iconColor,
  }) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
        ),
        child: const Center(
          child: Text(
            "Tidak ada data.",
            style: TextStyle(
              color: Color(0xFF7A7A7C),
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) =>
            Divider(color: cardBorder, height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(icon, color: iconColor, size: 18),
            title: Text(
              items[index],
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          );
        },
      ),
    );
  }
}
