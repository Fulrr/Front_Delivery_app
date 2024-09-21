// ignore_for_file: file_names

import 'package:delivery_app/pages/home/profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FoodHomeScreen extends StatefulWidget {
  const FoodHomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FoodHomeScreenState createState() => _FoodHomeScreenState();
}

class _FoodHomeScreenState extends State<FoodHomeScreen> {
  int _selectedIndex = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          'Foodgo',
          style: GoogleFonts.lobster(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          CircleAvatar(
            backgroundImage:
                CachedNetworkImageProvider('https://i.pinimg.com/564x/43/6b/47/436b47519f01232a329d90f75dbeb3f4.jpg'),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order your favourite food!',
              style:
                  GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSearchField(),
            const SizedBox(height: 16),
            _buildCategoryChips(),
            const SizedBox(height: 16),
            _buildFoodGrid(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryChip('All', isSelected: true),
          _buildCategoryChip('Combos'),
          _buildCategoryChip('Sliders'),
          _buildCategoryChip('Cla'),
        ],
      ),
    );
  }

  Widget _buildFoodGrid() {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        children: [
          _buildFoodItem('Cheeseburger', "Wendy's Burger", 4.9),
          _buildFoodItem('Hamburger', 'Veggie Burger', 4.8),
          _buildFoodItem('Chicken Burger', 'Grilled Chicken Burger', 4.6),
          _buildFoodItem('Fried Chicken', 'Crispy Fried Chicken', 4.5),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        // color: Colors.red,
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
              _buildNavItem(Icons.home, '●', 0), //home
              _buildNavItem(Icons.person, '', 1), //Profile
              const SizedBox(width: 60), // Space for FAB
              _buildNavItem(Icons.shopping_cart, '', 2), //Cart
              _buildNavItem(Icons.favorite, '', 3), //Favorites
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
            // Navigator.push(context, MaterialPageRoute(builder: (context) => FoodHomeScreen()));
            break;
          case 1:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const FoodProfileScreen()));
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
        color: Colors.red, // Background color
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4), // Shadow color
            spreadRadius: 3, // Spread radius
            blurRadius: 4, // Blur radius
            offset: const Offset(0, 1), // Changes position of shadow
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Action when tapped
        },
        child: const SizedBox(
          width: 65, // Width of the button
          height: 65, // Height of the button
          child: Icon(Icons.add, size: 35, color: Colors.white), // Icon
        ),
      ),
    );
  }

  // BottomNavigationBar _buildBottomNavigationBar() {
  //   return BottomNavigationBar(
  //     items: const <BottomNavigationBarItem>[
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.home),
  //         label: 'Home',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.person),
  //         label: 'Profile',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.shopping_cart),
  //         label: 'Cart',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.favorite),
  //         label: 'Favorites',
  //       ),
  //     ],
  //     currentIndex: _selectedIndex,
  //     selectedItemColor: Colors.red,
  //     unselectedItemColor: Colors.grey,
  //     onTap: _onItemTapped,
  //   );
  // }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Chip(
        label: Text(label),
        backgroundColor: isSelected ? Colors.red : Colors.grey[200],
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildFoodItem(String title, String subtitle, double rating) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: const Center(
                  child: Text('Food Image')), // Replace with actual image
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 16),
                    const SizedBox(width: 4),
                    Text(rating.toString()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
