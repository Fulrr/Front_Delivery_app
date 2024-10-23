import 'dart:convert'; // นำเข้า jsonEncode
import 'package:delivery_app/models/food_model.dart';
import 'package:delivery_app/pages/food-OR-setting/pay-food.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // นำเข้า HTTP package

class FoodOrderComponent extends StatefulWidget {
  final Food selectedFood; // เพิ่มการรับ selectedFood

  const FoodOrderComponent({super.key, required this.selectedFood});

  @override
  _FoodOrderComponentState createState() => _FoodOrderComponentState();
}

class _FoodOrderComponentState extends State<FoodOrderComponent> {
  int quantity = 1;
  bool isLoading = false;
  String? message; // ตัวแปรสำหรับเก็บข้อความแจ้งเตือน

  // ฟังก์ชันเรียก API สร้างคำสั่งซื้อ
  Future<void> createOrder() async {
    setState(() {
      isLoading = true;
      message = null; // ล้างข้อความก่อน
    });

    final orderData = {
      "sender": "66f3bb048dba2c35340f38e2", // กำหนด userId ของผู้ส่ง
      "recipient": {
        "name": "John Doe", // กำหนดข้อมูลผู้รับ
        "address": "123 Main St",
        "phone": "555-5555"
      },
      "items": [
        {
          "name": widget.selectedFood.name,
          "quantity": quantity,
          "price": widget.selectedFood.price,
        }
      ],
      "totalAmount": widget.selectedFood.price * quantity,
      "pickupLocation": {
        "latitude": 37.7749, // ใส่ค่าพิกัดสถานที่รับ
        "longitude": -122.4194
      },
      "deliveryLocation": {
        "latitude": 37.7849, // ใส่ค่าพิกัดสถานที่ส่ง
        "longitude": -122.4094
      }
    };

    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.0.145:8081/api/orders'), // เส้นทาง API ที่คุณต้องการเรียก
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201) {
        // สร้างคำสั่งซื้อสำเร็จ
        print('Order created successfully!');
        setState(() {
          message = 'คำสั่งซื้อสร้างสำเร็จ!';
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              food: widget.selectedFood,
              quantity: quantity,
            ),
          ),
        );
      } else {
        // หากล้มเหลว
        print('Failed to create order: ${response.body}');
        setState(() {
          message = 'ไม่สามารถสร้างคำสั่งซื้อได้: ${response.body}';
        });
      }
    } catch (e) {
      print('Error: $e');
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
