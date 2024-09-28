import 'package:flutter/material.dart';

class DeliveryDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dalivery'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.asset(
              'assets/map_placeholder.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  title: Text('Chicken Bhuna → Hollie jollile'),
                  subtitle: Text('\$30'),
                  trailing: Icon(Icons.arrow_forward),
                ),
                Divider(),
                _buildStep('ลูกค้าคิดเงิน', Icons.attach_money),
                _buildStep('ดำเนินการ', Icons.delivery_dining),
                _buildStep('ถ่ายรูปใบเสร็จ/สินค้าก่อนส่ง', Icons.camera_alt),
                _buildStep('ส่งมอบ', Icons.check_circle),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    child: Text('ยืนยัน'),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
