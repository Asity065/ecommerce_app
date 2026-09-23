class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final double rating;
  final String imageEmoji; 
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.rating,
    required this.imageEmoji,
    required this.stock,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    double? rating,
    String? imageEmoji,
    int? stock,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      imageEmoji: imageEmoji ?? this.imageEmoji,
      stock: stock ?? this.stock,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      imageEmoji: json['imageEmoji'] as String,
      stock: json['stock'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'rating': rating,
        'imageEmoji': imageEmoji,
        'stock': stock,
      };

  @override
  bool operator ==(Object other) => other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
