import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../strings.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String location;
  final String phone;
  final String email;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.location,
    required this.phone,
    required this.email,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController locationController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  String? originalEmail;
  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    locationController = TextEditingController(text: widget.location);
    phoneController = TextEditingController(text: widget.phone);
    emailController = TextEditingController(text: widget.email);
    _loadOriginalEmail();
  }

  Future<void> _loadOriginalEmail() async {
    final prefs = await SharedPreferences.getInstance();
    originalEmail = prefs.getString('email');
  }

  Future<void> _saveChanges() async {
    if (newPasswordController.text.isNotEmpty &&
        newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Strings.passwordsDoNotMatch)),
      );
      return;
    }

    final url = Uri.parse('http://localhost/project/update_user.php');

    final response = await http.post(
      url,
      body: {
        'original_email': originalEmail,
        'username': nameController.text,
        'location': locationController.text,
        'phone': phoneController.text,
        'email': emailController.text,
        'current_password': currentPasswordController.text,
        'new_password': newPasswordController.text,
      },
    );

    final data = json.decode(response.body);
    print('Response: $data');

    if (data['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', emailController.text);

      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? Strings.updateFailed)),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
  }) {
    const primaryColor = Color(0xFF408000);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: primaryColor) : null,
          suffixIcon: toggleVisibility != null
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: primaryColor,
                  ),
                  onPressed: toggleVisibility,
                )
              : null,
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF408000);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(Strings.editProfileTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            _buildTextField(
              controller: nameController,
              label: Strings.nameLabel,
              icon: Icons.person,
            ),
            _buildTextField(
              controller: locationController,
              label: Strings.locationLabel,
              icon: Icons.location_on,
            ),
            _buildTextField(
              controller: phoneController,
              label: Strings.phoneLabel,
              icon: Icons.phone,
            ),
            _buildTextField(
              controller: emailController,
              label: Strings.email,
              icon: Icons.email,
            ),

            const SizedBox(height: 20),

            const Text(
              Strings.changePasswordSection,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            _buildTextField(
              controller: currentPasswordController,
              label: Strings.currentPasswordLabel,
              icon: Icons.lock,
              obscureText: !showCurrentPassword,
              toggleVisibility: () {
                setState(() => showCurrentPassword = !showCurrentPassword);
              },
            ),
            _buildTextField(
              controller: newPasswordController,
              label: Strings.newPasswordLabel,
              icon: Icons.lock_outline,
              obscureText: !showNewPassword,
              toggleVisibility: () {
                setState(() => showNewPassword = !showNewPassword);
              },
            ),
            _buildTextField(
              controller: confirmPasswordController,
              label: Strings.confirmNewPasswordLabel,
              icon: Icons.lock_outline,
              obscureText: !showConfirmPassword,
              toggleVisibility: () {
                setState(() => showConfirmPassword = !showConfirmPassword);
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveChanges,
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
                ),
                child: const Text(Strings.saveChangesButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
