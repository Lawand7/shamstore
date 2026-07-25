class SellerOrderModel {
  const SellerOrderModel({
    required this.id,
    required this.customerId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.status,
    required this.productName,
    required this.productImageUrl,
    required this.customerName,
    required this.governorate,
    required this.address,
    required this.phone,
    required this.shippingPeriod,
    required this.shippingImageUrl,
    required this.createdAt,
    required this.rawData,
  });

  final int id;
  final int customerId;
  final int productId;
  final int quantity;

  final double unitPrice;
  final double totalPrice;

  final String status;

  final String productName;
  final String productImageUrl;

  final String customerName;

  final String governorate;
  final String address;
  final String phone;

  final String shippingPeriod;
  final String shippingImageUrl;

  final String createdAt;

  final Map<String, dynamic> rawData;

  bool get isPending {
    return status.trim().toLowerCase() == 'pending';
  }

  bool get isCompleted {
    final normalizedStatus = status.trim().toLowerCase();

    return normalizedStatus == 'complete' || normalizedStatus == 'completed';
  }

  bool get hasShippingInformation {
    return shippingPeriod.isNotEmpty || shippingImageUrl.isNotEmpty;
  }

  String get displayLocation {
    if (address.isNotEmpty) {
      return address;
    }

    return governorate;
  }

  String get displayCustomerName {
    if (customerName.isNotEmpty) {
      return customerName;
    }

    if (customerId > 0) {
      return 'العميل #$customerId';
    }

    return 'عميل غير معروف';
  }

  factory SellerOrderModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> product = _toMap(json['product']);

    final Map<String, dynamic> shipping = _toMap(json['shipping']);

    final Map<String, dynamic> customer = _toMap(
      json['customer'] ?? json['user'] ?? json['buyer'],
    );

    final int quantity = _toInt(
      json['quantity'] ?? json['qty'] ?? json['count'],
    );

    final double unitPrice = _toDouble(
      json['price'] ?? json['unit_price'] ?? product['price'],
    );

    double totalPrice = _toDouble(
      json['total_price'] ??
          json['total'] ??
          json['amount'] ??
          json['final_price'],
    );

    if (totalPrice <= 0 && unitPrice > 0 && quantity > 0) {
      totalPrice = unitPrice * quantity;
    }

    return SellerOrderModel(
      id: _toInt(json['id']),
      customerId: _toInt(
        json['customer_id'] ?? json['user_id'] ?? customer['id'],
      ),
      productId: _toInt(json['product_id'] ?? product['id']),
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      status: _firstNonEmpty([json['status'], 'pending']),
      productName: _firstNonEmpty([
        product['title'],
        product['name'],
        json['product_name'],
        json['title'],
        'منتج بدون اسم',
      ]),
      productImageUrl: _firstNonEmpty([
        product['product_image_url'],
        product['image_url'],
        product['image'],
        json['product_image_url'],
      ]),
      customerName: _resolveCustomerName(json: json, customer: customer),
      governorate: _firstNonEmpty([
        shipping['governorate'],
        shipping['city'],
        json['governorate'],
        json['city'],
        customer['governorate'],
      ]),
      address: _firstNonEmpty([
        shipping['address'],
        shipping['location'],
        json['address'],
        json['location'],
      ]),
      phone: _firstNonEmpty([
        shipping['phone'],
        shipping['phone_number'],
        json['phone'],
        json['phone_number'],
        customer['phone'],
      ]),
      shippingPeriod: _firstNonEmpty([
        shipping['period'],
        shipping['shipping_period'],
        json['period'],
      ]),
      shippingImageUrl: _firstNonEmpty([
        shipping['image'],
        shipping['image_url'],
        shipping['shipping_image'],
        json['shipping_image'],
      ]),
      createdAt: _firstNonEmpty([
        json['created_at'],
        json['order_date'],
        json['date'],
      ]),
      rawData: Map<String, dynamic>.from(json),
    );
  }

  static String _resolveCustomerName({
    required Map<String, dynamic> json,
    required Map<String, dynamic> customer,
  }) {
    final String directName = _firstNonEmpty([
      customer['name'],
      customer['full_name'],
      json['customer_name'],
      json['buyer_name'],
    ]);

    if (directName.isNotEmpty) {
      return directName;
    }

    final String firstName = _firstNonEmpty([
      customer['first_name'],
      json['customer_first_name'],
    ]);

    final String lastName = _firstNonEmpty([
      customer['last_name'],
      json['customer_last_name'],
    ]);

    final String fullName = [
      firstName,
      lastName,
    ].where((part) => part.isNotEmpty).join(' ').trim();

    if (fullName.isNotEmpty) {
      return fullName;
    }

    /*
     * حل مؤقت: نعرض البريد الإلكتروني عندما لا يرسل الباك اسم العميل.
     */
    return _firstNonEmpty([
      customer['email'],
      json['customer_email'],
      json['buyer_email'],
    ]);
  }

  static Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
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

    return int.tryParse(value.toString().trim()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString().trim()) ?? 0;
  }

  static String _firstNonEmpty(List<dynamic> values) {
    for (final dynamic value in values) {
      if (value == null) {
        continue;
      }

      final String result = value.toString().trim();

      if (result.isNotEmpty && result.toLowerCase() != 'null') {
        return result;
      }
    }

    return '';
  }
}
