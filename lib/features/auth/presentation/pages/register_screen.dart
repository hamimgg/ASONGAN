import 'package:asongan_app/core/animations/animation_background.dart';
import 'package:asongan_app/features/auth/data/db_helper.dart';
import 'package:asongan_app/features/auth/model/user_model_sql.dart';
import 'package:flutter/material.dart';

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

  final List<String> listJenisProduk = [
    'Makanan Berat',
    'Makanan Ringan',
    'Minuman',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1c1c1e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const AnimationBackground(),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Daftar Akun ${widget.isPedagang ? "Pedagang" : "Pembeli"}',
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xffffffff),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: namaController,
                          hint: "Nama Lengkap",
                          icon: Icons.person_outline,
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: emailController,
                          hint: "Email",
                          icon: Icons.mail_outline_sharp,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Email tidak boleh kosong";
                            if (!value.contains('@'))
                              return "Format email tidak valid";
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: teleponController,
                          hint: "Nomor Telepon",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: passwordController,
                          hint: "Kata Sandi",
                          icon: Icons.lock_outline_sharp,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Kata sandi tidak boleh kosong";
                            if (value.length < 6)
                              return "Kata sandi terlalu singkat";
                            return null;
                          },
                        ),

                        if (widget.isPedagang) ...[
                          SizedBox(height: 16),
                          Divider(color: Colors.white54),
                          SizedBox(height: 16),
                          _buildTextField(
                            controller: namaTokoController,
                            hint: "Nama Toko",
                            icon: Icons.store_mall_directory_outlined,
                            validator: (value) => value == null || value.isEmpty
                                ? "Nama toko wajib diisi"
                                : null,
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: jenisProduk,
                            decoration: InputDecoration(
                              hintText: "Jenis Produk",
                              hintStyle: TextStyle(color: Color(0xFFffffff)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFFfffff),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFFfffff),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: Icon(
                                Icons.category_outlined,
                                color: Colors.white,
                              ),
                            ),
                            dropdownColor: Color(0xff1c1c1e),
                            style: TextStyle(color: Colors.white),
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
                          SizedBox(height: 16),
                          _buildTextField(
                            controller: namaMakananController,
                            hint: "Nama Makanan/Produk",
                            icon: Icons.fastfood_outlined,
                            validator: (value) => value == null || value.isEmpty
                                ? "Nama produk wajib diisi"
                                : null,
                          ),
                        ],

                        SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFffffff),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final newUser = UserModelSql(
                                  nama: namaController.text,
                                  email: emailController.text,
                                  telepon: teleponController.text,
                                  password: passwordController.text,
                                  role: widget.isPedagang
                                      ? 'pedagang'
                                      : 'pembeli',
                                  namaToko: widget.isPedagang
                                      ? namaTokoController.text
                                      : null,
                                  jenisProduk: widget.isPedagang
                                      ? jenisProduk
                                      : null,
                                  namaMakanan: widget.isPedagang
                                      ? namaMakananController.text
                                      : null,
                                );

                                bool success = await DBHelper().registerUser(
                                  newUser,
                                );
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Pendaftaran berhasil! Silakan masuk.",
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Pendaftaran gagal. Email mungkin sudah terdaftar.",
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(
                              "Daftar",
                              style: TextStyle(
                                color: Color(0xFF1C1C1E),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Color(0xFFffffff)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFfffff)),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFfffff)),
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(icon, color: Color(0xFFffffff)),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return "$hint tidak boleh kosong";
            }
            return null;
          },
    );
  }
}
