import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:shamstore/core/constants/api_constants.dart';
import 'package:shamstore/core/network/dio_client.dart';
import 'package:shamstore/features/products/models/product_model.dart';

class ProductPageResult {
  final List<ProductModel> products;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const ProductPageResult({
    required this.products,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });
}

class SellerRatingResult {
  final double? averageRating;
  final int ratingCount;
  final String? errorMessage;

  const SellerRatingResult({
    this.averageRating,
    this.ratingCount = 0,
    this.errorMessage,
  });

  bool get hasRating => averageRating != null && averageRating! > 0;
}

class ProductRepository {
  Future<String> reportProduct({
    required int productId,
    required String description,
  }) async {
    final cleanDescription = description.trim();

    if (productId <= 0) {
      throw Exception('تعذر تحديد المنتج لإرسال البلاغ');
    }

    if (cleanDescription.isEmpty) {
      throw Exception('يرجى كتابة تفاصيل المشكلة');
    }

    try {
      final response = await DioClient.dio.post(
        ApiConstants.reportProduct(productId),
        data: {'description': cleanDescription},
      );

      final data = response.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }

      return 'تم إرسال البلاغ إلى الإدارة بنجاح';
    } on DioException catch (error) {
      throw Exception(_reportProductError(error));
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<SellerRatingResult> getSellerRating({required int sellerId}) async {
    if (sellerId <= 0) {
      return const SellerRatingResult(
        errorMessage: 'تعذر تحديد البائع لعرض التقييم',
      );
    }

    try {
      final response = await DioClient.dio.get(
        ApiConstants.sellerRating(sellerId),
      );

      final data = response.data;
      if (data is! Map) {
        return const SellerRatingResult(
          errorMessage: 'تعذر قراءة تقييم البائع',
        );
      }

      final map = Map<String, dynamic>.from(data);
      final nestedMap = map['data'] is Map
          ? Map<String, dynamic>.from(map['data'] as Map)
          : <String, dynamic>{};
      final rawRating =
          map['most_common_rating'] ??
          map['average_rating'] ??
          nestedMap['most_common_rating'] ??
          nestedMap['average_rating'];
      final rating = _toDouble(rawRating);
      final ratingCount = _toInt(
        map['rating_count'] ?? nestedMap['rating_count'],
      );

      return SellerRatingResult(
        averageRating: rating > 0 ? rating : null,
        ratingCount: ratingCount,
      );
    } on DioException catch (error) {
      return SellerRatingResult(errorMessage: _sellerRatingError(error));
    } catch (_) {
      return const SellerRatingResult(errorMessage: 'تعذر تحميل تقييم البائع');
    }
  }

  Future<ProductPageResult> getAllProducts({int page = 1}) async {
    try {
      final response = await DioClient.dio.get(
        ApiConstants.showAllProducts,
        queryParameters: {'page': page},
      );

      debugPrint('========== SHOW ALL PRODUCTS RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('====================================================');

      return _parseProductPageResult(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected get all products error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<ProductPageResult> getProductsByCategory({
    required int categoryId,
    int page = 1,
  }) async {
    try {
      final response = await DioClient.dio.get(
        '/products/$categoryId/categories',
        queryParameters: {'page': page},
      );

      debugPrint('========== CATEGORY PRODUCTS RAW RESPONSE ==========');
      debugPrint('Category ID: $categoryId');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('====================================================');

      return _parseProductPageResult(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected get products by category error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<ProductModel>> searchProductsByProductUrl({
    required String query,
  }) async {
    try {
      final cleanedQuery = query.trim();

      final response = await DioClient.dio.get(
        '/products/searchByProductUrl',
        queryParameters: {'query': cleanedQuery},
      );

      debugPrint('========== SEARCH PRODUCTS RAW RESPONSE ==========');
      debugPrint('Query: $cleanedQuery');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('==================================================');

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('صيغة استجابة البحث غير متوقعة');
      }

      final rawProducts = data['products'];

      if (rawProducts is! List) {
        throw Exception('صيغة نتائج البحث غير صحيحة');
      }

      return _availableProducts(
        rawProducts.whereType<Map>().map(
          (item) => ProductModel.fromJson(Map<String, dynamic>.from(item)),
        ),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected search products error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<ProductPageResult> filterProducts({
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? governorate,
    int page = 1,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {'page': page};

      if (categoryId != null && categoryId > 0) {
        queryParameters['category_id'] = categoryId;
      }

      if (minPrice != null && maxPrice != null) {
        queryParameters['min_price'] = minPrice;
        queryParameters['max_price'] = maxPrice;
      }

      final cleanedGovernorate = governorate?.trim();

      if (cleanedGovernorate != null &&
          cleanedGovernorate.isNotEmpty &&
          cleanedGovernorate != 'الكل') {
        queryParameters['governorate'] = cleanedGovernorate;
      }

      final response = await DioClient.dio.get(
        '/products/filter',
        queryParameters: queryParameters,
      );

      debugPrint('========== FILTER PRODUCTS RAW RESPONSE ==========');
      debugPrint('Query Parameters: $queryParameters');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('==================================================');

      return _parseProductPageResult(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected filter products error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  ProductPageResult _parseProductPageResult(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw Exception('صيغة استجابة المنتجات غير متوقعة');
    }

    final productsObject = data['products'];

    if (productsObject is! Map<String, dynamic>) {
      throw Exception('لم يتم العثور على بيانات المنتجات');
    }

    final rawProducts = productsObject['data'];

    if (rawProducts is! List) {
      throw Exception('صيغة قائمة المنتجات غير صحيحة');
    }

    final products = _availableProducts(
      rawProducts.whereType<Map>().map(
        (item) => ProductModel.fromJson(Map<String, dynamic>.from(item)),
      ),
    );

    final pagination = data['pagination'];

    return ProductPageResult(
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

  String _handleDioError(DioException e) {
    final responseData = e.response?.data;

    if (e.response?.statusCode == 401) {
      return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول من جديد';
    }

    if (e.response?.statusCode == 403) {
      return 'لا تملك صلاحية الوصول إلى المنتجات';
    }

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

    if (e.response?.statusCode == 404) {
      return 'رابط المنتجات غير موجود في Laravel';
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

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is double) return value;

    if (value is int) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }

  List<ProductModel> _availableProducts(Iterable<ProductModel> products) {
    return products.where((product) => product.quantity > 0).toList();
  }

  String _reportProductError(DioException error) {
    final statusCode = error.response?.statusCode;

    if (statusCode == 401) {
      return 'انتهت الجلسة، يرجى تسجيل الدخول من جديد';
    }

    if (statusCode == 403) {
      return 'لا تملك صلاحية إرسال بلاغ عن المنتج';
    }

    if (statusCode == 404) {
      return 'المنتج غير موجود';
    }

    if (statusCode == 422) {
      return 'يرجى كتابة وصف صحيح للمشكلة';
    }

    if (statusCode == 500) {
      return 'تعذر إرسال البلاغ بسبب خطأ في الخادم';
    }

    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'تعذر الاتصال بالخادم لإرسال البلاغ';
      default:
        return 'تعذر إرسال البلاغ';
    }
  }

  String _sellerRatingError(DioException error) {
    switch (error.response?.statusCode) {
      case 401:
        return 'انتهت الجلسة، لا يمكن تحميل تقييم البائع';
      case 403:
        return 'لا تملك صلاحية عرض تقييم البائع';
      case 404:
        return 'لم يتم العثور على تقييم البائع';
      case 500:
        return 'تعذر تحميل تقييم البائع من الخادم';
    }

    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'تعذر الاتصال لتحميل تقييم البائع';
      default:
        return 'تعذر تحميل تقييم البائع';
    }
  }
}
