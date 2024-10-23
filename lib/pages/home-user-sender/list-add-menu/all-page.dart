// ignore_for_file: file_names, camel_case_types

import 'dart:convert';
import 'package:delivery_app/pages/home-user-sender/home-sender.dart';
import 'package:delivery_app/pages/home-user-sender/list-add-menu/Lunch.dart';
import 'package:delivery_app/pages/home-user-sender/profile-sender.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:delivery_app/pages/home-rider/Delivery_Details_Page.dart';
import 'package:delivery_app/config/config.dart';

class allpage extends StatefulWidget {
  const allpage({super.key});

  @override
  State<allpage> createState() => _allpageState();
}

class _allpageState extends State<allpage> {
  int _selectedIndex = 1;
  List<dynamic> orders = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAvailableOrders();
  }

  Future<void> fetchAvailableOrders() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(getAvailableOrders));
      if (response.statusCode == 200) {
        setState(() {
          orders = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dalivery'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Menus',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? const Center(
                        child: Text('ไม่มีคำสั่งที่พร้อมให้รับในขณะนี้'))
                    : ListView.builder(
                        itemCount: orders
                            .where((order) => order['items'][0]['orders'] == 3)
                            .length,
                        itemBuilder: (context, index) {
                          final filteredOrders = orders
                              .where(
                                  (order) => order['items'][0]['orders'] == 3)
                              .toList();
                          final order = filteredOrders[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: order['imageUrls'].isNotEmpty
                                    ? Image.network(order['imageUrls'][0],
                                        fit: BoxFit.cover)
                                    : const Icon(Icons.image_not_supported),
                              ),
                              title: Text(order['items'][0]['name']),
                              subtitle: Text(
                                  '฿${order['totalAmount'].toStringAsFixed(2)}'),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          LunchPage(order: order),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: const Text('รายละเอียด'),
                              ),
                            ),
                          );
                        },
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
              MaterialPageRoute(builder: (context) => const HomesenderPage()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SendProfileScreen()),
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
