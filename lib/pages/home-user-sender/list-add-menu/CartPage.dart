// ignore_for_file: file_names, library_private_types_in_public_api

import 'dart:convert';
import 'dart:developer';
import 'package:delivery_app/pages/home-user-sender/list-add-menu/all-page.dart';
import 'package:delivery_app/pages/home-user-sender/list-add-menu/checkout.dart';
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
      for (var item in order.items) {
        item.orders = 1; // ตั้งค่า orders ของสินค้ากลับเป็น 1
      }
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
          'items': order.items
              .map((item) => {
                    'name': item.name,
                    'orders':
                        item.orders, // อัพเดตค่า orders ของสินค้าแต่ละรายการ
                    "quantity": item.quantity, // จำนวนสินค้าจากรายการ
                    "price": item.price, // ราคาใหม่
                  })
              .toList(),
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

  // ฟังก์ชันชำระเงิน
  Future<void> checkout() async {
    setState(() {
      isLoading = true;
    });

    // ลูปผ่านสินค้าทั้งหมดในตะกร้าและทำการอัพเดต DB
    for (var order in widget.cartOrders) {
      final String updateUrl = '$baseUrl${order.id}';
      try {
        final response = await http.put(
          Uri.parse(updateUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'items': order.items
                .map((item) => {
                      'name': item.name,
                      'orders':
                          item.orders, // อัพเดตค่า orders ของสินค้าแต่ละรายการ
                      "quantity": item.quantity, // จำนวนสินค้าจากรายการ
                      "price": item.price, // ราคาใหม่
                    })
                .toList(),
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

    // ลบสินค้าเก่าหลังจากเพิ่มรายการใหม่
    widget.cartOrders.clear();

    setState(() {
      isLoading = false;
    });

    // หลังชำระเงินเสร็จ จะนำผู้ใช้ไปยังหน้า allpage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const allpage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    // กรองเฉพาะรายการที่ orders == 0
    final filteredOrders = widget.cartOrders
        .where((order) => order.items.any((item) => item.orders == 0))
        .toList();

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
            child: filteredOrders.isEmpty
                ? Center(
                    child:
                        Text('ไม่มีสินค้าในตะกร้า', style: GoogleFonts.itim()),
                  )
                : ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return ListTile(
                        title: Text(order.items[0].name,
                            style: GoogleFonts.itim()),
                        subtitle: Text(
                            '\$${order.items[0].price.toStringAsFixed(2)}',
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
          // หน้า CartPage เดิม
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CheckoutPage(cartOrders: widget.cartOrders)),
              ); // ไปที่หน้า CheckoutPage
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.payment),
          ),
        ],
      ),
    );
  }
}
