// To parse this JSON data, do
//
//     final order = orderFromJson(jsonString);

import 'dart:convert';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
    String sender;
    Recipient recipient;
    List<Item> items;
    int totalAmount;
    String status;
    List<dynamic> imageUrls;
    Location pickupLocation;
    Location deliveryLocation;
    dynamic rider;
    String id;
    String createdAt;
    String updatedAt;
    int v;

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
        totalAmount: (json["totalAmount"] as num).toInt(), // To handle both int and double
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
}

class Location {
    double latitude;
    double longitude;

    Location({
        required this.latitude,
        required this.longitude,
    });

    factory Location.fromJson(Map<String, dynamic> json) => Location(
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
    };
}

class Item {
    int orders;
    String name;
    int quantity;
    int price;
    String id;

    Item({
        required this.orders,
        required this.name,
        required this.quantity,
        required this.price,
        required this.id,
    });

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        //orders: json["orders"],
        name: json["name"],
        orders: (json["orders"] as num).toInt(), // To handle both int and double
        quantity: (json["quantity"] as num).toInt(),
        price: (json["price"] as num).toInt(),
        id: json["_id"],
    );

    Map<String, dynamic> toJson() => {
        "orders": orders,
        "name": name,
        "quantity": quantity,
        "price": price,
        "_id": id,
    };
}

class Recipient {
    String name;
    String address;
    String phone;

    Recipient({
        required this.name,
        required this.address,
        required this.phone,
    });

    factory Recipient.fromJson(Map<String, dynamic> json) => Recipient(
        name: json["name"],
        address: json["address"],
        phone: json["phone"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "address": address,
        "phone": phone,
    };
}
