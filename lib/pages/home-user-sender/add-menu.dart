// ignore_for_file: file_names

import 'package:delivery_app/pages/home-user-sender/home-sender.dart';
import 'package:delivery_app/pages/home-user-sender/list-add-menu/Lunch.dart';
import 'package:delivery_app/pages/home-user-sender/list-add-menu/all-page.dart';
import 'package:delivery_app/pages/home-user-sender/profile-sender.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ListOrdersPage extends StatefulWidget {
  const ListOrdersPage({super.key});

  @override
  State<ListOrdersPage> createState() => _ListOrdersPageState();
}

class _ListOrdersPageState extends State<ListOrdersPage> {
  int _selectedIndex = 0;
  int _selectedTabIndex = 1;
  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

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
            child: const CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 15,
            ),
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTabBar(),
          const SizedBox(width: 60),
          _buildSearchCard(),
          Expanded(
            child: ListView(
              children: const [
                OrderItem(name: 'Justin', dish: 'Chicken Bhuna', id: '15253', price: 30),
                OrderItem(name: 'Justin', dish: 'Vegetarian Poutine', id: '21200', price: 35),
                OrderItem(name: 'Justin', dish: 'Turkey Bacon Strips', id: '53241', price: 45),
              ],
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem('All', 0),
          _buildTabItem('List Orders', 1),
          _buildTabItem('Lunch', 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
        switch (_selectedTabIndex) {
          case 0:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const allpage()));
          break;
          case 2:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LunchPage()));
          break;
        }
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.orange : Colors.black,
            ),
          ),
          if (isSelected)
            Container(
              height: 2,
              width: 70,
              color: Colors.orange,
            ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment:CrossAxisAlignment.start,
                children: [
                  const Text('ที่อยู่'),Row(
                    children: [
                      // const SizedBox(height: 20,),
                      Text('xx/xx', style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                ],
              ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'IMG:xxxxxx',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () => _pickImage(ImageSource.camera), // ถ่ายรูป
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: () => _pickImage(ImageSource.gallery), // เลือกรูปจากแกลเลอรี
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        if (_image != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Image.file(
              _image!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('จัดส่งสินค้า', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 50, height: 30),
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
              _buildNavItem(Icons.dehaze, '●', 1),
              const SizedBox(width: 60), // Space for FAB
              _buildNavItem(Icons.apps, '', 2),
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

class OrderItem extends StatelessWidget {
  final String name;
  final String dish;
  final String id;
  final double price;

  const OrderItem({
    super.key,
    required this.name,
    required this.dish,
    required this.id,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.orange)),
                Text(dish, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('ID: $id', style: TextStyle(color: Colors.grey[600])),
                Text('\$$price', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}