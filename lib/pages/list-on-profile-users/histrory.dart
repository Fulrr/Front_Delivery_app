import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderHistoryPage extends StatelessWidget {
  OrderHistoryPage({super.key});

  final List<Order> orders = [
    Order(
      restaurantName: 'Desert show cafe',
      date: DateTime(2021, 7, 15, 11, 5),
      status: OrderStatus.delivered,
      total: 36.42,
      imageUrl: 'https://i.pinimg.com/originals/6a/5f/4d/6a5f4d604102449b2737e792fecb23d2.jpg',
      items: [
        OrderItem('Momos', 1, 12.75),
        OrderItem('Chicken', 1, 14.91),
        OrderItem('Noodles', 1, 6.34),
      ],
    ),
    Order(
      restaurantName: 'Woof Woof',
      date: DateTime(2021, 7, 15, 11, 5),
      status: OrderStatus.cancelled,
      total: 36.42,
      imageUrl: 'https://i.pinimg.com/originals/6a/5f/4d/6a5f4d604102449b2737e792fecb23d2.jpg',
    ),
    Order(
      restaurantName: 'Tommy Yummy',
      date: DateTime(2021, 7, 15, 11, 5),
      status: OrderStatus.delivered,
      total: 36.42,
      imageUrl: 'https://i.pinimg.com/originals/6a/5f/4d/6a5f4d604102449b2737e792fecb23d2.jpg',
    ),
    Order(
      restaurantName: 'Mega Rolls',
      date: DateTime(2021, 7, 15, 11, 5),
      status: OrderStatus.delivered,
      total: 36.42,
      imageUrl: 'https://i.pinimg.com/originals/6a/5f/4d/6a5f4d604102449b2737e792fecb23d2.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return OrderTile(order: orders[index]);
        },
      ),
    );
  }
}

class OrderTile extends StatelessWidget {
  final Order order;

  const OrderTile({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                order.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              order.restaurantName,
              style: GoogleFonts.lato(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              DateFormat('MMM d, yyyy - hh:mm a').format(order.date),
              style: GoogleFonts.lato(),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  order.status == OrderStatus.delivered ? 'Delivered' : 'Cancelled',
                  style: TextStyle(
                    color: order.status == OrderStatus.delivered ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (order.items != null && order.items!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: order.items!.map((item) => Text(
                  '${item.name} x ${item.quantity} - \$${item.price.toStringAsFixed(2)}',
                  style: GoogleFonts.lato(),
                )).toList(),
              ),
            ),
          if (order.status == OrderStatus.delivered)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  // Handle button press
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.blue),
                ),
                child: const Text('รายละเอียด'),
              ),
            ),
        ],
      ),
    );
  }
}

enum OrderStatus { delivered, cancelled }

class Order {
  final String restaurantName;
  final DateTime date;
  final OrderStatus status;
  final double total;
  final String imageUrl;
  final List<OrderItem>? items;

  Order({
    required this.restaurantName,
    required this.date,
    required this.status,
    required this.total,
    required this.imageUrl,
    this.items,
  });
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem(this.name, this.quantity, this.price);
}
