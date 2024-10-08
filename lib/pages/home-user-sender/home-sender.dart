import 'dart:developer';

import 'package:delivery_app/pages/home-user-sender/add-menu.dart';
import 'package:delivery_app/pages/home-user-sender/list-menu.dart';
import 'package:delivery_app/pages/home-user-sender/profile-sender.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Order {
  final String id;
  final String customerName;
  final String itemName;
  final double price;
  final String phone;

  Order(
      {required this.id,
      required this.customerName,
      required this.phone,
      required this.itemName,
      required this.price});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      customerName: json['recipient']['name'],
      phone: json['recipient']['phone'],
      itemName: json['items'][0]['name'],
      price: json['totalAmount'].toDouble(),
    );
  }
}

class HomesenderPage extends StatefulWidget {
  const HomesenderPage({super.key});

  @override
  State<HomesenderPage> createState() => _HomesenderPageState();
}

class _HomesenderPageState extends State<HomesenderPage> {
  int _selectedIndex = 0;
  List<Order> orders = [];
  List<Order> filteredOrders = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  final String url = 'http://10.210.60.215:8081/api/orders/';

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          orders = jsonData.map((data) => Order.fromJson(data)).toList();
          filteredOrders = orders;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      log('Error fetching orders: $e');
    }
  }

  void searchOrders(String query) {
  setState(() {
    filteredOrders = orders.where((order) =>
      order.customerName.toLowerCase().contains(query.toLowerCase()) ||
      order.phone.toLowerCase().contains(query.toLowerCase())
    ).toList();
  });
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
              'Orders',
              style: GoogleFonts.itim(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or ID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: searchOrders,
              style: GoogleFonts.itim(),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                searchOrders(searchController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('ค้นหาผู้รับสินค้า', style: GoogleFonts.itim(fontSize: 14)),
            ),
          ),
          const Center(
            child: FractionallySizedBox(
              widthFactor: 0.9, // 80% of the available width
              child: Divider(color: Colors.black),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.customerName,
                                          style: GoogleFonts.itim(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          order.itemName,
                                          style: GoogleFonts.itim(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                            'ID: ${order.phone}',style: GoogleFonts.itim()),
                                        Text(
                                          '\$${order.price.toStringAsFixed(2)}',
                                          style: GoogleFonts.itim(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Implement accept order functionality
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text('เพิ่ม',
                                      style: GoogleFonts.itim(color: Colors.white)),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    // Implement cancel order functionality
                                  },
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                  ),
                                  child: Text('Cancel',
                                      style: GoogleFonts.itim(color: Colors.red)),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
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
              _buildNavItem(Icons.home, '●', 0),
              _buildNavItem(Icons.dehaze, '', 1),
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
          case 1:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ListOrdersPage()));
            break;
          case 2:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MenusenderPage()));
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
