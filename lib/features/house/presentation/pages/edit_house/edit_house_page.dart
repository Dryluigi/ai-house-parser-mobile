import 'dart:convert';
import 'dart:io';

import 'package:house_parser_mobile/constants/config.dart';
import 'package:house_parser_mobile/features/house/data/dtos/house_data_response.dart';
import 'package:exif/exif.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class EditHousePage extends StatefulWidget {
  final HouseDataResponse houseData;

  const EditHousePage({super.key, required this.houseData});

  @override
  State<EditHousePage> createState() => _EditHousePageState();
}

class _EditHousePageState extends State<EditHousePage> {
  File? _selectedImage;
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _areaSizeController = TextEditingController();
  final _buildingAreaSizeController = TextEditingController();
  final _streetRowWidthController = TextEditingController();
  final _bedroomCountController = TextEditingController();
  final _bathroomCountController = TextEditingController();
  final _electricityCapacityController = TextEditingController();

  // Boolean values
  bool _isSHM = false;
  bool _isWellWater = false;
  bool _isPDAM = false;
  bool _isSale = true;
  bool _isRent = false;
  bool _isOneGate = false;
  bool _hasCarport = false;

  // Contact controllers
  final List<Map<String, TextEditingController>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  Future<Position?> _getCoordinatesFromImage(File image) async {
    try {
      final bytes = await image.readAsBytes();
      final tags = await readExifFromBytes(bytes);

      debugPrint(tags.toString());

      if (tags.containsKey('GPS GPSLatitude') &&
          tags.containsKey('GPS GPSLongitude')) {
        final latitude = tags['GPS GPSLatitude']!.values.toList();
        final longitude = tags['GPS GPSLongitude']!.values.toList();

        double convertToDegree(List values) {
          return values[0].toDouble() +
              values[1].toDouble() / 60 +
              values[2].toDouble() / 3600;
        }

        final lat = convertToDegree(latitude);
        final lon = convertToDegree(longitude);

        final latRef = tags['GPS GPSLatitudeRef']?.printable;
        final lonRef = tags['GPS GPSLongitudeRef']?.printable;

        final finalLat = (latRef == 'S') ? -lat : lat;
        final finalLon = (lonRef == 'W') ? -lon : lon;

        return Position(
          latitude: finalLat,
          longitude: finalLon,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
      }
    } catch (_) {
      // silently ignore errors
    }
    return null;
  }

  void _populateFields() {
    // Populate form fields with existing data
    _addressController.text = widget.houseData.address ?? '';
    _priceController.text = widget.houseData.price?.toString() ?? '';
    _latitudeController.text = widget.houseData.latitude.toString();
    _longitudeController.text = widget.houseData.longitude.toString();
    _lengthController.text = widget.houseData.length?.toString() ?? '';
    _widthController.text = widget.houseData.width?.toString() ?? '';
    _areaSizeController.text = widget.houseData.areaSize?.toString() ?? '';
    _buildingAreaSizeController.text =
        widget.houseData.buildingAreaSize?.toString() ?? '';
    _streetRowWidthController.text =
        widget.houseData.streetRowWidth?.toString() ?? '';
    _bedroomCountController.text =
        widget.houseData.bedroomCount?.toInt().toString() ?? '';
    _bathroomCountController.text =
        widget.houseData.bathroomCount?.toInt().toString() ?? '';
    _electricityCapacityController.text =
        widget.houseData.electricityCapacity?.toInt().toString() ?? '';

    // Set boolean values
    _isSHM = widget.houseData.isSHM ?? false;
    _isWellWater = widget.houseData.isWellWater ?? false;
    _isPDAM = widget.houseData.isPDAM ?? false;
    _isSale = widget.houseData.isSale ?? true;
    _isRent = widget.houseData.isRent ?? false;
    _isOneGate = widget.houseData.isOneGate ?? false;
    _hasCarport = widget.houseData.hasCarport ?? false;

    // Populate contacts
    for (var contact in widget.houseData.contacts) {
      _contacts.add({
        'name': TextEditingController(text: contact.name ?? ''),
        'phone': TextEditingController(text: contact.phoneNumber ?? ''),
        'company': TextEditingController(text: contact.companyName ?? ''),
      });
    }

    // Add at least one contact if none exist
    if (_contacts.isEmpty) {
      _addContact();
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    final uri = Uri.parse('${Config.apiBaseUrl}/api/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['path'] = 'house'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final resBody = await response.stream.bytesToString();
      final data = json.decode(resBody);
      return data['image_path'];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upload image'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    String? imageKey = widget.houseData.mainImageKey;
    if (_selectedImage != null) {
      imageKey = await _uploadImage(_selectedImage!);
      if (imageKey == null) return; // upload failed
    }

    double? toDouble(String text) =>
        text.isEmpty ? null : double.tryParse(text);

    final requestBody = {
      "id": widget.houseData.id,
      "main_image_key": imageKey,
      "address": _addressController.text,
      "price": toDouble(_priceController.text),
      "latitude": double.tryParse(_latitudeController.text) ?? 0,
      "longitude": double.tryParse(_longitudeController.text) ?? 0,
      "length": toDouble(_lengthController.text),
      "width": toDouble(_widthController.text),
      "area_size": toDouble(_areaSizeController.text),
      "building_area_size": toDouble(_buildingAreaSizeController.text),
      "is_shm": _isSHM,
      "is_well_water": _isWellWater,
      "is_pdam": _isPDAM,
      "is_sale": _isSale,
      "is_rent": _isRent,
      "is_one_gate": _isOneGate,
      "has_carport": _hasCarport,
      "street_row_width": toDouble(_streetRowWidthController.text),
      "bedroom_count": toDouble(_bedroomCountController.text),
      "bathroom_count": toDouble(_bathroomCountController.text),
      "electricity_capacity": toDouble(_electricityCapacityController.text),
      "contacts": _contacts
          .map(
            (c) => {
              "name": c['name']?.text,
              "phone_number": c['phone']?.text,
              "company_name": c['company']?.text,
            },
          )
          .toList(),
      "other_images": widget.houseData.otherImages
          .map((img) => img.toJson())
          .toList(),
    };

    final response = await http.put(
      Uri.parse('${Config.apiBaseUrl}/api/house-data'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('House data updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate data was updated
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update data: ${response.body}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    final file = File(pickedFile.path);
                    final position = await _getCoordinatesFromImage(file);

                    setState(() {
                      _selectedImage = file;
                      if (position != null) {
                        _latitudeController.text = position.latitude.toString();
                        _longitudeController.text = position.longitude
                            .toString();
                      }
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _priceController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _areaSizeController.dispose();
    _buildingAreaSizeController.dispose();
    _streetRowWidthController.dispose();
    _bedroomCountController.dispose();
    _bathroomCountController.dispose();
    _electricityCapacityController.dispose();
    _scrollController.dispose();

    // Dispose contact controllers
    for (var contact in _contacts) {
      contact['name']?.dispose();
      contact['phone']?.dispose();
      contact['company']?.dispose();
    }

    super.dispose();
  }

  void _addContact() {
    setState(() {
      _contacts.add({
        'name': TextEditingController(),
        'phone': TextEditingController(),
        'company': TextEditingController(),
      });
    });
  }

  void _removeContact(int index) {
    if (_contacts.length > 1) {
      setState(() {
        _contacts[index]['name']?.dispose();
        _contacts[index]['phone']?.dispose();
        _contacts[index]['company']?.dispose();
        _contacts.removeAt(index);
      });
    }
  }

  Future<void> _fetchCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are denied.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permissions are permanently denied.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get current location
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      left: false,
      right: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit ${widget.houseData.number}'),
          backgroundColor: Colors.blue,
          actions: [
            TextButton(
              onPressed: _submitForm,
              child: const Text(
                'SAVE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _centeredImageUploadWidget(),
                const SizedBox(height: 24),
                // Basic Information Section
                _buildSectionTitle('Basic Information'),
                _buildTextFormField(
                  controller: _addressController,
                  label: 'Address',
                  hint: 'Enter house address',
                  maxLines: 3,
                ),
                _buildTextFormField(
                  controller: _priceController,
                  label: 'Price',
                  hint: 'Enter price',
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 24),

                // Location Section
                _buildSectionTitle('Location'),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _latitudeController,
                        label: 'Latitude *',
                        hint: 'e.g., -6.2088',
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) => value?.isEmpty == true
                            ? 'Latitude is required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _longitudeController,
                        label: 'Longitude *',
                        hint: 'e.g., 106.8456',
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) => value?.isEmpty == true
                            ? 'Longitude is required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Use GPS',
                      onPressed: _fetchCurrentLocation,
                      icon: const Icon(Icons.my_location, color: Colors.blue),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Property Dimensions Section
                _buildSectionTitle('Property Dimensions'),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _lengthController,
                        label: 'Length (m)',
                        hint: 'e.g., 12.5',
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _widthController,
                        label: 'Width (m)',
                        hint: 'e.g., 8.0',
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _areaSizeController,
                        label: 'Area Size (m²)',
                        hint: 'e.g., 120',
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _buildingAreaSizeController,
                        label: 'Building Area (m²)',
                        hint: 'e.g., 96',
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                _buildTextFormField(
                  controller: _streetRowWidthController,
                  label: 'Street Width (car)',
                  hint: 'e.g., 6.0',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),

                const SizedBox(height: 24),

                // Room Details Section
                _buildSectionTitle('Room Details'),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _bedroomCountController,
                        label: 'Bedrooms',
                        hint: 'e.g., 3',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _bathroomCountController,
                        label: 'Bathrooms',
                        hint: 'e.g., 2',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                _buildTextFormField(
                  controller: _electricityCapacityController,
                  label: 'Electricity Capacity (VA)',
                  hint: 'e.g., 2200',
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 24),

                // Features Section
                _buildSectionTitle('Features'),
                _buildSwitchTile('SHM Certificate', _isSHM, (value) {
                  setState(() {
                    _isSHM = value;
                  });
                }),
                _buildSwitchTile('Well Water', _isWellWater, (value) {
                  setState(() {
                    _isWellWater = value;
                  });
                }),
                _buildSwitchTile('PDAM Water', _isPDAM, (value) {
                  setState(() {
                    _isPDAM = value;
                  });
                }),
                _buildSwitchTile('One Gate System', _isOneGate, (value) {
                  setState(() {
                    _isOneGate = value;
                  });
                }),
                _buildSwitchTile('Has Carport', _hasCarport, (value) {
                  setState(() {
                    _hasCarport = value;
                  });
                }),

                const SizedBox(height: 24),

                // Availability Section
                _buildSectionTitle('Availability'),
                _buildSwitchTile('For Sale', _isSale, (value) {
                  setState(() {
                    _isSale = value;
                  });
                }),
                _buildSwitchTile('For Rent', _isRent, (value) {
                  setState(() {
                    _isRent = value;
                  });
                }),

                const SizedBox(height: 24),

                // Contact Information Section
                _buildSectionTitle('Contact Information'),
                ..._contacts.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, TextEditingController> contact = entry.value;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Contact ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_contacts.length > 1)
                                IconButton(
                                  onPressed: () => _removeContact(index),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildTextFormField(
                            controller: contact['name']!,
                            label: 'Name',
                            hint: 'Enter contact name',
                          ),
                          _buildTextFormField(
                            controller: contact['phone']!,
                            label: 'Phone Number',
                            hint: 'e.g., +62812345678',
                            keyboardType: TextInputType.phone,
                          ),
                          _buildTextFormField(
                            controller: contact['company']!,
                            label: 'Company Name',
                            hint: 'Enter company name',
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Add Contact Button
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _addContact,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Contact'),
                  ),
                ),

                const SizedBox(height: 24),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Update House Data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _centeredImageUploadWidget() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  )
                : widget.houseData.mainImageKey != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.houseData.getImageUrl(),
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap to change image',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
