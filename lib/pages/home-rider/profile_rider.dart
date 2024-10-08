import 'package:delivery_app/pages/list-on-profile-users/edit_profile.dart';
import 'package:delivery_app/pages/list-on-profile-users/histrory.dart';
import 'package:delivery_app/pages/home-rider/home-rider.dart';
import 'package:delivery_app/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class RiderProfileScreen extends StatefulWidget {
  const RiderProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RiderProfileScreenState createState() => _RiderProfileScreenState();
}

class _RiderProfileScreenState extends State<RiderProfileScreen> {
  int _selectedIndex = 1; // Set to 1 for Profile tab
  String userType = 'rider'; // เปลี่ยนเป็น rider

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFef2a38),
        elevation: 0,
        title: Text(
          'Rider Profile', // เปลี่ยนชื่อเป็น Rider Profile
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
          const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
                'https://i.pinimg.com/564x/43/6b/47/436b47519f01232a329d90f75dbeb3f4.jpg'),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'rider0', // เปลี่ยนชื่อผู้ใช้ให้เป็น rider
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'rider0@gmail.com', // เปลี่ยน email ให้ตรงกับ rider
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const EditProfile()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Column(
      children: [
        _buildOptionTile(Icons.history, 'Order History', 0),
        _buildOptionTile(Icons.payment, 'Payment Method', 1),
        _buildOptionTile(Icons.location_on, 'My Address', 2),
        _buildOptionTile(Icons.card_giftcard, 'My Promocodes', 3),
        _buildOptionTile(Icons.favorite, 'My Favorite', 4),
        _buildOptionTile(Icons.exit_to_app, 'Sign out', 5),
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
            style: GoogleFonts.lato(), // Apply font style here
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            switch (_selectedIndex) {
              case 0:
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OrderHistoryPage()));
                break;
              case 1:
                // Handle Payment Method
                break;
              case 2:
                // Handle My Address
                break;
              case 3:
                // Handle My Promocodes
                break;
              case 4:
                // Handle My Favorite
                break;
              case 5:
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const LoginScreen().animate().moveX()));
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
              _buildNavItem(Icons.person, '●', 1),
              const SizedBox(width: 60),
              _buildNavItem(Icons.shopping_cart, '', 2),
              _buildNavItem(Icons.favorite, '', 3),
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
                    builder: (context) => HomeRiderPage()
                        .animate()
                        .slideX(begin: -1, end: 0, curve: Curves.ease)));
            break;
          case 1:
            // Do nothing as it's the current screen
            break;
          case 2:
            // Handle Cart
            break;
          case 3:
            // Handle Favorites
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
