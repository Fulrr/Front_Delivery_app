// import 'package:delivery_app/pages/home-rider/RealTimeMapPage.dart';
import 'package:delivery_app/pages/home-rider/RealTimeMapPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:delivery_app/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;
  String? riderId; // สร้างตัวแปรเพื่อเก็บ riderId

  DeliveryDetailsPage({Key? key, required this.order}) : super(key: key) {
    _getRiderId(); // เรียกใช้เมื่อสร้าง DeliveryDetailsPage
  }

  void _getRiderId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    riderId = prefs.getString('userId'); // ดึง riderId (userId ที่เก็บไว้)
  }

  @override
  Widget build(BuildContext context) {
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
              _buildOrderInfo(),
              const SizedBox(height: 20),
              _buildRecipientInfo(),
              const SizedBox(height: 20),
              _buildItemsList(),
              const SizedBox(height: 20),
              _buildTotalAmount(),
              const SizedBox(height: 30),
              _buildAcceptButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfo() {
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

  Widget _buildRecipientInfo() {
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

  Widget _buildItemsList() {
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
                    Text(item['name'] ??
                        'ไม่ระบุชื่อสินค้า'), // จัดการค่าที่เป็น null
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

  Widget _buildTotalAmount() {
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
          if (riderId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ไม่พบข้อมูล riderId')),
            );
            return;
          }

          try {
            final response = await http.post(
              Uri.parse('${acceptOrder}/${order['_id']}/accept'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(<String, String>{
                'riderId': riderId!,
              }),
            );

            if (response.statusCode == 200) {
              // API call successful
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('คุณได้รับงานนี้แล้ว')),
              );
              // นำทางไปยังหน้า RealTimeMapPage แทนที่จะ pop
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RealTimeMapPage(orderId: order['_id']),
                ),
              );
            } else {
              // API call failed
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('เกิดข้อผิดพลาด: ${response.statusCode}')),
              );
            }
          } catch (e) {
            // Network or other error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'รับงาน',
          style: TextStyle(fontSize: 18),
        ),
      ),
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
