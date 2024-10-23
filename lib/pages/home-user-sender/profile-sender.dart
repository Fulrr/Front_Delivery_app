import 'dart:convert';
import 'package:delivery_app/pages/home-user-sender/home-sender.dart';
import 'package:delivery_app/pages/home-user-sender/list-menu.dart';
import 'package:delivery_app/pages/list-on-profile-users/edit_profile.dart';
import 'package:delivery_app/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:delivery_app/config/config.dart';

class SendProfileScreen extends StatefulWidget {
  const SendProfileScreen({super.key});

  @override
  _SendProfileScreenState createState() => _SendProfileScreenState();
}

class _SendProfileScreenState extends State<SendProfileScreen> {
  int _selectedIndex = 1;
  String userType = 'user';
  String userName = '';
  String userEmail = '';
  String userPhone = '';
  String userImage = 'https://i.pinimg.com/564x/43/6b/47/436b47519f01232a329d90f75dbeb3f4.jpg';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userId = prefs.getString('userId');

      if (token != null && userId != null) {
        var response = await http.get(
          Uri.parse('https://back-deliverys.onrender.com/api/users/$userId'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
        );

        if (response.statusCode == 200) {
          var userData = jsonDecode(response.body);
          setState(() {
            userName = userData['name'] ?? 'User';
            userEmail = userData['email'] ?? 'email@example.com';
            userPhone = userData['phone'] ?? '';
            userImage = userData['profileImage'] ?? userImage;
          });
        } else {
          print('Failed to load user data');
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _handleSignOut() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFef2a38),
        elevation: 0,
        title: Text(
          'My Profile',
          style: GoogleFonts.lobster(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader().animate().fadeIn(),
            _buildProfileOptions().animate().fadeIn(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFef2a38),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(userImage),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Text(
                  userEmail,
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  userPhone,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfile())
              ).then((_) => _loadUserData());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Column(
      children: [
        _buildOptionTile(Icons.payment, 'Payment Method', 0),
        _buildOptionTile(Icons.location_on, 'My Address', 1),
        _buildOptionTile(Icons.exit_to_app, 'Sign out', 2),
      ],
    );
  }

  Widget _buildOptionTile(IconData icon, String title, int index) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.grey),
          title: Text(
            title,
            style: GoogleFonts.lato(),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () async {
            switch (index) {
              case 0:
                // Handle payment method
                break;
              case 1:
                // Handle address
                break;
              case 2:
                await _handleSignOut();
                break;
            }
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomAppBar(
        color: const Color(0xFFef2a38),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(Icons.home, '', 0),
              _buildNavItem(Icons.dehaze, '', 1),
              const SizedBox(width: 60),
              _buildNavItem(Icons.apps, '', 2),
              _buildNavItem(Icons.person, '●', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        switch (_selectedIndex) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomesenderPage()
                  .animate()
                  .slideX(begin: -1, end: 0, curve: Curves.ease)
              )
            );
            break;
          case 1:
            // Current screen - do nothing
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MenusenderPage())
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SendProfileScreen())
            );
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _selectedIndex == index ? Colors.white : Colors.white,
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? Colors.white : Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            spreadRadius: 3,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Action when tapped
        },
        child: const SizedBox(
          width: 65,
          height: 65,
          child: Icon(Icons.add, size: 35, color: Colors.white),
        ),
      ),
    );
  }
}