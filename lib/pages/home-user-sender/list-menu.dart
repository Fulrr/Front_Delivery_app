import 'package:delivery_app/pages/home-user-sender/add-menu.dart';
import 'package:delivery_app/pages/home-user-sender/home-sender.dart';
import 'package:delivery_app/pages/home-user-sender/profile-sender.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenusenderPage extends StatefulWidget {
  const MenusenderPage({super.key});

  @override
  State<MenusenderPage> createState() => _MenusenderPageState();
}

class _MenusenderPageState extends State<MenusenderPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        title: const Row(
          children: [
            Text(
              'LOCATION',
              style: TextStyle(color: Colors.orange, fontSize: 14),
            ),
            SizedBox(width: 8),
            Text(
              'Halal Lab office',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.black),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 15,
            ),
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Menus',
              style: GoogleFonts.itim(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
              const SizedBox(width: 60), // Space for FAB
              _buildNavItem(Icons.apps, '●', 2),
              _buildNavItem(Icons.person, '', 3),
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
                    builder: (context) => const HomesenderPage()));
          break;
          case 1:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ListOrdersPage()));
          break;
          case 3:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SendProfileScreen()));
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
