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
        totalAmount: json["totalAmount"],
        status: json["status"],
        imageUrls: List<dynamic>.from(json["imageUrls"].map((x) => x)),
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
        "rider": rider,
        "_id": id,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "__v": v,
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
        orders: json["orders"],
        name: json["name"],
        quantity: json["quantity"],
        price: json["price"],
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
