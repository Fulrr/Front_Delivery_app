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

  Future<void> deleteOldOrders() async {
    final ordersToDelete = widget.cartOrders
        .where((order) => order.items.any((item) => item.orders == 0))
        .toList();

    for (var order in ordersToDelete) {
      final String deleteUrl =
          'https://back-deliverys.onrender.com/api/orders/${order.id}';
      final String deleteOrder =
          'http://back-deliverys.onrender.com/api/orders/del/${order.id}';

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

  Future<void> createOrder(BuildContext context) async {
    final String baseUrl = 'https://back-deliverys.onrender.com/api/orders/';
    List<Map<String, dynamic>> items = [];
    double totalAmount = 0;
    Map<String, dynamic> recipientData = {};
    Map<String, dynamic> LocationData = {};
    Map<String, dynamic> LocationData1 = {};

    for (var order in widget.cartOrders) {
      var recipient = order.recipient;
      // var Location = order.Location;

      if (recipientData.isEmpty) {
        recipientData = {
          "name": recipient.name,
          "address": recipient.address,
          "phone": recipient.phone
        };
      }

      if (LocationData.isEmpty) {
        LocationData = {
          "latitude": 16.2466083, 
          "longitude": 103.252,
        };
      }

      if (LocationData1.isEmpty) {
        LocationData1 = {
          "latitude": 16.2466283, 
          "longitude": 103.252185,
        };
      }

      for (var item in order.items) {
        if (item.orders == 0) {
          items.add({
            'orders': "3",
            'name': item.name,
            'quantity': item.quantity,
            'price': item.price,
          });
          totalAmount += item.price * item.quantity;
        }
      }
    }

    final orderData = {
      'recipient': recipientData,
      'items': items,
      'totalAmount': totalAmount,
      "sender": "6717acc4bccc05d91fafb7bd",
      "pickupLocation" : LocationData,
      "deliveryLocation" : LocationData1
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
            const SnackBar(content: Text('Failed to create order')),
          );
        }
      }
    } catch (e) {
      log('Error creating order: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error creating order')),
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
          totalAmount += item.price * item.quantity;
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
