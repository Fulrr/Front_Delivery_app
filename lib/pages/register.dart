import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:delivery_app/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

// Location Picker Dialog
class LocationPickerDialog extends StatefulWidget {
  final String? initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;

  const LocationPickerDialog({
    Key? key,
    this.initialAddress,
    this.initialLatitude,
    this.initialLongitude,
  }) : super(key: key);

  @override
  _LocationPickerDialogState createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String? _selectedAddress;
  bool _isLoading = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
      _searchController.text = widget.initialAddress ?? '';
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
      await _getAddressFromLatLng(_selectedLocation!);
    } catch (e) {
      // Default to Bangkok coordinates if location access is denied
      setState(() {
        _selectedLocation = const LatLng(13.7563, 100.5018);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}';
        setState(() {
          _selectedAddress = address;
          _searchController.text = address;
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
  }

  Future<void> _searchLocation(String query) async {
    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final newLatLng = LatLng(location.latitude, location.longitude);

        setState(() => _selectedLocation = newLatLng);
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newLatLng, 15),
        );
        await _getAddressFromLatLng(newLatLng);
      }
    } catch (e) {
      debugPrint('Error searching location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ค้นหาสถานที่',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchLocation(_searchController.text),
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: _searchLocation,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _selectedLocation ??
                                const LatLng(13.7563, 100.5018),
                            zoom: 15,
                          ),
                          onMapCreated: (controller) =>
                              _mapController = controller,
                          markers: _selectedLocation == null
                              ? {}
                              : {
                                  Marker(
                                    markerId: const MarkerId('selected'),
                                    position: _selectedLocation!,
                                  ),
                                },
                          onTap: (location) async {
                            setState(() => _selectedLocation = location);
                            await _getAddressFromLatLng(location);
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _selectedLocation == null
                                ? null
                                : () => Navigator.of(context).pop({
                                      'address': _selectedAddress,
                                      'latitude': _selectedLocation!.latitude,
                                      'longitude': _selectedLocation!.longitude,
                                    }),
                            child: const Text('ยืนยันตำแหน่ง'),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}

// User Registration Model
class UserRegistration {
  final String name;
  final String phone;
  final String password;
  final String confpass;
  final String type;
  final String? profileImage;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? vehicleNumber;

  UserRegistration({
    required this.name,
    required this.phone,
    required this.password,
    required this.confpass,
    required this.type,
    this.profileImage,
    this.address,
    this.latitude,
    this.longitude,
    this.vehicleNumber,
  });

  Map<String, dynamic> toJson() {
    final cleanPhone = phone.replaceAll('+66 ', '').replaceAll(' ', '');
    final Map<String, dynamic> json = {
      'name': name,
      'phone': cleanPhone,
      'password': password,
      'confpass': confpass,
      'type': type,
    };

    if (profileImage != null) json['profileImage'] = profileImage;

    if (type == 'user' || type == 'send') {
      if (address == null || latitude == null || longitude == null) {
        throw Exception('ที่อยู่และพิกัด GPS จำเป็นสำหรับผู้ใช้');
      }
      json['address'] = address;
      json['latitude'] = latitude;
      json['longitude'] = longitude;
    } else if (type == 'rider') {
      // Default GPS coordinates for riders
      json['latitude'] = 16.2465517;
      json['longitude'] = 103.25204;
      if (vehicleNumber == null) {
        throw Exception('หมายเลขทะเบียนรถจำเป็นสำหรับไรเดอร์');
      }
      json['vehicleNumber'] = vehicleNumber;
    }

    return json;
  }
}

// API Service
class UserRegistrationService {
  static const String baseUrl = 'http://192.168.0.200:8081/api';

  Future<Map<String, dynamic>> registerUser(
      UserRegistration registration) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/registration'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(registration.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
}

// SignUp Screen
class SignUpScreen extends StatefulWidget {
  final UserRegistration? initialData;
  final String userType;

  const SignUpScreen({
    super.key,
    this.initialData,
    required this.userType,
  });

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _registrationService = UserRegistrationService();

  late final TextEditingController _nameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _vehicleNumberController;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  File? _image;
  String? _profileImageUrl;
  double? _latitude;
  double? _longitude;

  bool _isNameValid = false;
  bool _isPhoneValid = false;
  bool _isAddressValid = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController =
        TextEditingController(text: widget.initialData?.name ?? '');
    _passwordController =
        TextEditingController(text: widget.initialData?.password ?? '');
    _confirmPasswordController =
        TextEditingController(text: widget.initialData?.confpass ?? '');
    _phoneController =
        TextEditingController(text: widget.initialData?.phone ?? '');
    _addressController =
        TextEditingController(text: widget.initialData?.address ?? '');
    _vehicleNumberController = TextEditingController();

    if (widget.initialData != null) {
      _profileImageUrl = widget.initialData!.profileImage;
      _latitude = widget.initialData!.latitude;
      _longitude = widget.initialData!.longitude;

      _isNameValid = _nameController.text.isNotEmpty;
      _isPhoneValid = _phoneController.text.isNotEmpty;
      _isAddressValid = _addressController.text.isNotEmpty;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _profileImageUrl = null;
      });
    }
  }

  Future<void> _showLocationPicker() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => LocationPickerDialog(
        initialAddress: _addressController.text,
        initialLatitude: _latitude,
        initialLongitude: _longitude,
      ),
    );

    if (result != null) {
      setState(() {
        _addressController.text = result['address'];
        _latitude = result['latitude'];
        _longitude = result['longitude'];
        _isAddressValid = true;
      });
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกเบอร์โทรศัพท์';
    }
    final cleanPhone = value.replaceAll('+66 ', '').replaceAll(' ', '');
    if (!RegExp(r'^\d{10}$').hasMatch(cleanPhone)) {
      return 'กรุณากรอกเบอร์โทรศัพท์ 10 หลัก';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }
    if (value.length < 3) {
      return 'รหัสผ่านต้องมีความยาวอย่างน้อย 3 ตัวอักษร';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณายืนยันรหัสผ่าน';
    }
    if (value != _passwordController.text) {
      return 'รหัสผ่านไม่ตรงกัน';
    }
    return null;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ข้อผิดพลาด'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorDialog('กรุณากรอกข้อมูลให้ครบถ้วนและถูกต้อง');
      return;
    }

    if ((widget.userType == 'user' || widget.userType == 'send') &&
        (_addressController.text.isEmpty ||
            _latitude == null ||
            _longitude == null)) {
      _showErrorDialog('กรุณาระบุที่อยู่และพิกัด GPS');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final registration = UserRegistration(
        name: _nameController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        confpass: _confirmPasswordController.text,
        type: widget.userType,
        profileImage: _profileImageUrl,
        address: _addressController.text,
        latitude: widget.userType == 'rider' ? 16.2465517 : _latitude,
        longitude: widget.userType == 'rider' ? 103.25204 : _longitude,
        vehicleNumber:
            widget.userType == 'rider' ? _vehicleNumberController.text : null,
      );

      await _registrationService.registerUser(registration);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลงทะเบียนสำเร็จ')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      String errorMessage = 'การลงทะเบียนล้มเหลว';

      if (e.toString().contains('หมายเลขโทรศัพท์ถูกใช้แล้ว')) {
        errorMessage = 'หมายเลขโทรศัพท์นี้ถูกใช้งานแล้ว';
      } else if (e.toString().contains('GPS')) {
        errorMessage = 'กรุณาระบุที่อยู่และพิกัด GPS';
      }

      if (mounted) {
        _showErrorDialog(errorMessage);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ลงทะเบียน'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: _image != null
                      ? ClipOval(
                          child: Image.file(
                            _image!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _profileImageUrl != null
                          ? ClipOval(
                              child: Image.network(
                                _profileImageUrl!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.grey,
                            ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อผู้ใช้',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกชื่อผู้ใช้';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() => _isNameValid = value.isNotEmpty);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'เบอร์โทรศัพท์',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
                onChanged: (value) {
                  final cleanPhone =
                      value.replaceAll('+66 ', '').replaceAll(' ', '');
                  setState(() =>
                      _isPhoneValid = RegExp(r'^\d{10}$').hasMatch(cleanPhone));
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'ยืนยันรหัสผ่าน',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => setState(() =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  ),
                ),
                validator: _validateConfirmPassword,
              ),
              if (widget.userType == 'user' || widget.userType == 'send') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'ที่อยู่',
                    prefixIcon: const Icon(Icons.location_on),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.map),
                      onPressed: _showLocationPicker,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาระบุที่อยู่';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() => _isAddressValid = value.isNotEmpty);
                  },
                ),
              ],
              if (widget.userType == 'rider') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vehicleNumberController,
                  decoration: const InputDecoration(
                    labelText: 'หมายเลขทะเบียนรถ',
                    prefixIcon: Icon(Icons.directions_bike),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกหมายเลขทะเบียนรถ';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'ลงทะเบียน',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }
}
