import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import '../strings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String location = '';
  String phone = '';
  String email = '';
  bool isLoading = true;

  String selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');

    if (savedEmail == null || savedEmail.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse('http://localhost/project/get_user.php');

    try {
      final response = await http.post(url, body: {'email': savedEmail});
      final data = json.decode(response.body);

      if (data['success'] == true && data['user'] != null) {
        setState(() {
          name = data['user']['username'] ?? '';
          location = data['user']['location'] ?? '';
          phone = data['user']['phone'] ?? '';
          email = data['user']['email'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() => isLoading = false);
    }
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    const primaryColor = Color(0xFF408000);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        subtitle: Text(
          value.isNotEmpty ? value : '—',
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF408000);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(Strings.profileLabel),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    name: name,
                    location: location,
                    phone: phone,
                    email: email,
                  ),
                ),
              );

              if (updated == true) {
                _loadUserInfo();
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: primaryColor.withOpacity(0.2),
                      child: const Icon(
                        Icons.person,
                        size: 70,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Text(
                      name.isNotEmpty ? 'Hi, ' + name + '!' : 'User Name',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    Strings.personalInfo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _buildInfoTile(Strings.nameLabel, name, Icons.person),
                  _buildInfoTile(
                    Strings.locationLabel,
                    location,
                    Icons.location_on,
                  ),
                  _buildInfoTile(Strings.phoneLabel, phone, Icons.phone),
                  _buildInfoTile(Strings.email, email, Icons.email),

                  const SizedBox(height: 20),
                  const Text(
                    Strings.aboutApp,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        ExpansionTile(
                          leading: const Icon(
                            Icons.info_outline,
                            color: primaryColor,
                          ),
                          title: const Text(
                            Strings.appInfo,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                Strings.appinfodetails,
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                        ExpansionTile(
                          leading: const Icon(
                            Icons.contact_mail,
                            color: primaryColor,
                          ),
                          title: const Text(
                            Strings.contactUs,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                Strings.contactUsdetails,
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                        ExpansionTile(
                          leading: const Icon(
                            Icons.security,
                            color: primaryColor,
                          ),
                          title: const Text(
                            Strings.security,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                Strings.securitydetails,
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                        ExpansionTile(
                          leading: const Icon(
                            Icons.language,
                            color: primaryColor,
                          ),
                          title: const Text(
                            Strings.language,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: DropdownButton<String>(
                                value: selectedLanguage,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'English',
                                    child: Text('English'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedLanguage = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    Strings.logout,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text(Strings.Confirmlogout),
                          content: const Text(Strings.surelogout),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text(
                                Strings.cancel,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                Strings.logout,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _logout(context);
                      }
                    },
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: Icon(Icons.logout, color: primaryColor),
                        title: const Text(
                          Strings.logout,
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
