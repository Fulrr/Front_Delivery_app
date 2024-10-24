import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:delivery_app/pages/home-user-sender/home-sender.dart';
import 'package:delivery_app/pages/home-user-sender/list-add-menu/Lunch.dart';
import 'package:delivery_app/pages/home-user-sender/profile-sender.dart';
import 'package:delivery_app/pages/home_user/home-re.dart';
import 'package:delivery_app/pages/home_user/map_order.dart';
import 'package:delivery_app/pages/home_user/profile.dart';
import 'package:delivery_app/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:delivery_app/config/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class cartUser extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userImage;
  final String userAddress;

  const cartUser({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.userImage,
    required this.userAddress,
  }) : super(key: key);

  @override
  _cartUserState createState() => _cartUserState();
}

class _cartUserState extends State<cartUser> {
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
      final response = await http.get(Uri.parse('https://back-deliverys.onrender.com/api/orders/')); // ใส่ URL ของ API ที่ใช้ในการดึงคำสั่งซื้อ
      if (response.statusCode == 200) {
        List<dynamic> allOrders = json.decode(response.body);
        orders = allOrders.where((order) => order['recipient']['phone'] == widget.userPhone).toList();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Map<String, dynamic> getOrderStatusInfo(int status) {
    switch (status) {
      case 1:
        return {'text': 'รอการยืนยัน', 'color': Colors.orange};
      case 2:
        return {'text': 'กำลังจัดเตรียม', 'color': Colors.blue};
      case 3:
        return {'text': 'พร้อมจัดส่ง', 'color': Colors.green};
      case 4:
        return {'text': 'กำลังจัดส่ง', 'color': Colors.purple};
      case 5:
        return {'text': 'จัดส่งสำเร็จ', 'color': Colors.teal};
      default:
        return {'text': 'ไม่ทราบสถานะ', 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการทั้งหมด'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'รายการอาหาร',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'รายการทั้งหมด: ${orders.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? const Center(child: Text('ไม่มีรายการอาหาร'))
                    : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final statusInfo = getOrderStatusInfo(order['items'][0]['orders']);

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey[200],
                                    ),
                                    child: order['imageUrls'].isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              order['imageUrls'][0],
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.image_not_supported),
                                            ),
                                          )
                                        : const Icon(Icons.image_not_supported),
                                  ),
                                  title: Text(
                                    order['items'][0]['name'],
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        '฿${order['totalAmount'].toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusInfo['color'].withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          statusInfo['text'],
                                          style: TextStyle(
                                            color: statusInfo['color'],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  mapOrder(order: order),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                        child: const Text('รายละเอียด'),
                                      ),
                                    ],
                                  ),
                                ),
                                if (order['imageUrls'].length > 1) ...[
                                  const Divider(),
                                  SizedBox(
                                    height: 80,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      itemCount: order['imageUrls'].length,
                                      itemBuilder: (context, imageIndex) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              order['imageUrls'][imageIndex],
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
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
              _buildNavItem(Icons.home, '', 0),
              _buildNavItem(Icons.person, '', 1),
              const SizedBox(width: 60),
              _buildNavItem(Icons.shopping_cart, '●', 2),
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
                    builder: (context) => const FoodHomeScreen()
                        .animate()
                        .slideX(begin: -1, end: 0, curve: Curves.ease)));
            break;
          case 1:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FoodProfileScreen()
                        .animate()
                        .slideX(begin: -1, end: 0, curve: Curves.ease)));
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