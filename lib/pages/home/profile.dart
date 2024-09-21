import 'package:delivery_app/pages/home/home-re.dart';
import 'package:delivery_app/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodProfileScreen extends StatefulWidget {
  const FoodProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FoodProfileScreenState createState() => _FoodProfileScreenState();
}

class _FoodProfileScreenState extends State<FoodProfileScreen> {
  int _selectedIndex = 1; // Set to 1 for Profile tab

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
            _buildProfileHeader(),
            _buildProfileOptions(),
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
            backgroundImage: NetworkImage('https://i.pinimg.com/564x/43/6b/47/436b47519f01232a329d90f75dbeb3f4.jpg'),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'user0',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'user0@gmail.com',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Handle edit profile
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
          title: Text(title),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            setState(() {
          _selectedIndex = index;
        });
        switch (_selectedIndex) {
          case 0:
            // Navigator.push(context, MaterialPageRoute(builder: (context) => FoodHomeScreen()));
            break;
          case 1:
            // Navigator.push(context, MaterialPageRoute(builder: (context) => FoodProfileScreen()));
            break;
          case 2:
            // Navigator.push(context, MaterialPageRoute(builder: (context) => FoodHomeScreen()));
            break;
          case 3:
            // Navigator.push(context, MaterialPageRoute(builder: (context) => FoodHomeScreen()));
            break;
          case 4:
            // Navigator.push(context, MaterialPageRoute(builder: (context) => FoodHomeScreen()));
            break;
          case 5:
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            break;
        }
          },
        ),
        // if (!isLast) const Divider(height: 1),
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const FoodHomeScreen()));
            break;
          case 1:
            // Navigator.push(context, MaterialPageRoute(builder: (context) => FoodProfileScreen()));
            break;
          case 2:
            // Navigator.push(context, MaterialPageRoute(builder: (context) => FoodHomeScreen()));
            break;
          case 3:
            // Navigator.push(context, MaterialPageRoute(builder: (context) => FoodHomeScreen()));
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
