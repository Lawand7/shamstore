import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:shamstore/core/network/dio_client.dart';
import 'package:shamstore/features/products/models/product_model.dart';

class CustomerFavoriteProductsResult {
  final List<ProductModel> products;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const CustomerFavoriteProductsResult({
    required this.products,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });
}

class CustomerCartResult {
  final int? cartId;
  final List<CustomerCartItem> items;
  final double total;

  const CustomerCartResult({
    required this.cartId,
    required this.items,
    required this.total,
  });
}

class CustomerCartItem {
  final int id;
  final int? cartId;
  final int productId;
  final int quantity;
  final double totalPrice;
  final String? createdAt;
  final String? updatedAt;
  final ProductModel? product;

  const CustomerCartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
  });

  factory CustomerCartItem.fromJson(Map<String, dynamic> json) {
    ProductModel? parsedProduct;

    final rawProduct = json['product'];
    if (rawProduct is Map) {
      parsedProduct = ProductModel.fromJson(
        Map<String, dynamic>.from(rawProduct),
      );
    }

    return CustomerCartItem(
      id: _toIntStatic(json['id']),
      cartId: json['cart_id'] == null ? null : _toIntStatic(json['cart_id']),
      productId: _toIntStatic(json['product_id']),
      quantity: _toIntStatic(json['quantity']),
      totalPrice: _toDoubleStatic(json['total_price']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      product: parsedProduct,
    );
  }

  static int _toIntStatic(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDoubleStatic(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}

class CustomerRepository {
  Future<Map<String, dynamic>> addToFavorites({required int productId}) async {
    try {
      final response = await DioClient.dio.post('/addToFavorites/$productId');

      debugPrint('========== ADD TO FAVORITES RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('===================================================');

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('صيغة استجابة إضافة المنتج للمفضلة غير متوقعة');
      }

      return data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected add to favorites error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> removeFromFavorites({
    required int productId,
  }) async {
    try {
      final response = await DioClient.dio.post(
        '/removeFromFavorites/$productId',
      );

      debugPrint('========== REMOVE FROM FAVORITES RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('========================================================');

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('صيغة استجابة حذف المنتج من المفضلة غير متوقعة');
      }

      return data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected remove from favorites error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<CustomerFavoriteProductsResult> getFavoriteProducts({
    int page = 1,
  }) async {
    try {
      final response = await DioClient.dio.get(
        '/getFavoriteProducts',
        queryParameters: {'page': page},
      );

      debugPrint('========== GET FAVORITE PRODUCTS RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('========================================================');

      return _parseFavoriteProductsResult(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected get favorite products error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<CustomerCartResult> getCart() async {
    try {
      final response = await DioClient.dio.get('/cart');

      debugPrint('========== GET CART RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('===========================================');

      return _parseCartResult(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected get cart error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<CustomerCartItem> addCartItem({
    required int productId,
    required int quantity,
  }) async {
    try {
      final formData = FormData.fromMap({
        'product_id': productId,
        'quantity': quantity,
      });

      final response = await DioClient.dio.post('/cart/items', data: formData);

      debugPrint('========== ADD CART ITEM RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('================================================');

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('صيغة استجابة إضافة المنتج للسلة غير متوقعة');
      }

      _throwIfNestedCartError(data);

      final rawItem = data['data'];

      if (rawItem is! Map) {
        throw Exception('لم يتم العثور على بيانات عنصر السلة');
      }

      return CustomerCartItem.fromJson(Map<String, dynamic>.from(rawItem));
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected add cart item error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<CustomerCartItem> updateCartItem({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await DioClient.dio.put(
        '/cart/items/$cartItemId',
        queryParameters: {'quantity': quantity},
      );

      debugPrint('========== UPDATE CART ITEM RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('===================================================');

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('صيغة استجابة تعديل عنصر السلة غير متوقعة');
      }

      _throwIfNestedCartError(data);

      final rawItem = data['data'];

      if (rawItem is Map && rawItem['original'] is Map) {
        final original = Map<String, dynamic>.from(rawItem['original'] as Map);

        if (original['item'] is Map) {
          return CustomerCartItem.fromJson(
            Map<String, dynamic>.from(original['item'] as Map),
          );
        }

        if (original['data'] is Map) {
          return CustomerCartItem.fromJson(
            Map<String, dynamic>.from(original['data'] as Map),
          );
        }
      }

      if (rawItem is Map) {
        return CustomerCartItem.fromJson(Map<String, dynamic>.from(rawItem));
      }

      final refreshedCart = await getCart();
      final updatedItem = refreshedCart.items.firstWhere(
        (item) => item.id == cartItemId,
        orElse: () =>
            throw Exception('لم يتم العثور على عنصر السلة بعد التعديل'),
      );

      return updatedItem;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected update cart item error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> removeCartItem({required int cartItemId}) async {
    try {
      final response = await DioClient.dio.delete('/cart/items/$cartItemId');

      debugPrint('========== REMOVE CART ITEM RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('===================================================');

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('صيغة استجابة حذف عنصر السلة غير متوقعة');
      }

      _throwIfNestedCartError(data);

      return data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected remove cart item error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  CustomerFavoriteProductsResult _parseFavoriteProductsResult(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw Exception('صيغة استجابة منتجات المفضلة غير متوقعة');
    }

    final productsObject = data['products'];

    if (productsObject is! Map<String, dynamic>) {
      throw Exception('لم يتم العثور على بيانات منتجات المفضلة');
    }

    final rawProducts = productsObject['data'];

    if (rawProducts is! List) {
      throw Exception('صيغة قائمة منتجات المفضلة غير صحيحة');
    }

    final products = rawProducts
        .whereType<Map>()
        .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    final pagination = data['pagination'];

    return CustomerFavoriteProductsResult(
      products: products,
      currentPage: _toInt(
        pagination is Map<String, dynamic>
            ? pagination['current_page']
            : productsObject['current_page'],
      ),
      lastPage: _toInt(
        pagination is Map<String, dynamic>
            ? pagination['last_page']
            : productsObject['last_page'],
      ),
      perPage: _toInt(
        pagination is Map<String, dynamic>
            ? pagination['per_page']
            : productsObject['per_page'],
      ),
      total: _toInt(
        pagination is Map<String, dynamic>
            ? pagination['total']
            : productsObject['total'],
      ),
    );
  }

  CustomerCartResult _parseCartResult(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw Exception('صيغة استجابة السلة غير متوقعة');
    }

    final cartData = _extractOriginalData(data);

    final rawCartId = cartData['cart_id'];
    final rawItems = cartData['items'];

    if (rawItems is! List) {
      throw Exception('صيغة عناصر السلة غير صحيحة');
    }

    final items = rawItems
        .whereType<Map>()
        .map(
          (item) => CustomerCartItem.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();

    final total = items.fold<double>(0, (sum, item) => sum + item.totalPrice);

    return CustomerCartResult(
      cartId: rawCartId == null ? null : _toInt(rawCartId),
      items: items,
      total: total,
    );
  }

  Map<String, dynamic> _extractOriginalData(Map<String, dynamic> data) {
    if (data['original'] is Map) {
      return Map<String, dynamic>.from(data['original'] as Map);
    }

    return data;
  }

  void _throwIfNestedCartError(Map<String, dynamic> data) {
    final directMessage = data['message']?.toString().trim();

    if (directMessage != null &&
        directMessage.toLowerCase().contains('not found')) {
      throw Exception(directMessage);
    }

    final responseData = data['data'];

    if (responseData is Map && responseData['original'] is Map) {
      final original = Map<String, dynamic>.from(
        responseData['original'] as Map,
      );
      final originalMessage = original['message']?.toString().trim();

      if (originalMessage != null && originalMessage.isNotEmpty) {
        throw Exception(originalMessage);
      }
    }

    if (data['original'] is Map) {
      final original = Map<String, dynamic>.from(data['original'] as Map);
      final originalMessage = original['message']?.toString().trim();

      if (originalMessage != null &&
          originalMessage.toLowerCase().contains('not found')) {
        throw Exception(originalMessage);
      }
    }
  }

  String _handleDioError(DioException e) {
    final responseData = e.response?.data;

    if (responseData is Map<String, dynamic>) {
      if (responseData['message'] != null) {
        return responseData['message'].toString();
      }

      if (responseData['error'] != null) {
        return responseData['error'].toString();
      }

      if (responseData['errors'] != null) {
        return responseData['errors'].toString();
      }
    }

    if (responseData is String && responseData.trim().isNotEmpty) {
      return responseData;
    }

    if (e.type == DioExceptionType.connectionTimeout) {
      return 'انتهت مهلة الاتصال بالسيرفر';
    }

    if (e.type == DioExceptionType.receiveTimeout) {
      return 'السيرفر تأخر في إرسال الاستجابة';
    }

    if (e.type == DioExceptionType.sendTimeout) {
      return 'انتهت مهلة إرسال الطلب';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'تعذر الاتصال بالسيرفر. تأكد أن Laravel يعمل وأن adb reverse مفعّل';
    }

    if (e.response?.statusCode == 400) {
      return 'الطلب غير صالح';
    }

    if (e.response?.statusCode == 401) {
      return 'غير مصرح. يرجى تسجيل الدخول من جديد';
    }

    if (e.response?.statusCode == 403) {
      return 'هذه العملية متاحة للمشتري فقط';
    }

    if (e.response?.statusCode == 404) {
      return 'العنصر غير موجود أو رابط الطلب غير صحيح';
    }

    if (e.response?.statusCode == 422) {
      return 'بيانات الطلب غير صحيحة';
    }

    if (e.response?.statusCode == 500) {
      return 'خطأ داخلي في السيرفر';
    }

    if (e.response?.statusCode != null) {
      return 'فشل تنفيذ الطلب. كود الخطأ: ${e.response?.statusCode}';
    }

    return 'فشل الاتصال بالسيرفر';
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }
}
