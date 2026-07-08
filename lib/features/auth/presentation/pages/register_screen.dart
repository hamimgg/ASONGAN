import 'package:asongan_app/core/animations/animation_background.dart';
import 'package:asongan_app/features/auth/data/firebase_auth_service.dart';
import 'package:asongan_app/features/auth/model/user_model_firebase.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';
import 'package:asongan_app/features/auth/data/db_helper.dart';

class RegisterPage extends StatefulWidget {
  final bool isPedagang;
  const RegisterPage({super.key, required this.isPedagang});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController namaTokoController = TextEditingController();
  final TextEditingController namaMakananController = TextEditingController();
  String? jenisProduk;
  bool _isAgreeTc = false;

  final List<String> listJenisProduk = [
    'Makanan Berat',
    'Makanan Ringan',
    'Minuman',
  ];

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    teleponController.dispose();
    passwordController.dispose();
    namaTokoController.dispose();
    namaMakananController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        final Color scaffoldBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF8F9FA);
        final Color cardBg = isDark ? const Color(0xFF2A2A2C) : Colors.white;
        final Color cardBorder = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE2E8F0);
        final Color textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
        final Color inputFill = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF1F5F9);
        final Color inputBorder = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE2E8F0);
        final Color iconColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
        final Color dividerColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE2E8F0);

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: iconColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Stack(
            children: [
              if (isDark) const AnimationBackground(),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cardBorder, width: 0.5),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                            ],
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Daftar Akun ${widget.isPedagang ? "Pedagang" : "Pembeli"}',
                          style: TextStyle(
                            fontSize: 22,
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: namaController,
                                hint: "Nama Lengkap",
                                icon: Icons.person_outline_rounded,
                                fillColor: inputFill,
                                borderColor: inputBorder,
                                textColor: textColor,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: emailController,
                                hint: "Email",
                                icon: Icons.mail_outline_rounded,
                                fillColor: inputFill,
                                borderColor: inputBorder,
                                textColor: textColor,
                                isDark: isDark,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Email tidak boleh kosong";
                                  }
                                  if (!value.contains('@')) {
                                    return "Format email tidak valid";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: teleponController,
                                hint: "Nomor Telepon",
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                fillColor: inputFill,
                                borderColor: inputBorder,
                                textColor: textColor,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: passwordController,
                                hint: "Kata Sandi",
                                icon: Icons.lock_outline_rounded,
                                obscureText: true,
                                fillColor: inputFill,
                                borderColor: inputBorder,
                                textColor: textColor,
                                isDark: isDark,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Kata sandi tidak boleh kosong";
                                  }
                                  if (value.length < 6) {
                                    return "Kata sandi terlalu singkat";
                                  }
                                  return null;
                                },
                              ),

                              if (widget.isPedagang) ...[
                                const SizedBox(height: 16),
                                Divider(color: dividerColor, thickness: 1),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: namaTokoController,
                                  hint: "Nama Toko",
                                  icon: Icons.storefront_rounded,
                                  fillColor: inputFill,
                                  borderColor: inputBorder,
                                  textColor: textColor,
                                  isDark: isDark,
                                  validator: (value) => value == null || value.isEmpty
                                      ? "Nama toko wajib diisi"
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  initialValue: jenisProduk,
                                  decoration: InputDecoration(
                                    hintText: "Jenis Produk",
                                    hintStyle: TextStyle(
                                      color: isDark ? const Color(0xFF5A5A5C) : const Color(0xFF9E9E9E),
                                      fontSize: 14,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                    filled: true,
                                    fillColor: inputFill,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                      borderSide: const BorderSide(color: Color(0xFFF5A623), width: 1.5),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.category_outlined,
                                      color: isDark ? const Color(0xFF7A7A7C) : const Color(0xFF9E9E9E),
                                      size: 20,
                                    ),
                                  ),
                                  dropdownColor: cardBg,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                  items: listJenisProduk.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      jenisProduk = newValue;
                                    });
                                  },
                                  validator: (value) =>
                                      value == null ? "Pilih jenis produk" : null,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: namaMakananController,
                                  hint: "Nama Makanan/Produk",
                                  icon: Icons.fastfood_outlined,
                                  fillColor: inputFill,
                                  borderColor: inputBorder,
                                  textColor: textColor,
                                  isDark: isDark,
                                  validator: (value) => value == null || value.isEmpty
                                      ? "Nama produk wajib diisi"
                                      : null,
                                ),
                              ],
                              const SizedBox(height: 20),

                              // Syarat & Ketentuan Checkbox
                              Row(
                                children: [
                                  Checkbox(
                                    value: _isAgreeTc,
                                    onChanged: (val) {
                                      setState(() {
                                        _isAgreeTc = val ?? false;
                                      });
                                    },
                                    activeColor: const Color(0xFFF5A623),
                                    checkColor: const Color(0xFF1C1C1E),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _showTermsDialog(context, isDark),
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'Saya menyetujui ',
                                          style: TextStyle(
                                            color: textColor.withValues(alpha: 0.7),
                                            fontSize: 13,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                          children: const [
                                            TextSpan(
                                              text: 'Syarat & Ketentuan',
                                              style: TextStyle(
                                                color: Color(0xFFF5A623),
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' Layanan Asongan.',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF5A623),
                                    foregroundColor: const Color(0xFF1C1C1E),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () async {
                                    if (!_isAgreeTc) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Anda harus menyetujui Syarat & Ketentuan untuk mendaftar."),
                                          backgroundColor: Colors.redAccent,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      return;
                                    }
                                    if (_formKey.currentState!.validate()) {
                                      final newUser = UserModelFirebase(
                                        nama: namaController.text,
                                        email: emailController.text,
                                        telepon: teleponController.text,
                                        password: passwordController.text,
                                        role: widget.isPedagang ? 'pedagang' : 'pembeli',
                                        namaToko: widget.isPedagang ? namaTokoController.text : null,
                                        jenisProduk: widget.isPedagang ? jenisProduk : null,
                                        namaMakanan: widget.isPedagang ? namaMakananController.text : null,
                                      );

                                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                                      final navigator = Navigator.of(context);

                                      bool success = await FirebaseAuthService().registerUser(newUser);

                                      if (success) {
                                        // Sinkronisasi data ke SQLite lokal
                                        await DBHelper().registerUser(newUser.toSql());
                                        
                                        scaffoldMessenger.showSnackBar(
                                          const SnackBar(
                                            content: Text("Pendaftaran berhasil! Silakan masuk."),
                                          ),
                                        );
                                        navigator.pop();
                                      } else {
                                        scaffoldMessenger.showSnackBar(
                                          const SnackBar(
                                            content: Text("Pendaftaran gagal. Email mungkin sudah terdaftar."),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text(
                                    "Daftar",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color fillColor,
    required Color borderColor,
    required Color textColor,
    required bool isDark,
    bool obscureText = false,
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
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
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
        prefixIcon: Icon(
          icon,
          color: isDark ? const Color(0xFF7A7A7C) : const Color(0xFF9E9E9E),
          size: 20,
        ),
      ),
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return "$hint tidak boleh kosong";
            }
            return null;
          },
    );
  }

  void _showTermsDialog(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final cardBg = isDark ? const Color(0xFF2A2A2C) : Colors.white;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Syarat & Ketentuan Layanan Asongan",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.5,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTermSection(
                    title: "1. Pendahuluan",
                    content: "Selamat datang di Asongan. Aplikasi ini menghubungkan pedagang jajanan/kuliner lokal dengan pembeli terdekat untuk melestarikan dan memudahkan transaksi jajanan tradisional secara digital.",
                    textColor: textColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTermSection(
                    title: "2. Akun & Keamanan",
                    content: "Pengguna wajib memberikan informasi yang akurat dan valid pada saat registrasi. Anda bertanggung jawab penuh atas keamanan kredensial akun Anda.",
                    textColor: textColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTermSection(
                    title: "3. Ketentuan Pedagang (Penjual)",
                    content: "Pedagang berkomitmen untuk menyajikan produk jajanan yang bersih, higienis, dan sesuai dengan deskripsi yang dipajang. Pedagang juga wajib melayani setiap pembeli dengan ramah dan menjunjung nilai kejujuran.",
                    textColor: textColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTermSection(
                    title: "4. Ketentuan Pembeli",
                    content: "Pembeli berkomitmen untuk menyelesaikan transaksi pembayaran pesanan secara bertanggung jawab (melalui metode yang tersedia, seperti bayar di tempat/COD atau metode lain). Pembeli dilarang melakukan pembatalan sepihak secara berulang demi menghargai usaha pedagang kecil.",
                    textColor: textColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTermSection(
                    title: "5. Keamanan & Kenyamanan Bersama",
                    content: "Setiap bentuk kecurangan, transaksi fiktif, spamming, dan perilaku tidak etis akan ditindak tegas dengan pemblokiran akun secara permanen dari sistem Asongan.",
                    textColor: textColor,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Tutup",
                style: TextStyle(
                  color: Color(0xFFF5A623),
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

  Widget _buildTermSection({
    required String title,
    required String content,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.7),
            fontSize: 13,
            height: 1.4,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
      ],
    );
  }
}
