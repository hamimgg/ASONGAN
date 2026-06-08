import 'package:asongan_app/core/animations/animation_background.dart';
import 'package:asongan_app/features/auth/data/auth_service.dart';
import 'package:asongan_app/features/auth/data/db_helper.dart';
import 'package:asongan_app/features/auth/model/user_model_sql.dart';
import 'package:asongan_app/features/auth/presentation/pages/register_screen.dart';
import 'package:asongan_app/features/auth/presentation/pages/wrapper/main_wrapper.dart';
import 'package:asongan_app/main.dart';
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
        final Color socialBg = isDark
            ? const Color(0xFF1C1C1E)
            : const Color(0xFFF1F5F9);
        final Color dividerColor = isDark
            ? const Color(0xFF3A3A3C)
            : const Color(0xFFE2E8F0);

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
                              Align(
                                alignment: Alignment.topLeft,
                                child: GestureDetector(
                                  onTap: () => Navigator.maybePop(context),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                    size: 22,
                                  ),
                                ),
                              ),
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
                                'Selamat Datang di Asongan',
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
                              const SizedBox(height: 20),

                              // Divider "Atau masuk dengan"
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: dividerColor,
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'Atau masuk dengan',
                                      style: TextStyle(
                                        color: textColor.withValues(alpha: 0.4),
                                        fontSize: 12,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: dividerColor,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Social login
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSocialButton(
                                      onTap: () {},
                                      fillColor: socialBg,
                                      borderColor: dividerColor,
                                      child: SvgPicture.string(
                                        '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
                                          <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                                          <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                                          <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/>
                                          <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
                                        </svg>''',
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildSocialButton(
                                      onTap: () {},
                                      fillColor: socialBg,
                                      borderColor: dividerColor,
                                      child: SvgPicture.string(
                                        '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="${isDark ? '#FFFFFF' : '#1877F2'}">
                                          <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                                        </svg>''',
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

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

  // --- Social button ---
  Widget _buildSocialButton({
    required VoidCallback onTap,
    required Widget child,
    required Color fillColor,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Center(child: child),
      ),
    );
  }

  // --- Login handler (CRUD preserved) ---
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = UserModelSql(
        email: emailController.text,
        password: passwordController.text,
      );
      final result = await DBHelper().loginUser(user);
      if (!mounted) return;

      if (result != null) {
        if (result.role != (pembeli ? 'pembeli' : 'pedagang') &&
            result.role != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Role tidak sesuai dengan akun ini.")),
          );
          return;
        }
        // Save session
        await AuthService.saveUserSession(result);
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
