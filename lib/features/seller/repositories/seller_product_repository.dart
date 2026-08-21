import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:shamstore/core/network/dio_client.dart';
import 'package:shamstore/features/products/models/product_model.dart';

class SellerProductRepository {
  Future<ProductModel> createProduct({
    required String title,
    required String description,
    required double price,
    required int quantity,
    required String governorate,
    required int categoryId,
    required String status, // <-- تمت إضافة بارامتر الحالة هنا
    required File productImageFile,
  }) async {
    try {
      final fileName = productImageFile.path.split(Platform.pathSeparator).last;

      final formData = FormData.fromMap({
        'title': title.trim(),
        'description': description.trim(),
        'price': price,
        'quantity': quantity,
        'governorate': governorate.trim(),
        'category_id': categoryId,
        'status': status.trim(), // <-- إرسال الحالة إلى الباك إند
        'product_image_url': await MultipartFile.fromFile(
          productImageFile.path,
          filename: fileName,
        ),
      });

      final response = await DioClient.dio.post('/products', data: formData);

      debugPrint('========== SELLER CREATE PRODUCT RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('========================================================');

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('صيغة استجابة إنشاء المنتج غير متوقعة');
      }

      final product = data['product'];

      if (product is! Map) {
        throw Exception('لم يتم العثور على بيانات المنتج في الاستجابة');
      }

      return ProductModel.fromJson(Map<String, dynamic>.from(product));
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected seller create product error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> updateProduct({
    required int productId,
    String? title,
    String? description,
    double? price,
    int? quantity,
    String? governorate,
    int? categoryId,
    String? status, // <-- تمت إضافة بارامتر الحالة هنا للتعديل
    File? productImageFile,
  }) async {
    try {
      final Map<String, dynamic> formMap = {'_method': 'PUT'};

      bool hasUpdateData = false;

      if (title != null && title.trim().isNotEmpty) {
        formMap['title'] = title.trim();
        hasUpdateData = true;
      }

      if (description != null && description.trim().isNotEmpty) {
        formMap['description'] = description.trim();
        hasUpdateData = true;
      }

      if (price != null) {
        formMap['price'] = price;
        hasUpdateData = true;
      }

      if (quantity != null) {
        formMap['quantity'] = quantity;
        hasUpdateData = true;
      }

      if (governorate != null && governorate.trim().isNotEmpty) {
        formMap['governorate'] = governorate.trim();
        hasUpdateData = true;
      }

      if (categoryId != null) {
        formMap['category_id'] = categoryId;
        hasUpdateData = true;
      }

      // <-- إضافة التحقق من الحالة لتعديلها إن وجدت
      if (status != null && status.trim().isNotEmpty) {
        formMap['status'] = status.trim();
        hasUpdateData = true;
      }

      if (productImageFile != null) {
        final fileName = productImageFile.path
            .split(Platform.pathSeparator)
            .last;

        formMap['product_image_url'] = await MultipartFile.fromFile(
          productImageFile.path,
          filename: fileName,
        );

        hasUpdateData = true;
      }

      if (!hasUpdateData) {
        throw Exception('لم يتم إرسال أي بيانات لتعديل المنتج');
      }

      final formData = FormData.fromMap(formMap);

      final response = await DioClient.dio.post(
        '/products/$productId',
        data: formData,
      );

      debugPrint('========== SELLER UPDATE PRODUCT RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('========================================================');

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('صيغة استجابة تعديل المنتج غير متوقعة');
      }

      final product = data['product'];

      if (product is Map &&
          product['original'] is Map &&
          product['original']['message']?.toString().toLowerCase() ==
              'unauthorized') {
        throw Exception('غير مصرح. يرجى تسجيل الدخول كبائع من جديد');
      }

      return data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected seller update product error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> deleteProduct({required int productId}) async {
    try {
      final response = await DioClient.dio.delete('/products/$productId');

      debugPrint('========== SELLER DELETE PRODUCT RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('========================================================');

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('صيغة استجابة حذف المنتج غير متوقعة');
      }

      return data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected delete product error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<Map<String, dynamic>>> getAllMyProducts({int page = 1}) async {
    try {
      final response = await DioClient.dio.get(
        '/getAllMyProducts',
        queryParameters: {'page': page},
      );

      debugPrint('========== GET ALL MY PRODUCTS RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('======================================================');

      return _extractPaginatedProducts(response.data, 'منتجاتي');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected get all my products error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<Map<String, dynamic>>> getMyActiveProducts({int page = 1}) async {
    try {
      final response = await DioClient.dio.get(
        '/getMyActiveProducts',
        queryParameters: {'page': page},
      );

      debugPrint('========== GET MY ACTIVE PRODUCTS RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('=========================================================');

      return _extractPaginatedProducts(response.data, 'المنتجات المنشورة');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected get active products error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<Map<String, dynamic>>> getMyInactiveProducts({
    int page = 1,
  }) async {
    try {
      final response = await DioClient.dio.get(
        '/getMyInactiveProducts',
        queryParameters: {'page': page},
      );

      debugPrint('========== GET MY INACTIVE PRODUCTS RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('===========================================================');

      return _extractPaginatedProducts(response.data, 'المنتجات غير المنشورة');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected get inactive products error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<int> countMyActiveProducts() async {
    try {
      final response = await DioClient.dio.get('/countMyActiveProducts');

      debugPrint('========== COUNT MY ACTIVE PRODUCTS RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('===========================================================');

      return _extractCount(response.data, 'المنتجات المنشورة');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected count active products error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<int> countMyInactiveProducts() async {
    try {
      final response = await DioClient.dio.get('/countMyInactiveProducts');

      debugPrint(
        '========== COUNT MY INACTIVE PRODUCTS RAW RESPONSE ==========',
      );
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint(
        '=============================================================',
      );

      return _extractCount(response.data, 'المنتجات غير المنشورة');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected count inactive products error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> hideProduct({required int productId}) async {
    try {
      final response = await DioClient.dio.put('/product/$productId/hide');

      debugPrint('========== SELLER HIDE PRODUCT RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('======================================================');

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('صيغة استجابة إخفاء المنتج غير متوقعة');
      }

      return data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected hide product error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> activeProduct({required int productId}) async {
    try {
      final response = await DioClient.dio.put('/product/$productId/show');

      debugPrint('========== SELLER ACTIVE PRODUCT RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('========================================================');

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('صيغة استجابة نشر المنتج غير متوقعة');
      }

      return data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected active product error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  List<Map<String, dynamic>> _extractPaginatedProducts(
    dynamic responseData,
    String label,
  ) {
    if (responseData is! Map<String, dynamic>) {
      throw Exception('صيغة استجابة $label غير متوقعة');
    }

    final productsWrapper = responseData['products'];

    if (productsWrapper is! Map) {
      throw Exception('لم يتم العثور على products في استجابة $label');
    }

    final productsData = productsWrapper['data'];

    if (productsData is! List) {
      throw Exception('صيغة قائمة $label غير متوقعة');
    }

    return productsData
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  int _extractCount(dynamic responseData, String label) {
    if (responseData is! Map<String, dynamic>) {
      throw Exception('صيغة استجابة عدد $label غير متوقعة');
    }

    final count = responseData['count'];

    if (count == null) {
      throw Exception('لم يتم العثور على count في استجابة عدد $label');
    }

    return _toInt(count);
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
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
      return 'هذه العملية متاحة للبائع فقط أو المنتج لا يخص هذا الحساب';
    }

    if (e.response?.statusCode == 404) {
      return 'رابط المنتج غير موجود في Laravel';
    }

    if (e.response?.statusCode == 422) {
      return 'بيانات المنتج غير صحيحة';
    }

    if (e.response?.statusCode == 500) {
      return 'خطأ داخلي في السيرفر';
    }

    if (e.response?.statusCode != null) {
      return 'فشل تنفيذ الطلب. كود الخطأ: ${e.response?.statusCode}';
    }

    return 'فشل الاتصال بالسيرفر';
  }
}
