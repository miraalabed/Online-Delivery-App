import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:latlong2/latlong.dart';
import 'MapPickerPage.dart';
import '../strings.dart';

class AddShopScreenWeb extends StatefulWidget {
  final int adminId;
  final String serverIP;

  const AddShopScreenWeb({
    super.key,
    required this.adminId,
    required this.serverIP,
  });

  @override
  State<AddShopScreenWeb> createState() => _AddShopScreenWebState();
}

class _AddShopScreenWebState extends State<AddShopScreenWeb> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _shopType;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final List<String> _shopTypes = ["Restaurant", "Sweets Shop", "Cafe"];

  Future<void> _pickImageWeb() async {
    final html.FileUploadInputElement uploadInput =
        html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final file = uploadInput.files!.first;
      final reader = html.FileReader();

      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((e) {
        setState(() {
          _selectedImageBytes = reader.result as Uint8List;
          _selectedImageName = file.name;
        });
      });
    });
  }

  Future<void> _pickLocation() async {
    LatLng initialLocation = LatLng(
      double.tryParse(_latitudeController.text) ?? 31.9142795,
      double.tryParse(_longitudeController.text) ?? 35.1834208,
    );
    final picked = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerPage(initialLocation: initialLocation),
      ),
    );
    if (picked != null && picked is LatLng) {
      setState(() {
        _latitudeController.text = picked.latitude.toStringAsFixed(7);
        _longitudeController.text = picked.longitude.toStringAsFixed(7);
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  Future<void> _submitShop() async {
    if (!_formKey.currentState!.validate()) return;

    String workingHoursText = '';
    if (_startTime != null && _endTime != null) {
      workingHoursText =
          "${_startTime!.format(context)} - ${_endTime!.format(context)}";
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://${widget.serverIP}/project/add_shop.php"),
    );

    request.fields['name'] = _nameController.text.trim();
    request.fields['type'] = _shopType ?? 'Other';
    request.fields['location'] = _locationController.text.trim();
    request.fields['latitude'] = _latitudeController.text.trim();
    request.fields['longitude'] = _longitudeController.text.trim();
    request.fields['working_hours'] = workingHoursText;
    request.fields['phone'] = _phoneController.text.trim();
    request.fields['description'] = _descriptionController.text.trim();
    request.fields['admin_id'] = widget.adminId.toString();

    if (_selectedImageBytes != null && _selectedImageName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          _selectedImageBytes!,
          filename: _selectedImageName!,
        ),
      );
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(Strings.shopAddedSuccess)));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${Strings.failedToAddShop}: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${Strings.errorOccurred}: $e")));
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    const primaryColor = Color(0xFF408000);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: primaryColor) : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
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
        title: const Text(Strings.addShop),
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
                label: Strings.shopName,
                icon: Icons.store,
                validator: (val) =>
                    val == null || val.isEmpty ? Strings.enterShopName : null,
              ),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.white,
                child: DropdownButtonFormField<String>(
                  value: _shopType,
                  decoration: InputDecoration(
                    labelText: Strings.shopType,
                    prefixIcon: const Icon(
                      Icons.category_sharp,
                      color: primaryColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 20,
                    ),
                  ),
                  items: _shopTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _shopType = val;
                    });
                  },
                  validator: (val) =>
                      val == null ? Strings.selectShopType : null,
                ),
              ),
              _buildTextField(
                controller: _locationController,
                label: Strings.location,
                icon: Icons.location_on,
                validator: (val) =>
                    val == null || val.isEmpty ? Strings.enterLocation : null,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.map, color: primaryColor, size: 30),
                    onPressed: _pickLocation,
                  ),
                  Expanded(
                    child: _buildTextField(
                      controller: _latitudeController,
                      label: Strings.latitude,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: _longitudeController,
                      label: Strings.longitude,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: TextEditingController(
                        text: _startTime != null
                            ? _startTime!.format(context)
                            : '',
                      ),
                      label: Strings.startTime,
                      readOnly: true,
                      onTap: _pickStartTime,
                      icon: Icons.access_time,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: TextEditingController(
                        text: _endTime != null ? _endTime!.format(context) : '',
                      ),
                      label: Strings.endTime,
                      readOnly: true,
                      onTap: _pickEndTime,
                      icon: Icons.access_time,
                    ),
                  ),
                ],
              ),
              _buildTextField(
                controller: _phoneController,
                label: Strings.phoneNumber,
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                controller: _descriptionController,
                label: Strings.description,
                icon: Icons.description,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickImageWeb,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _selectedImageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.memory(
                            _selectedImageBytes!,
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
        onPressed: _submitShop,
        backgroundColor: primaryColor,
        child: const Icon(Icons.check, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
