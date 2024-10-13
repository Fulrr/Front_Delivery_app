import 'package:delivery_app/pages/list-on-profile-users/add-card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Method',
          style: GoogleFonts.fredoka(color: Colors.black),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Credit Cards',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent, // พื้นหลังโปร่งใส
                      builder: (context) {
                        return const AddCardView(); // แสดง AddCardView
                      },
                    );
                  },
                  child: Text(
                    'Add +',
                    style: GoogleFonts.fredoka(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCreditCard(),
            const SizedBox(height: 24),
            _buildPaymentOption(
              icon: Icons.circle,
              title: 'Pay',
              subtitle: 'Pay Play',
              trailingIcon: Icons.edit,
            ),
            const Divider(),
            _buildPaymentOption(
              icon: Icons.account_balance_wallet,
              title: 'PayFree',
              subtitle: 'Pay Free',
              trailingIcon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCard() {
    return SizedBox(
      height: 180,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '9897 6565 3232 3232',
                    style:
                        GoogleFonts.fredoka(color: Colors.white, fontSize: 18),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Titanium Debit',
                        style: GoogleFonts.fredoka(color: Colors.white),
                      ),
                      Text(
                        'Exp. End 12/25',
                        style: GoogleFonts.fredoka(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Center(
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                'Kristin',
                style: GoogleFonts.fredoka(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required IconData trailingIcon,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: GoogleFonts.fredoka()),
      subtitle: Text(subtitle, style: GoogleFonts.fredoka()),
      trailing: Icon(trailingIcon, color: Colors.grey),
    );
  }
}
