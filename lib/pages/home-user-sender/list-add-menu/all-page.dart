import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:delivery_app/pages/home-user-sender/home-sender.dart';
import 'package:delivery_app/pages/home-user-sender/list-add-menu/Lunch.dart';
import 'package:delivery_app/pages/home-user-sender/profile-sender.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:delivery_app/config/config.dart';
import 'package:image_picker/image_picker.dart';

class allpage extends StatefulWidget {
  const allpage({super.key});

  @override
  State<allpage> createState() => _allpageState();
}

class _allpageState extends State<allpage> {
  int _selectedIndex = 1;
  List<dynamic> orders = [];
  bool isLoading = false;
  List<File> selectedImages = [];

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
      // Decode the response and filter for orders with items.orders == 3
      List<dynamic> allOrders = json.decode(response.body);
      orders = allOrders.where((order) => order['items'][0]['orders'] == 3).toList();
      log("$orders");
      setState(() {
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


  // Helper method to get order status text and color
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

  Future<void> handleImageUpload(String orderId) async {
    final picker = ImagePicker();
    try {
      final pickedFiles = await picker.pickMultiImage();
      
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        setState(() {
          isLoading = true;
        });

        List<File> images = pickedFiles.map((xFile) => File(xFile.path)).toList();
        
        // Create multipart request
        var uri = Uri.parse('https://back-deliverys.onrender.com/api/orders/$orderId/images');
        var request = http.MultipartRequest('POST', uri);
        
        // Add all images to the request
        for (var image in images) {
          var stream = http.ByteStream(image.openRead());
          var length = await image.length();
          
          var multipartFile = http.MultipartFile(
            'images',
            stream,
            length,
            filename: image.path.split('/').last,
          );
          
          request.files.add(multipartFile);
        }

        // Send request
        var response = await request.send();
        
        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('อัปโหลดรูปภาพสำเร็จ'),
              backgroundColor: Colors.green,
            ),
          );
          fetchAvailableOrders(); // Refresh the orders list
        } else {
          throw Exception('Upload failed');
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
                                    order['recipient']['name'],
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
                                      IconButton(
                                        icon: const Icon(Icons.photo_camera),
                                        onPressed: () => handleImageUpload(order['_id']),
                                      ),
                                      ElevatedButton(
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
              _buildNavItem(Icons.dehaze, '●', 1),
              const SizedBox(width: 60),
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
              MaterialPageRoute(builder: (context) => const SendProfileScreen()),
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
      child: const SizedBox(
        width: 65,
        height: 65,
        child: Icon(Icons.add, size: 35, color: Colors.white),
      ),
    );
  }
}