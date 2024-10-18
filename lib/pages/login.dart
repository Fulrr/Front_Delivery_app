import 'dart:convert';
import 'package:delivery_app/pages/home-rider/home-rider.dart';
import 'package:delivery_app/pages/home_user/home-re.dart';
import 'package:delivery_app/pages/reg-rider.dart';
import 'package:delivery_app/pages/register.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;
import 'package:delivery_app/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  late SharedPreferences prefs;
  String errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    initSharedPref();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void loginUser() async {
    if (_formKey.currentState!.validate()) {
      var reqBody = {
        "phone": _phoneController.text,
        "password": _passwordController.text,
      };

      try {
        var response = await http.post(Uri.parse(login),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(reqBody));

        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status']) {
          var myToken = jsonResponse['token'];
          var userType = jsonResponse['userType'];
          prefs.setString('token', myToken);
          prefs.setString('userType', userType);

          if (userType == 'user') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const FoodHomeScreen()),
            );
          } else if (userType == 'rider') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeRiderPage()),
            );
          }
        } else {
          _showErrorSnackBar("Login failed. Please check your credentials.");
          dev.log(
              'Login failed: ${jsonResponse['message'] ?? "Unknown error"}');
        }
      } catch (e) {
        _showErrorSnackBar("An error occurred. Please try again later.");
        dev.log('Error during login: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    ).then((value) {
      if (value == true) {
        // Use SystemNavigator.pop() to close the app
        // SystemNavigator.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showExitDialog(context);
        return false; // Prevents closing the screen by pressing back
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      prefixText: '+66 ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกหมายเลขโทรศัพท์';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.visibility_off),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกรหัสผ่าน';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('SIGN IN'),
                  ),
                  const SizedBox(height: 16),
                  const Spacer(),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    const Text("Don't have an UserAccount? "),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => SignUpScreen()),
                                        );
                                      },
                                      child: const Text(
                                        "Sign up",
                                        style: TextStyle(
                                          color: Colors.red,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    const Text("Don't have an RiderAccount? "),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => SignUpRider()),
                                        );
                                      },
                                      child: const Text(
                                        "Sign up",
                                        style: TextStyle(
                                          color: Colors.red,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.facebook),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.alternate_email),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.g_mobiledata),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
