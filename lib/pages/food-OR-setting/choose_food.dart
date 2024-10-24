import 'dart:convert';
import 'package:delivery_app/models/food_model.dart';
import 'package:delivery_app/pages/food-OR-setting/pay-food.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:delivery_app/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodOrderComponent extends StatefulWidget {
  final Food selectedFood;

  const FoodOrderComponent({super.key, required this.selectedFood});

  @override
  _FoodOrderComponentState createState() => _FoodOrderComponentState();
}

class _FoodOrderComponentState extends State<FoodOrderComponent> {
  int quantity = 1;
  bool isLoading = false;
  String? message;
  String? userId;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // ฟังก์ชันดึง userId และข้อมูลผู้ใช้
  Future<void> _getUserData() async {
    try {
      // ดึง userId จาก SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedUserId = prefs.getString('userId');

      if (storedUserId != null) {
        // เรียก API เพื่อดึงข้อมูลผู้ใช้
        final response = await http.get(
          Uri.parse('${getUserById}/$storedUserId'),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == true) {
            setState(() {
              userId = storedUserId;
              userData = responseData['data'];
            });
          } else {
            setState(() {
              message = 'ไม่สามารถดึงข้อมูลผู้ใช้ได้';
            });
          }
        } else {
          setState(() {
            message = 'เกิดข้อผิดพลาดในการดึงข้อมูลผู้ใช้';
          });
        }
      } else {
        setState(() {
          message = 'ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่';
        });
      }
    } catch (e) {
      setState(() {
        message = 'เกิดข้อผิดพลาด: $e';
      });
    }
  }

  // ฟังก์ชันสร้างคำสั่งซื้อ
  Future<void> createOrder() async {
    if (userId == null || userData == null) {
      setState(() {
        message = 'กรุณาเข้าสู่ระบบก่อนสั่งอาหาร';
      });
      return;
    }

    // ตรวจสอบข้อมูล GPS
    final userGpsLocation = userData!['gpsLocation'];
    if (userGpsLocation == null ||
        userGpsLocation['latitude'] == null ||
        userGpsLocation['longitude'] == null) {
      setState(() {
        message =
            'ไม่พบข้อมูลตำแหน่ง GPS กรุณาอัปเดตตำแหน่งของคุณก่อนสั่งอาหาร';
      });
      return;
    }

    setState(() {
      isLoading = true;
      message = null;
    });

    final orderData = {
      "sender": userId,
      "recipient": {
        "name": userData!['name'] ?? '',
        "address": userData!['address'] ?? '',
        "phone": userData!['phone'] ?? '',
      },
      "items": [
        {
          "name": widget.selectedFood.name,
          "quantity": quantity,
          "price": widget.selectedFood.price,
        }
      ],
      "totalAmount": widget.selectedFood.price * quantity,
      "pickupLocation": {"latitude": 15.9717, "longitude": 102.6217},
      "deliveryLocation": {
        "latitude": userGpsLocation['latitude'],
        "longitude": userGpsLocation['longitude']
      }
    };

    try {
      final response = await http.post(
        Uri.parse(cre_Order),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201) {
        setState(() {
          message = 'คำสั่งซื้อสร้างสำเร็จ!';
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              food: widget.selectedFood,
              quantity: quantity,
              recipientPhone: userData!['phone'] ?? '', // ส่งเบอร์โทรไป
              recipientAddress: userData!['address'] ?? '', // ส่งที่อยู่ไป
            ),
          ),
        );
      } else {
        setState(() {
          message = 'ไม่สามารถสร้างคำสั่งซื้อได้: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        message = 'เกิดข้อผิดพลาด: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.selectedFood;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.grey),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(food.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: GoogleFonts.lato(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow),
                        SizedBox(width: 4),
                        Text("4.9"),
                        SizedBox(width: 16),
                        Text("• 26 mins", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      food.description,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Portion",
                            style:
                                GoogleFonts.lato(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  quantity = quantity > 1 ? quantity - 1 : 1;
                                });
                              },
                            ),
                            Text("$quantity", style: GoogleFonts.lato()),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (message != null) // แสดงข้อความถ้ามี
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          message!,
                          style: TextStyle(
                            color: message!.contains('สำเร็จ')
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${food.price.toStringAsFixed(2)}',
                          style: GoogleFonts.lato(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                        isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed:
                                    createOrder, // เรียกฟังก์ชันสร้างคำสั่งซื้อ
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                                child: const Text("ORDER NOW",
                                    style: TextStyle(color: Colors.white)),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
