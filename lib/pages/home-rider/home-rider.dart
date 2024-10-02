import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:delivery_app/pages/list-on-profile-users/edit_profile.dart';
import 'package:delivery_app/pages/home-rider/Delivery_Details_Page.dart';
import 'package:delivery_app/pages/login.dart';

class HomeRiderPage extends StatefulWidget {
  const HomeRiderPage({Key? key}) : super(key: key);

  @override
  _HomeRiderPageState createState() => _HomeRiderPageState();
}

class _HomeRiderPageState extends State<HomeRiderPage> {
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
      final response = await http.get(
          Uri.parse('http://192.168.0.254:8081/api/orders/rider/available'));
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
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
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
                                          DeliveryDetailsPage(order: order),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: const Text('รับงาน'),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
              _buildNavItem(Icons.person, 0),
              _buildNavItem(Icons.home, 1),
              _buildNavItem(Icons.exit_to_app, 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _handleNavigation(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: _selectedIndex == index
                ? Colors.white
                : Colors.white.withOpacity(0.5),
          ),
          _selectedIndex == index
              ? Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        // Navigate to RiderProfileScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditProfile()),
        );
        break;
      case 1:
        // Do nothing since it's already on HomeRiderPage
        break;
      case 2:
        // Navigate to LoginScreen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
        break;
    }
  }
}
