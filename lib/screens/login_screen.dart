import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/gestures.dart';
import '../strings.dart';
import 'home_screen.dart';
import 'admin_home_screen.dart';
import 'forgetpassword_screen.dart';
import 'signup_step1_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('remember_me') ?? false;

    if (remember) {
      _emailController.text = prefs.getString('email') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      setState(() {
        _rememberMe = true;
      });
    }
  }

  Future<void> _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (email.isEmpty) {
      setState(() => _emailError = Strings.errorFieldEmpty);
      return;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = Strings.errorFieldEmpty);
      return;
    }

    try {
      final url = Uri.parse('http://localhost/project/login.php');
      final response = await http.post(
        url,
        body: {'email': email, 'password': password},
      );

      final result = json.decode(response.body);

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        final role = result['role'];
        final userId = result['id'];

        // Remember Me
        if (_rememberMe) {
          await prefs.setBool('remember_me', true);
          await prefs.setString('email', email);
          await prefs.setString('password', password);
          await prefs.setString('role', role);
          if (userId != null) await prefs.setInt('user_id', userId);
        } else {
          await prefs.setBool('remember_me', false);
        }

        // حفظ بيانات المستخدم
        await prefs.setString('current_user_email', email);
        await prefs.setString('current_user_role', role);
        if (userId != null) await prefs.setInt('user_id', userId);

        if (!mounted) return;

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminHomeScreen(adminId: userId),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        setState(() {
          _passwordError = result['message'] ?? "Login failed";
        });
      }
    } catch (e) {
      setState(() {
        _passwordError = 'Server error, please try again.';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? errorText,
    bool obscureText = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
  }) {
    const primaryColor = Color(0xFF408000);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryColor),
          labelText: label,
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Icon(suffixIcon, color: primaryColor),
                )
              : null,
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF408000);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/logo.jpg',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 0),

                _buildTextField(
                  controller: _emailController,
                  label: Strings.email,
                  icon: Icons.email,
                  errorText: _emailError,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _passwordController,
                  label: Strings.password,
                  icon: Icons.lock,
                  obscureText: _obscurePassword,
                  errorText: _passwordError,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                  onSuffixTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),

                // Remember Me
                CheckboxListTile(
                  title: Text(Strings.rememberMe),
                  value: _rememberMe,
                  onChanged: (val) {
                    setState(() {
                      _rememberMe = val ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 20),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      elevation: 6,
                      shadowColor: Colors.black45,
                    ),
                    child: Text(Strings.login),
                  ),
                ),
                const SizedBox(height: 20),

                // Sign Up Link
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: Strings.signUpPrompt,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                    children: [
                      TextSpan(
                        text: Strings.signUp,
                        style: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupStep1Screen(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Forget Password
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgetPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    Strings.forgetPassword,
                    style: const TextStyle(color: primaryColor, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
