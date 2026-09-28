class Product {
  final int id;
  final String name;
  final double price;
  final String category;
  final String icon;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.icon,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      category: map['category'] as String,
      icon: (map['icon'] as String?) ?? '☕',
    );
  }
}
