import 'dart:developer';
import 'package:delivery_app/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SignUpRider extends StatefulWidget {
  const SignUpRider({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpRiderState createState() => _SignUpRiderState();
}

class _SignUpRiderState extends State<SignUpRider> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  File? _image;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController(); // New field for address
  final _latitudeController = TextEditingController(); // New field for latitude
  final _longitudeController =
      TextEditingController(); // New field for longitude

  bool _isNameValid = false;
  bool _isEmailValid = false;
  bool _isPhoneValid = false;
  bool _isAddressValid = false;
  bool _isLatitudeValid = false;
  bool _isLongitudeValid = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up Raider'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                  } else {
                    setState(() {
                      _isNameValid = true;
                    });
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
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'EMAIL',
                  suffixIcon: _isEmailValid
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  border: const UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกอีเมล';
                  } else {
                    setState(() {
                      _isEmailValid = true;
                    });
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _isEmailValid = value.isNotEmpty;
                  });
                },
              ),
              const SizedBox(height: 16),
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
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
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
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'PHONE NUMBER',
                  prefixText: '+66 ',
                  suffixIcon: _isPhoneValid
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  border: const UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกเบอร์โทรศัพท์';
                  } else {
                    setState(() {
                      _isPhoneValid = true;
                    });
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _isPhoneValid = value.isNotEmpty;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController, // New field for address
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
                  } else {
                    setState(() {
                      _isAddressValid = true;
                    });
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _isAddressValid = value.isNotEmpty;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Perform sign up logic
                    log('Sign up successful');
                    // Here you can send the data to your backend or any further processing
                  } else {
                    _showErrorDialog('กรุณากรอกข้อมูลให้ครบถ้วนและถูกต้อง');
                  }
                },
                child: const Text('SIGN UP'),
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
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.facebook, color: Colors.blue),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.alternate_email,
                        color: Colors.lightBlue),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Text('G',
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 24)),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
