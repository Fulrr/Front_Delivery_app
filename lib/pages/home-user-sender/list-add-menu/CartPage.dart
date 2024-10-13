import 'package:delivery_app/pages/home-user-sender/home-sender.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatelessWidget {
  final List<Order> cartOrders;
  final Function(Order) onRemove; // Callback สำหรับลบ

  const CartPage({super.key, required this.cartOrders, required this.onRemove});

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
      height: media.height * 0.5, // กำหนดความสูงให้เป็น 50% ของหน้าจอ
      child: Column(
        children: [
          Expanded(
            child: cartOrders.isEmpty
                ? Center(
                    child:
                        Text('ไม่มีสินค้าในตะกร้า', style: GoogleFonts.itim()))
                : ListView.builder(
                    itemCount: cartOrders.length,
                    itemBuilder: (context, index) {
                      final order = cartOrders[index];
                      return ListTile(
                        title: Text(order.itemName, style: GoogleFonts.itim()),
                        subtitle: Text('\$${order.price.toStringAsFixed(2)}',
                            style: GoogleFonts.itim()),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            onRemove(order); // เรียกใช้ callback เพื่อลบสินค้า
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
