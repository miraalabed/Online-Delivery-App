import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'dart:html' as html;
import 'MapPickerPage.dart';
import 'package:latlong2/latlong.dart';
import '../strings.dart';

class EditShopSheet extends StatefulWidget {
  final Map shop;
  final String serverIP;
  final int adminId;

  const EditShopSheet({
    super.key,
    required this.shop,
    required this.serverIP,
    required this.adminId,
  });

  @override
  State<EditShopSheet> createState() => _EditShopSheetState();
}

class _EditShopSheetState extends State<EditShopSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _phoneController;
  late final TextEditingController _descriptionController;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final List<String> _shopTypes = const ["Restaurant", "Sweets Shop", "Cafe"];
  String? _shopType;

  Uint8List? _selectedImageBytesWeb;
  String? _selectedImageNameWeb;
  XFile? _pickedFileMobile;

  bool _isSaving = false;

  static const primaryColor = Color(0xFF408000);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shop['name'] ?? '');
    _locationController = TextEditingController(
      text: widget.shop['location'] ?? '',
    );
    _latitudeController = TextEditingController(
      text: (widget.shop['latitude'] ?? '').toString(),
    );
    _longitudeController = TextEditingController(
      text: (widget.shop['longitude'] ?? '').toString(),
    );
    _phoneController = TextEditingController(text: widget.shop['phone'] ?? '');
    _descriptionController = TextEditingController(
      text: widget.shop['description'] ?? '',
    );

    _shopType = widget.shop['type'];
    _parseWorkingHours(widget.shop['working_hours'] ?? '');
  }

  void _parseWorkingHours(String wh) {
    try {
      final parts = wh.split('-');
      if (parts.length == 2) {
        final startStr = parts[0].trim();
        final endStr = parts[1].trim();
        _startTime = _parseTimeOfDay(startStr);
        _endTime = _parseTimeOfDay(endStr);
      }
    } catch (_) {}
  }

  TimeOfDay? _parseTimeOfDay(String s) {
    try {
      final hasAm = s.toUpperCase().contains('AM');
      final hasPm = s.toUpperCase().contains('PM');
      final clean = s
          .toUpperCase()
          .replaceAll('AM', '')
          .replaceAll('PM', '')
          .trim();
      final hhmm = clean.split(':');
      int hour = int.parse(hhmm[0].trim());
      int minute = hhmm.length > 1 ? int.parse(hhmm[1].trim()) : 0;

      if (hasAm) {
        if (hour == 12) hour = 0;
      } else if (hasPm) {
        if (hour != 12) hour += 12;
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  String _formatWorkingHours() {
    if (_startTime == null || _endTime == null) return '';
    return "${_startTime!.format(context)} - ${_endTime!.format(context)}";
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

  Future<void> _pickImageWeb() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      if (file == null) return;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((e) {
        setState(() {
          _selectedImageBytesWeb = reader.result as Uint8List;
          _selectedImageNameWeb = file.name;
        });
      });
    });
  }

  Future<void> _pickImageMobile() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _pickedFileMobile = picked);
  }

  Future<void> _pickLocation() async {
    final lat = double.tryParse(_latitudeController.text) ?? 31.9;
    final lng = double.tryParse(_longitudeController.text) ?? 35.2;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerPage(initialLocation: LatLng(lat, lng)),
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        _latitudeController.text = result.latitude.toStringAsFixed(6);
        _longitudeController.text = result.longitude.toStringAsFixed(6);
      });
    }
  }

  Widget _fieldCard({required Widget child}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: child,
      ),
    );
  }

  InputDecoration _dec({required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      border: InputBorder.none,
      prefixIcon: icon == null ? null : Icon(icon, color: primaryColor),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final workingHours = _formatWorkingHours();
    setState(() => _isSaving = true);

    try {
      final uri = Uri.parse("http://${widget.serverIP}/project/edit_shop.php");
      final req = http.MultipartRequest('POST', uri);

      req.fields['id'] = widget.shop['id'].toString();
      req.fields['name'] = _nameController.text.trim();
      req.fields['type'] = _shopType ?? 'Restaurant';
      req.fields['location'] = _locationController.text.trim();
      req.fields['latitude'] = _latitudeController.text.trim();
      req.fields['longitude'] = _longitudeController.text.trim();
      req.fields['working_hours'] = workingHours;
      req.fields['phone'] = _phoneController.text.trim();
      req.fields['description'] = _descriptionController.text.trim();

      if (kIsWeb &&
          _selectedImageBytesWeb != null &&
          _selectedImageNameWeb != null) {
        req.files.add(
          http.MultipartFile.fromBytes(
            'image',
            _selectedImageBytesWeb!,
            filename: _selectedImageNameWeb!,
          ),
        );
      } else if (!kIsWeb && _pickedFileMobile != null) {
        req.files.add(
          await http.MultipartFile.fromPath('image', _pickedFileMobile!.path),
        );
      }

      final resp = await req.send();
      final body = await resp.stream.bytesToString();

      if (resp.statusCode == 200) {
        final data = json.decode(body);
        if (data['success'] == true) {
          if (!mounted) return;
          Navigator.pop(context, true);
        } else {
          _showSnack(data['message'] ?? Strings.updateFailed);
        }
      } else {
        _showSnack("${Strings.serverError}: ${resp.statusCode}");
      }
    } catch (e) {
      _showSnack("${Strings.errorPrefix}$e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return SafeArea(
      child: SizedBox(
        height: screenH * 1.00,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black87,
            title: const Text(Strings.editShopTitle),
          ),
          body: AbsorbPointer(
            absorbing: _isSaving,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        _fieldCard(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: _dec(
                              label: Strings.shopNameLabel,
                              icon: Icons.store,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? Strings.enterShopName
                                : null,
                          ),
                        ),
                        _fieldCard(
                          child: DropdownButtonFormField<String>(
                            value: _shopType,
                            items: _shopTypes
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t),
                                  ),
                                )
                                .toList(),
                            decoration: _dec(
                              label: Strings.shopTypeLabel,
                              icon: Icons.category,
                            ),
                            onChanged: (v) => setState(() => _shopType = v),
                            validator: (v) =>
                                v == null ? Strings.selectShopType : null,
                          ),
                        ),
                        _fieldCard(
                          child: TextFormField(
                            controller: _locationController,
                            decoration: _dec(
                              label: Strings.locationLabel,
                              icon: Icons.location_on,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? Strings.enterLocation
                                : null,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.map, color: primaryColor),
                              onPressed: _pickLocation,
                            ),
                            Expanded(
                              child: _fieldCard(
                                child: TextFormField(
                                  controller: _latitudeController,
                                  keyboardType: TextInputType.number,
                                  decoration: _dec(
                                    label: Strings.latitudeLabel,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _fieldCard(
                                child: TextFormField(
                                  controller: _longitudeController,
                                  keyboardType: TextInputType.number,
                                  decoration: _dec(
                                    label: Strings.longitudeLabel,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _fieldCard(
                                child: InkWell(
                                  onTap: _pickStartTime,
                                  child: InputDecorator(
                                    decoration: _dec(
                                      label: Strings.startTimeLabel,
                                      icon: Icons.access_time,
                                    ),
                                    child: Text(
                                      _startTime == null
                                          ? Strings.pickStartTime
                                          : _startTime!.format(context),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _fieldCard(
                                child: InkWell(
                                  onTap: _pickEndTime,
                                  child: InputDecorator(
                                    decoration: _dec(
                                      label: Strings.endTimeLabel,
                                      icon: Icons.timer,
                                    ),
                                    child: Text(
                                      _endTime == null
                                          ? Strings.pickEndTime
                                          : _endTime!.format(context),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        _fieldCard(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: _dec(
                              label: Strings.phoneNumberLabel,
                              icon: Icons.phone,
                            ),
                          ),
                        ),
                        _fieldCard(
                          child: TextFormField(
                            controller: _descriptionController,
                            minLines: 2,
                            maxLines: 5,
                            decoration: _dec(
                              label: Strings.description,
                              icon: Icons.description,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () async {
                            if (kIsWeb) {
                              await _pickImageWeb();
                            } else {
                              await _pickImageMobile();
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Builder(
                              builder: (_) {
                                if (kIsWeb && _selectedImageBytesWeb != null) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.memory(
                                      _selectedImageBytesWeb!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  );
                                }
                                if (!kIsWeb && _pickedFileMobile != null) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      io.File(_pickedFileMobile!.path),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  );
                                }
                                final imageUrl =
                                    (widget.shop['image_url'] ?? '').toString();
                                if (imageUrl.isNotEmpty) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.network(
                                      "http://${widget.serverIP}/project/$imageUrl",
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (_, __, ___) =>
                                          const Center(
                                            child: Icon(Icons.broken_image),
                                          ),
                                    ),
                                  );
                                }
                                return const Center(
                                  child: Icon(
                                    Icons.add_a_photo,
                                    color: primaryColor,
                                    size: 50,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        _isSaving
                            ? Strings.savingText
                            : Strings.saveChangesButton,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: _isSaving ? null : _save,
                    ),
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
