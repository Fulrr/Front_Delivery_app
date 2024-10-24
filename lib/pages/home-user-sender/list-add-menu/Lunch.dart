// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:delivery_app/pages/home-rider/RealTimeMapPage.dart';
import 'package:delivery_app/pages/home-user-sender/list-add-menu/Lunch-follow.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:delivery_app/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LunchPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const LunchPage({super.key, required this.order});

  @override
  _LunchPageState createState() => _LunchPageState();
}

class _LunchPageState extends State<LunchPage> {
  String? Id; // สร้างตัวแปรเพื่อเก็บ riderId
  File? _image;
  final TextEditingController _imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getRiderId(); // เรียกใช้เมื่อสร้าง LunchPage
  }

  void _getRiderId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      Id = prefs.getString('userId'); // ดึง riderId (userId ที่เก็บไว้)
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageController.text =
            pickedFile.path.split('/').last; // แสดงชื่อไฟล์ในช่อง TextField
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    // ตรวจสอบว่า order ไม่เป็น null
    if (order.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('รายละเอียดคำสั่งส่ง'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: const Text('ไม่พบข้อมูลคำสั่งส่ง'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดคำสั่งส่ง'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderInfo(order),
              const SizedBox(height: 20),
              _buildRecipientInfo(order),
              const SizedBox(height: 20),
              _buildItemsList(order),
              const SizedBox(height: 20),
              _buildTotalAmount(order),
              const SizedBox(height: 30),
              _buildBottomButtons(),
              const SizedBox(height: 30),
              _buildAcceptButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfo(Map<String, dynamic> order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'คำสั่งที่ ${order['_id']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'สถานะ: ${_getStatusInThai(order['status'])}',
              style: TextStyle(
                color: _getStatusColor(order['status']),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'วันที่สั่ง: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(order['createdAt']))}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientInfo(Map<String, dynamic> order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ข้อมูลผู้รับ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('ชื่อ: ${order['recipient']['name']}'),
            const SizedBox(height: 4),
            Text('ที่อยู่: ${order['recipient']['address']}'),
            const SizedBox(height: 4),
            Text('เบอร์โทร: ${order['recipient']['phone']}'),
          ],
        ),
      ),
    );
  }

  // Widget _buildRaider(Map<String, dynamic> order) {
  //   return Card(
  //     elevation: 2,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Text(
  //             'ข้อมูลผู้รับ',
  //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //           ),
  //           const SizedBox(height: 8),
  //           Text('ชื่อ: ${order['recipient']['name']}'),
  //           const SizedBox(height: 4),
  //           Text('ที่อยู่: ${order['recipient']['address']}'),
  //           const SizedBox(height: 4),
  //           Text('เบอร์โทร: ${order['recipient']['phone']}'),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildItemsList(Map<String, dynamic> order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'รายการสินค้า',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...order['items'].map<Widget>((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['name'] ?? 'ไม่ระบุชื่อสินค้า'), // จัดการค่าที่เป็น null
                    Text(
                        '${item['quantity'] ?? 0} x ฿${(item['price'] ?? 0).toStringAsFixed(2)}'), // ป้องกันการเรียกใช้ toStringAsFixed บน null
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmount(Map<String, dynamic> order) {
    return Card(
      elevation: 2,
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ยอดรวมทั้งสิ้น',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '฿${(order['totalAmount'] ?? 0).toStringAsFixed(2)}', // ป้องกันการเรียกใช้ toStringAsFixed บน null
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => LunchFollowPage(order: widget.order))
  );
},

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'รายละเอียด',
          style: TextStyle(fontSize: 18),
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
            controller: _imageController,
            decoration: InputDecoration(
              hintText: 'อัพโหลดรูปภาพ',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: () => _pickImage(ImageSource.gallery),
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
      ],
    );
  }

  String _getStatusInThai(String status) {
    switch (status) {
      case 'pending':
        return 'รอดำเนินการ';
      case 'processing':
        return 'กำลังดำเนินการ';
      case 'shipped':
        return 'จัดส่งแล้ว';
      case 'delivered':
        return 'ส่งถึงผู้รับแล้ว';
      case 'cancelled':
        return 'ยกเลิกแล้ว';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.green;
      case 'delivered':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
