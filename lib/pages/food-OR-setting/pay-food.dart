import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:delivery_app/models/food_model.dart'; // นำเข้าโมเดล Food

class PaymentPage extends StatefulWidget {
  final Food food;
  final int quantity;
  final String recipientPhone;
  final String recipientAddress;

  const PaymentPage({
    super.key,
    required this.food,
    required this.quantity,
    required this.recipientPhone,
    required this.recipientAddress,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    // คำนวณราคาทั้งหมด
    double totalPrice = widget.food.price * widget.quantity;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Summary',
          style: GoogleFonts.lato(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style:
                  GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // แสดงชื่ออาหารและจำนวนที่สั่ง
            _buildSummaryRow(
              widget.food.name,
              '\$${widget.food.price.toStringAsFixed(2)} x ${widget.quantity}',
            ),
            const Divider(),
            _buildSummaryRow(
              'Total:',
              '\$${totalPrice.toStringAsFixed(2)}',
              isBold: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Estimated delivery time: 15 - 30 mins',
              style: GoogleFonts.lato(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildDeliveryInfo(),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle payment logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างแถวสรุปรายการอาหาร
  Widget _buildSummaryRow(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: GoogleFonts.lato(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: GoogleFonts.lato(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  // ฟังก์ชันแสดงข้อมูลการจัดส่งเพิ่มเติม
  Widget _buildDeliveryInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Information',
          style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.black),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.recipientAddress, // แสดงที่อยู่ที่รับมา
                style: GoogleFonts.lato(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.phone, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              widget.recipientPhone, // แสดงเบอร์โทรที่รับมา
              style: GoogleFonts.lato(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }
}
