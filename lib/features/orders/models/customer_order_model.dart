class CustomerOrderModel {
  final int id;
  final int customerId;
  final int productId;
  final int sellerId;
  final int quantity;

  final double totalPrice;

  final String status;
  final String productName;
  final String governorate;
  final String phone;
  final String address;
  final String createdAt;

  final String shippingImage;
  final String shippingPeriod;
  final bool hasRating;

  final Map<String, dynamic> rawData;

  const CustomerOrderModel({
    required this.id,
    required this.customerId,
    required this.productId,
    required this.sellerId,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.productName,
    required this.governorate,
    required this.phone,
    required this.address,
    required this.createdAt,
    required this.shippingImage,
    required this.shippingPeriod,
    required this.hasRating,
    required this.rawData,
  });

  bool get isPending => status.toLowerCase() == 'pending';

  bool get isCompleted => status.toLowerCase() == 'complete';

  bool get hasShippingImage => shippingImage.trim().isNotEmpty;

  bool get hasShippingPeriod => shippingPeriod.trim().isNotEmpty;

  bool get hasCompleteShippingData => hasShippingImage && hasShippingPeriod;

  bool get isWaitingForSeller => isPending && !hasCompleteShippingData;

  bool get isInDelivery => isPending && hasCompleteShippingData;

  bool get canConfirmDelivery => isInDelivery;

  bool get canRateSeller => isCompleted && !hasRating;

  factory CustomerOrderModel.fromJson(Map<String, dynamic> json) {
    final product = _asMap(json['product']);
    final shipping = _asMap(json['shipping']);

    return CustomerOrderModel(
      id: _toInt(json['id']),
      customerId: _toInt(json['customer_id']),
      productId: _toInt(json['product_id'] ?? product['id']),
      sellerId: _toInt(json['seller_id'] ?? product['seller_id']),
      quantity: _toInt(json['quantity']),
      totalPrice: _toDouble(json['total_price'] ?? json['price']),
      status: _firstText([json['status']], fallback: 'pending'),
      productName: _firstText([
        product['title'],
        product['name'],
        product['product_name'],
        json['product_name'],
      ], fallback: 'منتج غير معروف'),
      governorate: _firstText([
        shipping['governorate'],
        shipping['city'],
        product['governorate'],
        json['governorate'],
      ]),
      phone: _firstText([shipping['phone'], json['phone']]),
      address: _firstText([shipping['address'], json['address']]),
      createdAt: _firstText([json['created_at']]),
      shippingImage: _firstText([shipping['image']]),
      shippingPeriod: _firstText([shipping['period']]),
      hasRating: _toBool(json['has_rating']),
      rawData: Map<String, dynamic>.from(json),
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  static String _firstText(List<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';

      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }

    return fallback;
  }

  static int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalized = value?.toString().trim().toLowerCase();

    return normalized == 'true' || normalized == '1';
  }
}
