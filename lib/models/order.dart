// models/order.dart
class Order {
  final String id;
  final String customerName;
  final String itemName;
  final double price;
  final String phone;
  late int orders;

  Order({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.itemName,
    required this.price,
    required this.orders,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      customerName: json['recipient']['name'],
      phone: json['recipient']['phone'],
      itemName: json['items'][0]['name'],
      price: json['totalAmount'].toDouble(),
      orders: json['items'][0]['orders'],
    );
  }
}
