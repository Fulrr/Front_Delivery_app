// ignore_for_file: file_names, library_private_types_in_public_api

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:delivery_app/models/order.dart';

class CartPage extends StatefulWidget {
  final List<Order> cartOrders; // รายการสินค้าในตะกร้า

  const CartPage({super.key, required this.cartOrders});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isLoading = false;

  // URL สำหรับการอัพเดตคำสั่งซื้อ
  final String baseUrl = 'https://back-deliverys.onrender.com/api/orders/';

  Future<void> removeFromCart(Order order) async {
    setState(() {
      widget.cartOrders.remove(order); // ลบสินค้าออกจากตะกร้า
      order.orders = 1; // เซ็ตค่า orders เป็น 1 หลังจากลบออกจากตะกร้า
    });

    // อัพเดตคำสั่งซื้อในฐานข้อมูล
    final String updateUrl = '$baseUrl${order.id}';
    try {
      final response = await http.put(
        Uri.parse(updateUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'items': [
            {
              'name': order.itemName,
              'orders': order.orders, // ส่งค่า orders ที่เปลี่ยนแปลงไปยัง API
              "quantity": 2, // ค่า quantity ที่กำหนด
              "price": 100, // ราคาใหม่
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        log('Order updated successfully');
      } else {
        throw Exception('Failed to update order');
      }
    } catch (e) {
      log('Error updating order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16.0),
      width: media.width,
      height: media.height * 0.5, // กำหนดความสูงเป็น 50% ของหน้าจอ
      child: Column(
        children: [
          Expanded(
            child: widget.cartOrders.isEmpty
                ? Center(
                    child: Text('ไม่มีสินค้าในตะกร้า', style: GoogleFonts.itim()),
                  )
                : ListView.builder(
                    itemCount: widget.cartOrders.length,
                    itemBuilder: (context, index) {
                      final order = widget.cartOrders[index];
                      return ListTile(
                        title: Text(order.itemName, style: GoogleFonts.itim()),
                        subtitle: Text('\$${order.price.toStringAsFixed(2)}',
                            style: GoogleFonts.itim()),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            removeFromCart(order); // เรียกใช้ฟังก์ชันลบสินค้า
                          },
                        ),
                      );
                    },
                  ),
          ),
          FloatingActionButton(
            onPressed: () {
              // ฟังก์ชันการชำระเงิน
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.payment),
          ),
        ],
      ),
    );
  }
}
