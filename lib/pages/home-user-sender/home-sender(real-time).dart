import 'dart:convert';
import 'package:delivery_app/pages/home-user-sender/add-menu.dart';
import 'package:delivery_app/pages/home-user-sender/list-menu.dart';
import 'package:delivery_app/pages/home-user-sender/profile-sender.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Order {
  final String id;
  final String customerName;
  final String itemName;
  final double price;
  final String phone;

  Order({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.itemName,
    required this.price,
  });

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

class HomesenderPage1 extends StatefulWidget {
  const HomesenderPage1({super.key});

  @override
  State<HomesenderPage1> createState() => _HomesenderPage1State();
}

class _HomesenderPage1State extends State<HomesenderPage1> {
  List<Order> orders = [];
  List<Order> filteredOrders = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  late IO.Socket socket;
  int _selectedIndex = 0; // ตัวแปรสำหรับ Bottom Navigation

  @override
  void initState() {
    super.initState();
    connectToServer();
  }

  void connectToServer() {
    socket = IO.io('http://10.210.60.215:8081', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.on('connect', (_) {
      print('Connected to server');
      socket.emit('requestInitialData'); // ส่งคำขอข้อมูลเริ่มต้น
    });

    socket.on('initialData', (data) {
      setState(() {
        orders = (data as List).map((item) => Order.fromJson(item)).toList();
        filteredOrders = List.from(orders);
        isLoading = false;
      });
    });

    socket.on('dataChange', (change) {
      handleDataChange(change);
    });

    socket.on('disconnect', (_) => print('Disconnected from server'));
  }

  void handleDataChange(dynamic change) {
    if (change['operationType'] == 'insert') {
      setState(() {
        Order newOrder = Order.fromJson(change['fullDocument']);
        orders.add(newOrder);
        filteredOrders = List.from(orders);
      });
    } else if (change['operationType'] == 'update') {
      setState(() {
        int index = orders.indexWhere((order) => order.id == change['documentKey']['_id']);
        if (index != -1) {
          orders[index] = Order.fromJson(change['fullDocument']);
        }
        filteredOrders = List.from(orders);
      });
    } else if (change['operationType'] == 'delete') {
      setState(() {
        orders.removeWhere((order) => order.id == change['documentKey']['_id']);
        filteredOrders = List.from(orders);
      });
    }
  }

  void searchOrders(String query) {
    setState(() {
      filteredOrders = orders.where((order) =>
        order.customerName.toLowerCase().contains(query.toLowerCase()) ||
        order.phone.contains(query)
      ).toList();
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
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
            Text('LOCATION', style: TextStyle(color: Colors.orange, fontSize: 14)),
            SizedBox(width: 8),
            Text('Halal Lab office', style: TextStyle(color: Colors.black, fontSize: 16)),
            Icon(Icons.arrow_drop_down, color: Colors.black),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(backgroundColor: Colors.grey[300], radius: 15),
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
                hintText: 'Search by name or phone',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: searchOrders,
              style: GoogleFonts.itim(),
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
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(width: 60, height: 60, color: Colors.grey[300]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(order.customerName, style: GoogleFonts.itim(color: Colors.orange, fontWeight: FontWeight.bold)),
                                    Text(order.itemName, style: GoogleFonts.itim(fontWeight: FontWeight.bold)),
                                    Text('ID: ${order.phone}', style: GoogleFonts.itim()),
                                    Text('\$${order.price.toStringAsFixed(2)}', style: GoogleFonts.itim(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
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
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.dehaze, 'Orders', 1),
              const SizedBox(width: 60), // Space for FAB
              _buildNavItem(Icons.apps, 'Menu', 2),
              _buildNavItem(Icons.person, 'Profile', 3),
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
        // Implement navigation based on the selected index
        switch (_selectedIndex) {
          case 1:
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ListOrdersPage()));
            break;
          case 2:
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MenusenderPage()));
            break;
          case 3:
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SendProfileScreen()));
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _selectedIndex == index ? Colors.white : Colors.white),
          Text(label, style: TextStyle(color: _selectedIndex == index ? Colors.white : Colors.white, fontSize: 10)),
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddOrderPage()));
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

// หน้าจอสำหรับเพิ่มคำสั่งซื้อ
class AddOrderPage extends StatelessWidget {
  const AddOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Order')),
      body: Center(
        child: Text('Form to add order goes here'), // เพิ่มฟอร์มที่นี่
      ),
    );
  }
}
