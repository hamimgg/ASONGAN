import 'package:asongan_app/core/animations/animation_background.dart';
import 'package:asongan_app/features/auth/data/auth_service.dart';
import 'package:asongan_app/features/auth/data/firebase_auth_service.dart';
import 'package:asongan_app/features/auth/model/user_model_firebase.dart';
import 'package:asongan_app/features/auth/presentation/pages/register_screen.dart';
import 'package:asongan_app/features/auth/presentation/pages/wrapper/main_wrapper.dart';
import 'package:asongan_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool pembeli = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        final Color scaffoldBg = isDark
            ? const Color(0xFF1C1C1E)
            : const Color(0xFFf5a623);
        final Color cardBg = isDark ? const Color(0xFF2A2A2C) : Colors.white;
        final Color cardBorder = isDark
            ? const Color(0xFF3A3A3C)
            : const Color(0xFFE2E8F0);
        final Color textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
        final Color subtitleColor = isDark
            ? const Color(0xFFF5A623).withValues(alpha: 0.7)
            : const Color(0xFF7A7A7C);
        final Color inputFill = isDark
            ? const Color(0xFF1C1C1E)
            : const Color(0xFFF1F5F9);
        final Color inputBorder = isDark
            ? const Color(0xFF3A3A3C)
            : const Color(0xFFE2E8F0);
        final Color roleToggleBg = isDark
            ? const Color(0xFF1C1C1E)
            : const Color(0xFFF1F5F9);

        return Scaffold(
          backgroundColor: scaffoldBg,
          body: Stack(
            children: [
              const AnimationBackground(),
              // Dot grid background
              CustomPaint(
                size: Size.infinite,
                painter: _DotGridPainter(isDark: isDark),
              ),
              // Animated background glow from original
              if (isDark) const AnimationBackground(),
              // Main content
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorder, width: 0.5),
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Close button
                              // Align(
                              //   alignment: Alignment.topLeft,
                              //   child: GestureDetector(
                              //     onTap: () => Navigator.maybePop(context),
                              //     child: Icon(
                              //       Icons.close_rounded,
                              //       color: isDark
                              //           ? Colors.white54
                              //           : Colors.black54,
                              //       size: 22,
                              //     ),
                              //   ),
                              // ),
                              const SizedBox(height: 12),

                              // SVG Logo
                              SvgPicture.asset(
                                "assets/images/logo_asongan.svg",
                                width: 48,
                                height: 48,
                              ),
                              const SizedBox(height: 20),

                              // Pembeli / Pedagang toggle
                              _buildRoleToggle(roleToggleBg, isDark),
                              const SizedBox(height: 20),

                              // Title
                              Text(
                                'Selamat Datang di ASONGAN',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Masuk untuk mulai menemukan pedagang terdekat',
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 13,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),

                              // Form
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // Email field
                                    _buildInputField(
                                      controller: emailController,
                                      hint: 'Nomor Telepon atau Email',
                                      prefixIcon: Icons.mail_outline_rounded,
                                      fillColor: inputFill,
                                      borderColor: inputBorder,
                                      textColor: textColor,
                                      isDark: isDark,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Nama/Email tidak boleh kosong";
                                        } else if (!value.contains('@')) {
                                          return "Format email tidak valid";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 14),

                                    // Password field
                                    _buildInputField(
                                      controller: passwordController,
                                      hint: 'Kata Sandi',
                                      prefixIcon: Icons.lock_outline_rounded,
                                      obscure: _obscurePassword,
                                      fillColor: inputFill,
                                      borderColor: inputBorder,
                                      textColor: textColor,
                                      isDark: isDark,
                                      suffixWidget: GestureDetector(
                                        onTap: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                        child: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.black38,
                                          size: 20,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Kata sandi tidak boleh kosong";
                                        } else if (value.length < 6) {
                                          return "Kata sandi terlalu singkat";
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // Lupa kata sandi
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.only(top: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Lupa kata sandi?',
                                    style: TextStyle(
                                      color: Color(0xFFF5A623),
                                      fontSize: 12,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Masuk button
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
                                  onPressed: _isLoading ? null : _handleLogin,
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFF1C1C1E),
                                          ),
                                        )
                                      : const Text(
                                          'Masuk',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Daftar akun
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Belum punya akun? ',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                      fontSize: 13,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RegisterPage(
                                            isPedagang: !pembeli,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Daftar Akun Baru',
                                      style: TextStyle(
                                        color: Color(0xFFF5A623),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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

  // --- Role toggle (Pembeli / Pedagang) ---
  Widget _buildRoleToggle(Color bg, bool isDark) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _roleTab(label: 'Pembeli', isSelected: pembeli, isDark: isDark),
          _roleTab(label: 'Pedagang', isSelected: !pembeli, isDark: isDark),
        ],
      ),
    );
  }

  Widget _roleTab({
    required String label,
    required bool isSelected,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => pembeli = label == 'Pembeli'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF5A623) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white38 : Colors.black38),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ),
      ),
    );
  }

  // --- Input field ---
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    required Color fillColor,
    required Color borderColor,
    required Color textColor,
    required bool isDark,
    bool obscure = false,
    Widget? suffixWidget,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontFamily: 'Plus Jakarta Sans',
      ),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF5A5A5C) : const Color(0xFF9E9E9E),
          fontSize: 14,
          fontFamily: 'Plus Jakarta Sans',
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: isDark ? const Color(0xFF7A7A7C) : const Color(0xFF9E9E9E),
          size: 20,
        ),
        suffixIcon: suffixWidget != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffixWidget,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
    );
  }

  // --- Login handler (CRUD preserved) ---
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      // 1. Sign in dengan Firebase Authentication & Firestore
      final fbUser = UserModelFirebase(
        email: emailController.text,
        password: passwordController.text,
      );
      final fbResult = await FirebaseAuthService().loginUser(fbUser);

      if (!mounted) return;

      if (fbResult != null) {
        // 2. Validasi Role (data langsung dari Firestore)
        if (fbResult.role != (pembeli ? 'pembeli' : 'pedagang') &&
            fbResult.role != 'pedagang_dan_pembeli' &&
            fbResult.role != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Role tidak sesuai dengan akun ini.")),
          );
          return;
        }

        // 3. Simpan Session (UserModelFirebase, membawa uid Firebase)
        await AuthService.saveUserSession(fbResult);
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainWrapper()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email atau Kata Sandi salah")),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String errorMsg = "Email atau Kata Sandi salah";
      if (e.code == 'user-not-found') {
        errorMsg = "Email tidak terdaftar";
      } else if (e.code == 'wrong-password') {
        errorMsg = "Kata sandi salah";
      } else if (e.code == 'invalid-email') {
        errorMsg = "Format email tidak valid";
      } else if (e.code == 'user-disabled') {
        errorMsg = "Akun telah dinonaktifkan";
      } else if (e.code == 'invalid-credential') {
        errorMsg = "Email atau kata sandi tidak valid";
      } else if (e.message != null) {
        errorMsg = e.message!;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// Dot grid background painter
class _DotGridPainter extends CustomPainter {
  final bool isDark;
  _DotGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? const Color(0xFF2E2E30) : const Color(0xFFE2E8F0)
      ..strokeWidth = 1;

    const spacing = 24.0;
    const radius = 1.2;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
