import 'package:shamstore/core/constants/api_constants.dart';

class ProductModel {
  final int id;
  final int sellerId;
  final int categoryId;
  final String title;
  final String description;
  final double price;
  final int quantity;
  final String governorate;
  final String productImageUrl;
  final String productUrl;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  const ProductModel({
    required this.id,
    required this.sellerId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.price,
    required this.quantity,
    required this.governorate,
    required this.productImageUrl,
    required this.productUrl,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: _toInt(json['id']),
      sellerId: _toInt(json['seller_id']),
      categoryId: _toInt(json['category_id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: _toDouble(json['price']),
      quantity: _toInt(json['quantity']),
      governorate: json['governorate']?.toString() ?? '',
      productImageUrl: json['product_image_url']?.toString() ?? '',
      productUrl: json['product_url']?.toString() ?? '',
      isActive: _toBool(json['is_active']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'price': price,
      'quantity': quantity,
      'governorate': governorate,
      'product_image_url': productImageUrl,
      'product_url': productUrl,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String get fullImageUrl {
    final image = productImageUrl.trim();

    if (image.isEmpty) return '';

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }

    final serverBaseUrl = ApiConstants.baseUrl.replaceFirst('/api', '');

    if (image.startsWith('/storage/')) {
      return '$serverBaseUrl$image';
    }

    if (image.startsWith('storage/')) {
      return '$serverBaseUrl/$image';
    }

    return '$serverBaseUrl/storage/$image';
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return false;
  }
}
