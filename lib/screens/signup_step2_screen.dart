import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../strings.dart';
import '../widgets/button.dart';
import 'login_screen.dart';

class SignupStep2Screen extends StatefulWidget {
  final String username;
  final String gender;
  final DateTime dob;
  final String location;
  final String phone;
  final String role;

  const SignupStep2Screen({
    super.key,
    required this.username,
    required this.gender,
    required this.dob,
    required this.location,
    required this.phone,
    required this.role,
  });

  @override
  State<SignupStep2Screen> createState() => _SignupStep2ScreenState();
}

class _SignupStep2ScreenState extends State<SignupStep2Screen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,15}$',
  );

  Future<void> _handleDone() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    if (email.isEmpty) {
      setState(() => _emailError = Strings.errorFieldEmpty);
      return;
    } else if (!_emailRegex.hasMatch(email)) {
      setState(() => _emailError = Strings.errorInvalidEmail);
      return;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = Strings.errorFieldEmpty);
      return;
    } else if (!_passwordRegex.hasMatch(password)) {
      setState(() => _passwordError = Strings.errorInvalidPassword);
      return;
    }

    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = Strings.errorFieldEmpty);
      return;
    } else if (password != confirmPassword) {
      setState(() => _confirmPasswordError = Strings.errorPasswordsNotMatch);
      return;
    }

    final url = Uri.parse('http://localhost/project/signup.php');
    final response = await http.post(
      url,
      body: {
        'username': widget.username,
        'gender': widget.gender,
        'dob': widget.dob.toIso8601String(),
        'location': widget.location,
        'phone': widget.phone,
        'email': email,
        'password': password,
        'role': widget.role,
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success'].toString() == 'true') {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text(Strings.signupSuccess),
              ],
            ),
            backgroundColor: Colors.black87,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Registration failed')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server error. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(Strings.signUpStep2Title),
        flexibleSpace: Container(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(
                controller: _emailController,
                label: Strings.email,
                icon: Icons.email,
                errorText: _emailError,
                obscureText: false,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                label: Strings.password,
                icon: Icons.lock,
                errorText: _passwordError,
                obscureText: _obscurePassword,
                suffixIcon: _obscurePassword
                    ? Icons.visibility
                    : Icons.visibility_off,
                onSuffixTap: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _confirmPasswordController,
                label: Strings.confirmPassword,
                icon: Icons.lock_outline,
                errorText: _confirmPasswordError,
                obscureText: _obscureConfirm,
                suffixIcon: _obscureConfirm
                    ? Icons.visibility
                    : Icons.visibility_off,
                onSuffixTap: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                },
              ),
              const SizedBox(height: 30),
              CustomButton(text: Strings.done, onPressed: _handleDone),
            ],
          ),
        ),
      ),
    );
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFF408000)),
          labelText: label,
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Icon(suffixIcon, color: Colors.grey[600]),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
