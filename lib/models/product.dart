import 'dart:convert';
import 'dart:typed_data';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String image; // base64 or URL
  final String description;
  Uint8List? _cachedBytes;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.image = '',
    this.description = '',
  });

  Uint8List? get imageBytes {
    if (_cachedBytes != null) return _cachedBytes;
    if (image.isNotEmpty && !image.startsWith('http')) {
      try {
        _cachedBytes = base64Decode(image);
        return _cachedBytes;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? stock,
    String? image,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      image: image ?? this.image,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'image': image,
      'description': description,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'Umum',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] ?? 0,
      image: json['image'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
