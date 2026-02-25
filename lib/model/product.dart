class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;
  final int ratingCount;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
    required this.ratingCount,
  });


  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: (json['title'] as String).trim(),
      price: (json['price'] as num).toDouble(),
      description: (json['description'] as String).trim(),
      category: (json['category'] as String).trim(),
      image: json['image'] as String,
      rating: (json['rating']['rate'] as num).toDouble(),
      ratingCount: json['rating']['count'] as int,
    );
  }


  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'price': price,
    'description': description,
    'category': category,
    'image': image,
    'rating': rating,
    'ratingCount': ratingCount,
    'cachedAt': DateTime.now().toIso8601String(),
  };

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int,
      title: map['title'] as String,
      price: (map['price'] as num).toDouble(),
      description: map['description'] as String,
      category: map['category'] as String,
      image: map['image'] as String,
      rating: (map['rating'] as num).toDouble(),
      ratingCount: map['ratingCount'] as int,
    );
  }


  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String get shopUrl {
    final query = Uri.encodeComponent(title);
    return 'https://www.google.com/search?q=$query&tbm=shop';
  }

  String get searchUrl {
    final query = Uri.encodeComponent(title);
    return 'https://www.google.com/search?q=$query';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Product && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Product(id: $id, title: $title, price: $price)';
}