import 'package:asongan_app/core/animations/animation_background.dart';
import 'package:asongan_app/features/auth/data/auth_service.dart';
import 'package:asongan_app/features/auth/data/db_helper.dart';
import 'package:asongan_app/features/auth/model/user_model_sql.dart';
import 'package:asongan_app/features/auth/presentation/pages/register_screen.dart';
import 'package:asongan_app/features/auth/presentation/pages/wrapper/main_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool pembeli = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5a623),
      // appBar: AppBar(backgroundColor: Color(0xff1c1c1e)),
      body: Stack(
        children: [
          const AnimationBackground(),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  SvgPicture.asset("assets/images/logo_asongan.svg", width: 80),
                  SizedBox(height: 40),
                  Text(
                    'Selamat Datang di ASONGAN',
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xffffffff),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Masuk untuk mulai menemukan pedagang terdekat",
                    style: TextStyle(color: Color(0xffffffff)),
                  ),
                  SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ChoiceChip(
                              label: Text(
                                "Pembeli",
                                style: TextStyle(
                                  color: pembeli
                                      ? Colors.black
                                      : Color(0xfff5a623),
                                ),
                              ),
                              selected: pembeli,
                              selectedColor: Colors.white,
                              backgroundColor: Colors.white,
                              onSelected: (val) {
                                setState(() {
                                  pembeli = true;
                                });
                              },
                            ),
                            SizedBox(width: 16),
                            ChoiceChip(
                              label: Text(
                                "Pedagang",
                                style: TextStyle(
                                  color: !pembeli
                                      ? Colors.black
                                      : Color(0xfff5a623),
                                ),
                              ),
                              selected: !pembeli,
                              selectedColor: Colors.white,
                              backgroundColor: Colors.white,
                              onSelected: (val) {
                                setState(() {
                                  pembeli = false;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Email",
                            hintStyle: TextStyle(color: Color(0xFFffffff)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFFfffff)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFFfffff)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(
                              Icons.mail_outline_sharp,
                              color: Color(0xFFffffff),
                            ),
                          ),
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Nama/Email tidak boleh kosong";
                            } else if (!value.contains('@')) {
                              return "Format email tidak valid";
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16),

                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          obscureText: true,
                          obscuringCharacter: "X",
                          decoration: InputDecoration(
                            hintText: "Kata Sandi",
                            hintStyle: TextStyle(color: Color(0xFFffffff)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFFfffff)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFFfffff)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline_sharp,
                              color: Color(0xFFffffff),
                            ),
                            suffixIcon: Icon(
                              Icons.visibility,
                              color: Color(0xFFffffff),
                            ),
                          ),
                          controller: passwordController,
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
                  Align(
                    alignment: AlignmentGeometry.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "Lupa Kata Sandi?",
                        style: TextStyle(color: Color(0xFFffffff)),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFffffff),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final user = UserModelSql(
                            email: emailController.text,
                            password: passwordController.text,
                          );
                          final result = await DBHelper().loginUser(user);
                          if (result != null) {
                            if (result.role !=
                                    (pembeli ? 'pembeli' : 'pedagang') &&
                                result.role != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Role tidak sesuai dengan akun ini.",
                                  ),
                                ),
                              );
                              return;
                            }
                            // Save session
                            await AuthService.saveUserSession(result);

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainWrapper(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Email atau Kata Sandi salah"),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        "Masuk",
                        style: TextStyle(color: Color(0xFF1C1C1E)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Belum punya akun?",
                        style: TextStyle(color: Color(0xFFffffff)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RegisterPage(isPedagang: !pembeli),
                            ),
                          );
                        },
                        child: Text(
                          "Daftar",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Atau masuk dengan",
                    style: TextStyle(color: Color(0xFFAAAAAA)),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        //width: 140,
                        height: 32,
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: FaIcon(FontAwesomeIcons.google),
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      SizedBox(
                        //width: 140,
                        height: 32,
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: FaIcon(
                              FontAwesomeIcons.facebookF,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
