import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../strings.dart';
import 'login_screen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _emailError;
  String? _newPasswordError;
  String? _confirmPasswordError;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,15}$',
  );

  Future<void> _handleSave() async {
    final email = _emailController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _emailError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    if (email.isEmpty) {
      setState(() => _emailError = Strings.errorFieldEmpty);
      return;
    }

    if (newPassword.isEmpty) {
      setState(() => _newPasswordError = Strings.errorFieldEmpty);
      return;
    } else if (!_passwordRegex.hasMatch(newPassword)) {
      setState(() => _newPasswordError = Strings.errorInvalidPassword);
      return;
    }

    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = Strings.errorFieldEmpty);
      return;
    } else if (newPassword != confirmPassword) {
      setState(() => _confirmPasswordError = Strings.errorPasswordsNotMatch);
      return;
    }

    try {
      final url = Uri.parse('http://localhost/project/reset_password.php');
      final response = await http.post(
        url,
        body: {'email': email, 'new_password': newPassword},
      );

      final result = json.decode(response.body);

      if (result['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(Strings.passwordUpdated)));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        setState(() => _emailError = result['message'] ?? Strings.updateFailed);
      }
    } catch (e) {
      setState(() => _emailError = Strings.serverError);
    }
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
      appBar: AppBar(
        title: const Text(Strings.resetPassword),
        flexibleSpace: Container(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _emailController,
                label: Strings.email,
                icon: Icons.email,
                errorText: _emailError,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _newPasswordController,
                label: Strings.newPassword,
                icon: Icons.lock,
                obscureText: _obscureNew,
                errorText: _newPasswordError,
                suffixIcon: _obscureNew
                    ? Icons.visibility
                    : Icons.visibility_off,
                onSuffixTap: () => setState(() => _obscureNew = !_obscureNew),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _confirmPasswordController,
                label: Strings.confirmPassword,
                icon: Icons.lock_outline,
                obscureText: _obscureConfirm,
                errorText: _confirmPasswordError,
                suffixIcon: _obscureConfirm
                    ? Icons.visibility
                    : Icons.visibility_off,
                onSuffixTap: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleSave,
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
                  ),
                  child: const Text(Strings.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
