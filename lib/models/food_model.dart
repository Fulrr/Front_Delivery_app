class Food {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool available;
  final DateTime createdAt;
  final DateTime updatedAt;

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.available = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['_id'] ?? '', // MongoDB's ID field
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      available: json['available'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  get rating => null;

  // สำหรับแปลงข้อมูลเป็น JSON เมื่อต้องการส่งข้อมูลไป API
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'available': available,
    };
  }
}
