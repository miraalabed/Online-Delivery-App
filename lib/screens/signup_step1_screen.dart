import 'package:flutter/material.dart';
import 'signup_step2_screen.dart';
import '../widgets/button.dart';
import '../strings.dart';

class SignupStep1Screen extends StatefulWidget {
  const SignupStep1Screen({super.key});

  @override
  State<SignupStep1Screen> createState() => _SignupStep1ScreenState();
}

class _SignupStep1ScreenState extends State<SignupStep1Screen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _dob;
  String? _gender;
  String? _role;

  String? _usernameError;
  String? _roleError;
  String? _genderError;
  String? _dobError;
  String? _locationError;
  String? _phoneError;

  final _phoneRegex = RegExp(r'^\d{10}$');

  void _nextStep() {
    setState(() {
      _usernameError = _usernameController.text.isEmpty
          ? Strings.errorFieldEmpty
          : null;
      _roleError = _role == null ? Strings.errorFieldEmpty : null;
      _genderError = _gender == null ? Strings.errorFieldEmpty : null;
      _dobError = _dob == null ? Strings.errorFieldEmpty : null;
      _locationError = _locationController.text.isEmpty
          ? Strings.errorFieldEmpty
          : null;
      _phoneError = _phoneController.text.isEmpty
          ? Strings.errorFieldEmpty
          : (!_phoneRegex.hasMatch(_phoneController.text)
                ? Strings.errorInvalidPhone
                : null);
    });

    if (_usernameError == null &&
        _roleError == null &&
        _genderError == null &&
        _dobError == null &&
        _locationError == null &&
        _phoneError == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignupStep2Screen(
            username: _usernameController.text,
            gender: _gender!,
            dob: _dob!,
            location: _locationController.text,
            phone: _phoneController.text,
            role: _role!,
          ),
        ),
      );
    }
  }

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2010),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _dob = date);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF408000);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(Strings.signUpStep1Title),
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
                controller: _usernameController,
                label: Strings.username,
                icon: Icons.person,
                errorText: _usernameError,
              ),
              const SizedBox(height: 20),

              Text(
                Strings.role,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                emptySelectionAllowed: true,
                segments: const [
                  ButtonSegment(value: 'admin', label: Text(Strings.owner)),
                  ButtonSegment(value: 'user', label: Text(Strings.customer)),
                ],
                selected: _role != null ? {_role!} : {},
                onSelectionChanged: (val) {
                  setState(() => _role = val.isNotEmpty ? val.first : null);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.white,
                  ), // خلفية بيضاء
                  side: MaterialStateProperty.all(
                    BorderSide(color: primaryColor),
                  ),
                  foregroundColor: MaterialStateProperty.all(
                    primaryColor,
                  ), // لون النص
                ),
              ),
              if (_roleError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    _roleError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),

              Text(
                Strings.gender,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                emptySelectionAllowed: true,
                segments: const [
                  ButtonSegment(value: Strings.male, label: Text(Strings.male)),
                  ButtonSegment(
                    value: Strings.female,
                    label: Text(Strings.female),
                  ),
                ],
                selected: _gender != null ? {_gender!} : {},
                onSelectionChanged: (val) {
                  setState(() => _gender = val.isNotEmpty ? val.first : null);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  side: MaterialStateProperty.all(
                    BorderSide(color: primaryColor),
                  ),
                  foregroundColor: MaterialStateProperty.all(primaryColor),
                ),
              ),
              if (_genderError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    _genderError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                child: ListTile(
                  leading: Icon(Icons.calendar_month, color: primaryColor),
                  title: Text(
                    _dob != null
                        ? _dob!.toLocal().toString().split(' ')[0]
                        : Strings.notSelected,
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: TextButton(
                    onPressed: _pickDate,
                    child: Text(
                      Strings.pickDate,
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ),
              ),
              if (_dobError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    _dobError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _locationController,
                label: Strings.location,
                icon: Icons.location_on,
                errorText: _locationError,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _phoneController,
                label: Strings.phone,
                icon: Icons.phone,
                errorText: _phoneError,
              ),
              const SizedBox(height: 30),

              CustomButton(text: Strings.next, onPressed: _nextStep),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(Strings.alreadyHaveAccount),
                style: TextButton.styleFrom(foregroundColor: primaryColor),
              ),
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
  }) {
    const primaryColor = Color(0xFF408000);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: controller,
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
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
