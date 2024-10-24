// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';
import 'dart:convert';
import 'package:delivery_app/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class SignUpRider extends StatefulWidget {
  const SignUpRider({super.key});

  @override
  _SignUpRiderState createState() => _SignUpRiderState();
}

class _SignUpRiderState extends State<SignUpRider> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  File? _image;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController =
      TextEditingController(text: '13.736717'); // Default value
  final _longitudeController =
      TextEditingController(text: '100.523186'); // Default value
  final _vehicleNumberController = TextEditingController();

  bool _isNameValid = false;
  bool _isPhoneValid = false;
  bool _isAddressValid = false;
  bool _isVehicleNumberValid = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Compress image quality
      maxWidth: 1024, // Max width
      maxHeight: 1024, // Max height
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare the registration data
      final Map<String, dynamic> registrationData = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'password': _passwordController.text,
        'confpass': _confirmPasswordController.text,
        'type': 'rider',
        'address': _addressController.text,
        'latitude': _latitudeController.text,
        'longitude': _longitudeController.text,
        'vehicleNumber': _vehicleNumberController.text,
      };

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://back-deliverys.onrender.com/api/users/registration'),
      );

      // Add text fields
      registrationData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add image if selected
      if (_image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            _image!.path,
          ),
        );
      }

      // Send the request
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final decodedResponse = json.decode(responseData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('สำเร็จ'),
              content: const Text('ลงทะเบียนเรียบร้อยแล้ว'),
              actions: <Widget>[
                TextButton(
                  child: const Text('ตกลง'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        if (!mounted) return;
        _showErrorDialog(decodedResponse['message'] ??
            'การลงทะเบียนล้มเหลว กรุณาลองใหม่อีกครั้ง');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('เกิดข้อผิดพลาดในการเชื่อมต่อ กรุณาลองใหม่อีกครั้ง');
      log('Registration error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up Rider'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Image
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            backgroundImage:
                                _image != null ? FileImage(_image!) : null,
                            child: _image == null
                                ? Icon(Icons.person,
                                    size: 50, color: Colors.grey[600])
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.edit,
                                  size: 20, color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'NAME',
                      suffixIcon: _isNameValid
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      border: const UnderlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกชื่อ';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _isNameValid = value.isNotEmpty;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'PHONE NUMBER',
                      suffixIcon: _isPhoneValid
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      border: const UnderlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกเบอร์โทรศัพท์';
                      }
                      if (value.length != 10) {
                        return 'กรุณากรอกเบอร์โทรศัพท์ให้ครบ 10 หลัก';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _isPhoneValid = value.length == 10;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'PASSWORD',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: const UnderlineInputBorder(),
                    ),
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกรหัสผ่าน';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'CONFIRM PASSWORD',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      border: const UnderlineInputBorder(),
                    ),
                    obscureText: !_isConfirmPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณายืนยันรหัสผ่าน';
                      }
                      if (value != _passwordController.text) {
                        return 'รหัสผ่านไม่ตรงกัน';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Address Field
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'ADDRESS',
                      suffixIcon: _isAddressValid
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      border: const UnderlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกที่อยู่';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _isAddressValid = value.isNotEmpty;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Vehicle Number Field (New)
                  TextFormField(
                    controller: _vehicleNumberController,
                    decoration: InputDecoration(
                      labelText: 'VEHICLE NUMBER',
                      suffixIcon: _isVehicleNumberValid
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      border: const UnderlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกเลขทะเบียนรถ';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _isVehicleNumberValid = value.isNotEmpty;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              _registerUser();
                            } else {
                              _showErrorDialog(
                                  'กรุณากรอกข้อมูลให้ครบถ้วนและถูกต้อง');
                            }
                          },
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('SIGN UP'),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? '),
                      GestureDetector(
                        child: const Text('Sign in.',
                            style: TextStyle(color: Colors.red)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
