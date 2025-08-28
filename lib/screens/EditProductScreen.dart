import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../strings.dart';

class EditProductScreen extends StatefulWidget {
  final Map product;
  final String serverIP;
  final int shopId;

  const EditProductScreen({
    super.key,
    required this.product,
    required this.serverIP,
    required this.shopId,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;

  XFile? _pickedFile;
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']);
    _descController = TextEditingController(
      text: widget.product['description'],
    );
    _priceController = TextEditingController(
      text: widget.product['price'].toString(),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _pickedFile = pickedFile);
    }
  }

  Future<void> _updateProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Strings.namePriceRequired)));
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null || price < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Strings.enterValidPrice)));
      return;
    }

    setState(() => isLoading = true);

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("http://${widget.serverIP}/project/update_product.php"),
      );

      request.fields['product_id'] = widget.product['id'].toString();
      request.fields['shop_id'] = widget.shopId.toString();
      request.fields['name'] = _nameController.text;
      request.fields['description'] = _descController.text;
      request.fields['price'] = _priceController.text;

      if (_pickedFile != null) {
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
      }

      var response = await request.send();
      final resBody = await response.stream.bytesToString();

      final data = json.decode(resBody);
      if (data['status'] == 'success') {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? Strings.errorUpdatingProduct),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${Strings.errorUpdatingProduct}: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    const primaryColor = Color(0xFF408000);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: primaryColor) : null,
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

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Stack(
            children: [
              ListView(
                controller: scrollController,
                padding: const EdgeInsets.only(bottom: 80),
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  _buildTextField(
                    controller: _nameController,
                    label: Strings.productNameLabel,
                    icon: Icons.no_food,
                  ),
                  _buildTextField(
                    controller: _descController,
                    label: Strings.description,
                    icon: Icons.description,
                  ),
                  _buildTextField(
                    controller: _priceController,
                    label: Strings.priceLabel,
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: _pickImage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: _pickedFile != null
                                  ? kIsWeb
                                        ? Image.network(
                                            _pickedFile!.path,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(_pickedFile!.path),
                                            fit: BoxFit.cover,
                                          )
                                  : widget.product['image_url'] != null &&
                                        widget.product['image_url'].isNotEmpty
                                  ? Image.network(
                                      "http://${widget.serverIP}/project/${widget.product['image_url']}",
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.grey[100],
                                      child: const Center(
                                        child: Icon(
                                          Icons.add_a_photo,
                                          color: primaryColor,
                                          size: 50,
                                        ),
                                      ),
                                    ),
                            ),
                            Positioned.fill(
                              child: AnimatedOpacity(
                                opacity: 0.2,
                                duration: const Duration(milliseconds: 300),
                                child: Container(color: Colors.black),
                              ),
                            ),
                            const Positioned(
                              bottom: 10,
                              right: 10,
                              child: Icon(Icons.edit, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _updateProduct,
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
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(Strings.updateProductButton),
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
}
