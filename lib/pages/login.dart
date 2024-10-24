import 'dart:convert';
import 'package:delivery_app/config/config.dart';
import 'package:delivery_app/pages/home-rider/home-rider.dart';
import 'package:delivery_app/pages/home-user-sender/home-sender.dart';
import 'package:delivery_app/pages/home_user/home-re.dart';
import 'package:delivery_app/pages/reg-rider.dart';
import 'package:delivery_app/pages/register.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Constants
class AuthConstants {
  static const String userIdKey = 'userId';
  static const String tokenKey = 'token';
  static const String userTypeKey = 'userType';
}

// Authentication service
class AuthService {
  final String loginUrl;
  
  AuthService({required this.loginUrl});

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phone,
          "password": password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      dev.log('Login error: $e');
      throw Exception('Failed to login');
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  late SharedPreferences prefs;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  late final AuthService _authService;
  
  @override
  void initState() {
    super.initState();
    _authService = AuthService(loginUrl: login); // Replace 'login' with your URL
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกหมายเลขโทรศัพท์';
    }
    // Add more phone validation if needed
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }
    // Add more password validation if needed
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.login(
        _phoneController.text,
        _passwordController.text,
      );

      if (response['status']) {
        await _handleSuccessfulLogin(response);
      } else {
        _showErrorMessage("Login failed. Please check your credentials.");
      }
    } catch (e) {
      _showErrorMessage("An error occurred. Please try again later.");
      dev.log('Login error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSuccessfulLogin(Map<String, dynamic> response) async {
    final token = response['token'];
    final userType = response['userType'];
    final decodedToken = JwtDecoder.decode(token);
    final userId = decodedToken['_id'];

    await Future.wait([
      prefs.setString(AuthConstants.userIdKey, userId),
      prefs.setString(AuthConstants.tokenKey, token),
      prefs.setString(AuthConstants.userTypeKey, userType),
    ]);

    _navigateToHomeScreen(userType);
  }

  void _navigateToHomeScreen(String userType) {
    final routes = {
      'user': const FoodHomeScreen(),
      'rider': const HomeRiderPage(),
      'send': const HomesenderPage(),
    };

    final widget = routes[userType];
    if (widget != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => widget),
      );
    }
  }

  void _showErrorMessage(String message) {
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                _buildPhoneField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 24),
                _buildLoginButton(),
                const Divider(height: 48),
                _buildSignUpOptions(),
                _buildSocialLoginButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      decoration: const InputDecoration(
        labelText: 'Phone number',
        prefixText: '+66 ',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.phone,
      validator: _validatePhone,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() => _isPasswordVisible = !_isPasswordVisible);
          },
        ),
      ),
      obscureText: !_isPasswordVisible,
      validator: _validatePassword,
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('SIGN IN'),
    );
  }

  Widget _buildSignUpOptions() {
    return Column(
      children: [
        _buildSignUpOption(
          text: "Don't have an UserAccount? ",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignUpScreen()),
          ),
        ),
        const SizedBox(height: 8),
        _buildSignUpOption(
          text: "Don't have an RiderAccount? ",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignUpRider()),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpOption({required String text, required VoidCallback onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text),
        GestureDetector(
          onTap: onTap,
          child: const Text(
            "Sign up",
            style: TextStyle(
              color: Colors.red,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Row(
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
    );
  }
}