import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:delivery_app/models/order.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:image_picker/image_picker.dart';

class CheckoutPage extends StatefulWidget {
  final List<Order> cartOrders;

  const CheckoutPage({super.key, required this.cartOrders});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  File? _image;
  final TextEditingController _imageController = TextEditingController();
  bool _isUsingDefaultLocation = false;

  // Default location if recipient location is null
  static const Map<String, double> defaultLocation = {
    "latitude": 16.2466283,
    "longitude": 103.252185,
  };

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageController.text = pickedFile.path.split('/').last;
      });
    }
  }

  Future<void> deleteOldOrders() async {
    final ordersToDelete = widget.cartOrders
        .where((order) => order.items.any((item) => item.orders == 0))
        .toList();

    for (var order in ordersToDelete) {
      final String deleteOrder =
          'https://back-deliverys.onrender.com/api/orders/del/${order.id}';

      try {
        final response = await http.delete(Uri.parse(deleteOrder));

        if (response.statusCode == 200) {
          log('Order ${order.id} deleted successfully');
        } else {
          log('Failed to delete order ${order.id}: ${response.body}');
        }
      } catch (e) {
        log('Error deleting order ${order.id}: $e');
      }
    }
  }

  void _showLocationWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ไม่พบข้อมูลตำแหน่งผู้รับ กำลังใช้ตำแหน่งเริ่มต้น',
          style: GoogleFonts.itim(),
        ),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'เข้าใจแล้ว',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> createOrder(BuildContext context) async {
    final String baseUrl = 'https://back-deliverys.onrender.com/api/orders/';
    List<Map<String, dynamic>> items = [];
    double totalAmount = 0;
    Map<String, dynamic> recipientData = {};
    Map<String, double> recipientLocation = {};
    Map<String, double> pickupLocation = {
      "latitude": 16.2466083,
      "longitude": 103.252,
    };

    // ดึงข้อมูลจาก order แรกที่มี
    if (widget.cartOrders.isNotEmpty) {
      var firstOrder = widget.cartOrders.first;
      var recipient = firstOrder.recipient;

      // ตั้งค่าข้อมูลผู้รับและตำแหน่ง - ใช้ null safety
      if (recipient.location != null) {
        recipientLocation = {
          "latitude": recipient.location!.latitude,
          "longitude": recipient.location!.longitude,
        };
        _isUsingDefaultLocation = false;
      } else {
        // ใช้ตำแหน่งเริ่มต้นถ้าไม่มีข้อมูลตำแหน่ง
        recipientLocation = defaultLocation;
        _isUsingDefaultLocation = true;
        log('Warning: Using default location as recipient location is null');
        _showLocationWarning();
      }

      recipientData = {
        "name": recipient.name,
        "address": recipient.address,
        "phone": recipient.phone,
        "location": recipientLocation
      };

      // รวบรวมรายการสินค้าและคำนวณราคารวม
      for (var order in widget.cartOrders) {
        for (var item in order.items) {
          if (item.orders == 0) {
            items.add({
              'orders': "3",
              'name': item.name,
              'quantity': item.quantity,
              'price': item.price,
            });
            double itemTotalPrice = (item.price * item.quantity).toDouble();
            totalAmount += itemTotalPrice;
          }
        }
      }
    }

    final orderData = {
      'sender': "6717acc4bccc05d91fafb7bd",
      'recipient': recipientData,
      'items': items,
      'totalAmount': totalAmount,
      'pickupLocation': pickupLocation,
      'deliveryLocation': recipientLocation
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(orderData),
      );

      if (response.statusCode == 201) {
        log('Order created successfully');
        await deleteOldOrders();

        if (context.mounted) {
          Navigator.pop(context);
        }
      } else {
        log('Failed to create order: ${response.body}');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('ไม่สามารถสร้างรายการได้', style: GoogleFonts.itim()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      log('Error creating order: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการสร้างรายการ',
                style: GoogleFonts.itim()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = 0;

    final filteredOrders = widget.cartOrders
        .where((order) => order.items.any((item) => item.orders == 0))
        .toList();

    for (var order in filteredOrders) {
      for (var item in order.items) {
        if (item.orders == 0) {
          double itemTotalPrice = (item.price * item.quantity).toDouble();
          totalAmount += itemTotalPrice;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout', style: GoogleFonts.itim()),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          if (_isUsingDefaultLocation)
            Container(
              color: Colors.orange.shade100,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'กำลังใช้ตำแหน่งเริ่มต้นเนื่องจากไม่พบข้อมูลตำแหน่งผู้รับ',
                      style: GoogleFonts.itim(color: Colors.orange[900]),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return Column(
                          children: order.items
                              .where((item) => item.orders == 0)
                              .map((item) {
                            return ListTile(
                              title: Text(item.name, style: GoogleFonts.itim()),
                              subtitle: Text(
                                  '\$${item.price.toStringAsFixed(2)} x ${item.quantity}',
                                  style: GoogleFonts.itim()),
                              trailing: Text(
                                  '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                  style: GoogleFonts.itim()),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  Text(
                    'ราคารวม: \$${totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.itim(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      createOrder(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: Text('สร้างรายการ',
                        style: GoogleFonts.itim(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }
}
