import 'dart:convert';

class Order {
  final String sender;
  final Recipient recipient;
  final List<Item> items;
  final double totalAmount;
  final String status;
  final List<dynamic> imageUrls;
  final Location pickupLocation;
  final Location deliveryLocation;
  final dynamic rider;
  final String id;
  final String createdAt;
  final String updatedAt;
  final int v;

  Order({
    required this.sender,
    required this.recipient,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.imageUrls,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.rider,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        sender: json["sender"],
        recipient: Recipient.fromJson(json["recipient"]),
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
        totalAmount: (json["totalAmount"] as num).toDouble(),
        status: json["status"],
        imageUrls: List<dynamic>.from(json["imageUrls"].map((x) => x)),
        pickupLocation: Location.fromJson(json["pickupLocation"]),
        deliveryLocation: Location.fromJson(json["deliveryLocation"]),
        rider: json["rider"],
        id: json["_id"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "sender": sender,
        "recipient": recipient.toJson(),
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "totalAmount": totalAmount,
        "status": status,
        "imageUrls": List<dynamic>.from(imageUrls.map((x) => x)),
        "pickupLocation": pickupLocation.toJson(),
        "deliveryLocation": deliveryLocation.toJson(),
        "rider": rider,
        "_id": id,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "__v": v,
      };

  static Order fromJsonString(String str) => Order.fromJson(json.decode(str));
  String toJsonString() => json.encode(toJson());
}

class Location {
  final double latitude;
  final double longitude;

  const Location({
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        latitude: (json["latitude"] as num).toDouble(),
        longitude: (json["longitude"] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}

class Item {
  // Changed from final to allow modification
  int _orders;
  final String name;
  final int quantity;
  final double price;
  final String id;

  // Getter for orders
  int get orders => _orders;

  // Setter for orders
  set orders(int value) {
    _orders = value;
  }

  Item({
    required int orders,
    required this.name,
    required this.quantity,
    required this.price,
    required this.id,
  }) : _orders = orders;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        orders: (json["orders"] as num).toInt(),
        name: json["name"],
        quantity: (json["quantity"] as num).toInt(),
        price: (json["price"] as num).toDouble(),
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "orders": _orders,
        "name": name,
        "quantity": quantity,
        "price": price,
        "_id": id,
      };

  // Copy with method for creating a new instance with updated values
  Item copyWith({
    int? orders,
    String? name,
    int? quantity,
    double? price,
    String? id,
  }) {
    return Item(
      orders: orders ?? this._orders,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      id: id ?? this.id,
    );
  }
}

class Recipient {
  final String name;
  final String address;
  final String phone;
  final Location? location;

  const Recipient({
    required this.name,
    required this.address,
    required this.phone,
    this.location,
  });

  factory Recipient.fromJson(Map<String, dynamic> json) => Recipient(
        name: json["name"],
        address: json["address"],
        phone: json["phone"],
        location: json["location"] != null
            ? Location.fromJson(json["location"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "address": address,
        "phone": phone,
        if (location != null) "location": location!.toJson(),
      };
}
