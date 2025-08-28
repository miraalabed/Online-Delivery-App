import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../strings.dart';

class AddProductScreen extends StatefulWidget {
  final int shopId;
  final String serverIP;

  const AddProductScreen({
    super.key,
    required this.shopId,
    required this.serverIP,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  XFile? _pickedFile;
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _pickedFile = pickedFile);
    }
  }

  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Strings.selectImage)));
      return;
    }

    setState(() => isLoading = true);

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("http://${widget.serverIP}/project/add_product.php"),
      );

      request.fields['shop_id'] = widget.shopId.toString();
      request.fields['name'] = _nameController.text;
      request.fields['description'] = _descController.text;
      request.fields['price'] = _priceController.text;

      if (kIsWeb) {
        final bytes = await _pickedFile!.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: _pickedFile!.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('image', _pickedFile!.path),
        );
      }

      var response = await request.send();
      final resBody = await response.stream.bytesToString();

      try {
        final data = json.decode(resBody);
        if (data['status'] == 'success') {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Error adding product")),
          );
        }
      } catch (e) {
        debugPrint("JSON decode error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server returned invalid JSON")),
        );
      }
    } catch (e) {
      debugPrint("Error uploading product: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error uploading product: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
    String? Function(String?)? validator,
  }) {
    const primaryColor = Color(0xFF408000);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
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
        title: const Text(Strings.addProduct),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _nameController,
                label: Strings.productName,
                icon: Icons.no_food,
                validator: (val) => val == null || val.isEmpty
                    ? Strings.enterProductName
                    : null,
              ),
              _buildTextField(
                controller: _descController,
                label: Strings.description,
                icon: Icons.description,
              ),
              _buildTextField(
                controller: _priceController,
                label: Strings.price,
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return Strings.enterPrice;
                  final number = double.tryParse(val);
                  if (number == null) return Strings.priceMustBeNumber;
                  if (number < 0) return Strings.priceCannotBeNegative;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickImage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey[300]!, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _pickedFile != null
                      ? kIsWeb
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  _pickedFile!.path,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(
                                  File(_pickedFile!.path),
                                  fit: BoxFit.cover,
                                ),
                              )
                      : const Center(
                          child: Icon(
                            Icons.add_a_photo,
                            color: primaryColor,
                            size: 50,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadProduct,
        backgroundColor: primaryColor,
        child: const Icon(Icons.check, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
