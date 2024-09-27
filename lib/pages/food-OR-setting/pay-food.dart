import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart'; // ใช้สำหรับไอคอน CreditCard ถ้าต้องการ

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool saveCard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text('Payment Page'),
          // backgroundColor: Colors.black,
          ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order summary',
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Order', '\$16.48'),
            _buildSummaryRow('Taxes', '\$0.30'),
            _buildSummaryRow('Delivery fees', '\$1.50'),
            const Divider(),
            _buildSummaryRow(
              'Total:',
              '\$18.19',
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
            Text(
              'Payment methods',
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethod('Credit card', '5105 •••• •••• 0505', true),
            _buildPaymentMethod('Debit card', '3566 •••• •••• 0505', false),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: saveCard,
                  onChanged: (bool? value) {
                    setState(() {
                      saveCard = value!;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'Save card details for future payments',
                    style: GoogleFonts.lato(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$18.19',
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
                  child: const Text('Pay Now',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: GoogleFonts.lato(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(
          value,
          style: GoogleFonts.lato(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildPaymentMethod(String title, String cardNumber, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey[400] : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/credit-card.svg', // เปลี่ยนเป็นที่อยู่ไฟล์ไอคอนของคุณ
                height: 24,
                width: 24,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                  Text(cardNumber, style: GoogleFonts.lato(color: Colors.grey[600])),
                ],
              ),
            ],
          ),
          if (isSelected)
            const Icon(Icons.radio_button_checked, color: Colors.white)
          else
            const Icon(Icons.radio_button_unchecked, color: Colors.grey),
        ],
      ),
    );
  }
}
