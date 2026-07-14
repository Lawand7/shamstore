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

class ProductRepository {
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

      return rawProducts
          .whereType<Map>()
          .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
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

    final products = rawProducts
        .whereType<Map>()
        .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();

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
      return 'لا تملك صلاحية الوصول إلى المنتجات';
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
}
