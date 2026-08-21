import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/products/models/product_model.dart';
import 'package:shamstore/features/seller/repositories/seller_product_repository.dart';

class SellerProductController extends GetxController {
  final SellerProductRepository _sellerProductRepository =
      SellerProductRepository();

  final RxBool isCreatingProduct = false.obs;
  final RxString createProductErrorMessage = ''.obs;
  final Rxn<ProductModel> createdProduct = Rxn<ProductModel>();

  final RxBool isUpdatingProduct = false.obs;
  final RxString updateProductErrorMessage = ''.obs;
  final RxMap<String, dynamic> updatedProductResponse = <String, dynamic>{}.obs;

  final RxBool isDeletingProduct = false.obs;
  final RxString deleteProductErrorMessage = ''.obs;
  final RxInt deletingProductId = 0.obs;

  final RxBool isLoadingMyProducts = false.obs;
  final RxString myProductsErrorMessage = ''.obs;
  final RxList<Map<String, dynamic>> myProducts = <Map<String, dynamic>>[].obs;

  final RxBool isLoadingActiveProducts = false.obs;
  final RxString activeProductsErrorMessage = ''.obs;
  final RxList<Map<String, dynamic>> myActiveProducts =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoadingInactiveProducts = false.obs;
  final RxString inactiveProductsErrorMessage = ''.obs;
  final RxList<Map<String, dynamic>> myInactiveProducts =
      <Map<String, dynamic>>[].obs;

  final RxBool isChangingProductVisibility = false.obs;
  final RxString productVisibilityErrorMessage = ''.obs;
  final RxInt changingVisibilityProductId = 0.obs;

  final RxBool isLoadingProductCounts = false.obs;
  final RxString productCountsErrorMessage = ''.obs;
  final RxBool hasLoadedProductCounts = false.obs;
  final RxInt activeProductsCountFromServer = 0.obs;
  final RxInt inactiveProductsCountFromServer = 0.obs;

  Future<bool> createProduct({
    required String title,
    required String description,
    required double price,
    required int quantity,
    required String governorate,
    required int categoryId,
    required String status, // <-- تمت إضافة بارامتر الحالة
    required File productImageFile,
  }) async {
    try {
      isCreatingProduct.value = true;
      createProductErrorMessage.value = '';
      createdProduct.value = null;

      final product = await _sellerProductRepository.createProduct(
        title: title,
        description: description,
        price: price,
        quantity: quantity,
        governorate: governorate,
        categoryId: categoryId,
        status: status, // <-- إرسال الحالة للـ Repository
        productImageFile: productImageFile,
      );

      createdProduct.value = product;

      debugPrint('========== SELLER PRODUCT CREATED ==========');
      debugPrint('Product ID: ${product.id}');
      debugPrint('Title: ${product.title}');
      debugPrint('Status: $status');
      debugPrint('Category ID: ${product.categoryId}');
      debugPrint('============================================');

      return true;
    } catch (e) {
      createProductErrorMessage.value = e.toString().replaceFirst(
        'Exception: ',
        '',
      );
      debugPrint('Create product error: ${createProductErrorMessage.value}');
      return false;
    } finally {
      isCreatingProduct.value = false;
    }
  }

  Future<bool> updateProduct({
    required int productId,
    String? title,
    String? description,
    double? price,
    int? quantity,
    String? governorate,
    int? categoryId,
    String? status, // <-- تمت إضافة بارامتر الحالة للتعديل
    File? productImageFile,
  }) async {
    try {
      isUpdatingProduct.value = true;
      updateProductErrorMessage.value = '';
      updatedProductResponse.clear();

      final response = await _sellerProductRepository.updateProduct(
        productId: productId,
        title: title,
        description: description,
        price: price,
        quantity: quantity,
        governorate: governorate,
        categoryId: categoryId,
        status: status, // <-- إرسال الحالة
        productImageFile: productImageFile,
      );

      updatedProductResponse.assignAll(response);

      debugPrint('========== SELLER PRODUCT UPDATED ==========');
      debugPrint(response.toString());
      debugPrint('============================================');

      return true;
    } catch (e) {
      updateProductErrorMessage.value = e.toString().replaceFirst(
        'Exception: ',
        '',
      );
      debugPrint('Update product error: ${updateProductErrorMessage.value}');
      return false;
    } finally {
      isUpdatingProduct.value = false;
    }
  }

  Future<bool> deleteProduct({required int productId}) async {
    try {
      isDeletingProduct.value = true;
      deletingProductId.value = productId;
      deleteProductErrorMessage.value = '';

      final response = await _sellerProductRepository.deleteProduct(
        productId: productId,
      );

      debugPrint('========== PRODUCT DELETED ==========');
      debugPrint(response.toString());
      debugPrint('=====================================');

      return true;
    } catch (e) {
      deleteProductErrorMessage.value = e.toString().replaceFirst(
        'Exception: ',
        '',
      );
      debugPrint('Delete product error: ${deleteProductErrorMessage.value}');
      return false;
    } finally {
      isDeletingProduct.value = false;
      deletingProductId.value = 0;
    }
  }

  Future<bool> fetchAllMyProducts({int page = 1}) async {
    try {
      isLoadingMyProducts.value = true;
      myProductsErrorMessage.value = '';

      final products = await _sellerProductRepository.getAllMyProducts(
        page: page,
      );

      myProducts.assignAll(products);

      debugPrint('========== ALL MY PRODUCTS LOADED ==========');
      debugPrint('Count: ${myProducts.length}');
      debugPrint('============================================');

      return true;
    } catch (e) {
      myProductsErrorMessage.value = e.toString().replaceFirst(
        'Exception: ',
        '',
      );
      debugPrint('Get all products error: ${myProductsErrorMessage.value}');
      return false;
    } finally {
      isLoadingMyProducts.value = false;
    }
  }

  Future<bool> fetchMyActiveProducts({int page = 1}) async {
    try {
      isLoadingActiveProducts.value = true;
      activeProductsErrorMessage.value = '';

      final products = await _sellerProductRepository.getMyActiveProducts(
        page: page,
      );

      myActiveProducts.assignAll(products);

      debugPrint('========== ACTIVE PRODUCTS LOADED ==========');
      debugPrint('Count: ${myActiveProducts.length}');
      debugPrint('============================================');

      return true;
    } catch (e) {
      activeProductsErrorMessage.value = e.toString().replaceFirst(
        'Exception: ',
        '',
      );
      debugPrint(
        'Get active products error: ${activeProductsErrorMessage.value}',
      );
      return false;
    } finally {
      isLoadingActiveProducts.value = false;
    }
  }

  Future<bool> fetchMyInactiveProducts({int page = 1}) async {
    try {
      isLoadingInactiveProducts.value = true;
      inactiveProductsErrorMessage.value = '';

      final products = await _sellerProductRepository.getMyInactiveProducts(
        page: page,
      );

      myInactiveProducts.assignAll(products);

      debugPrint('========== INACTIVE PRODUCTS LOADED ==========');
      debugPrint('Count: ${myInactiveProducts.length}');
      debugPrint('==============================================');

      return true;
    } catch (e) {
      inactiveProductsErrorMessage.value = e.toString().replaceFirst(
        'Exception: ',
        '',
      );
      debugPrint(
        'Get inactive products error: ${inactiveProductsErrorMessage.value}',
      );
      return false;
    } finally {
      isLoadingInactiveProducts.value = false;
    }
  }

  Future<bool> fetchMyProductCounts() async {
    try {
      isLoadingProductCounts.value = true;
      productCountsErrorMessage.value = '';

      final activeCount = await _sellerProductRepository
          .countMyActiveProducts();
      final inactiveCount = await _sellerProductRepository
          .countMyInactiveProducts();

      activeProductsCountFromServer.value = activeCount;
      inactiveProductsCountFromServer.value = inactiveCount;
      hasLoadedProductCounts.value = true;

      debugPrint('========== PRODUCT COUNTS LOADED ==========');
      debugPrint('Active: $activeCount');
      debugPrint('Inactive: $inactiveCount');
      debugPrint('===========================================');

      return true;
    } catch (e) {
      productCountsErrorMessage.value = e.toString().replaceFirst(
        'Exception: ',
        '',
      );
      hasLoadedProductCounts.value = false;
      debugPrint('Product counts error: ${productCountsErrorMessage.value}');
      return false;
    } finally {
      isLoadingProductCounts.value = false;
    }
  }

  Future<bool> hideProduct({required int productId}) async {
    try {
      isChangingProductVisibility.value = true;
      changingVisibilityProductId.value = productId;
      productVisibilityErrorMessage.value = '';

      final response = await _sellerProductRepository.hideProduct(
        productId: productId,
      );

      debugPrint('========== PRODUCT HIDDEN ==========');
      debugPrint(response.toString());
      debugPrint('====================================');

      return true;
    } catch (e) {
      productVisibilityErrorMessage.value = e.toString().replaceFirst(
        'Exception: ',
        '',
      );
      debugPrint('Hide product error: ${productVisibilityErrorMessage.value}');
      return false;
    } finally {
      isChangingProductVisibility.value = false;
      changingVisibilityProductId.value = 0;
    }
  }

  Future<bool> activeProduct({required int productId}) async {
    try {
      isChangingProductVisibility.value = true;
      changingVisibilityProductId.value = productId;
      productVisibilityErrorMessage.value = '';

      final response = await _sellerProductRepository.activeProduct(
        productId: productId,
      );

      debugPrint('========== PRODUCT ACTIVATED ==========');
      debugPrint(response.toString());
      debugPrint('=======================================');

      return true;
    } catch (e) {
      productVisibilityErrorMessage.value = e.toString().replaceFirst(
        'Exception: ',
        '',
      );
      debugPrint(
        'Active product error: ${productVisibilityErrorMessage.value}',
      );
      return false;
    } finally {
      isChangingProductVisibility.value = false;
      changingVisibilityProductId.value = 0;
    }
  }

  int get activeProductsCount {
    if (hasLoadedProductCounts.value) {
      return activeProductsCountFromServer.value;
    }

    return myProducts.where((product) {
      return _toInt(product['is_active']) == 1;
    }).length;
  }

  int get inactiveProductsCount {
    if (hasLoadedProductCounts.value) {
      return inactiveProductsCountFromServer.value;
    }

    return myProducts.where((product) {
      return _toInt(product['is_active']) == 0;
    }).length;
  }

  void clearCreateProductState() {
    createProductErrorMessage.value = '';
    createdProduct.value = null;
    isCreatingProduct.value = false;
  }

  void clearUpdateProductState() {
    updateProductErrorMessage.value = '';
    updatedProductResponse.clear();
    isUpdatingProduct.value = false;
  }

  void clearDeleteProductState() {
    deleteProductErrorMessage.value = '';
    isDeletingProduct.value = false;
    deletingProductId.value = 0;
  }

  void clearMyProductsState() {
    myProductsErrorMessage.value = '';
    myProducts.clear();
    isLoadingMyProducts.value = false;
  }

  void clearActiveProductsState() {
    activeProductsErrorMessage.value = '';
    myActiveProducts.clear();
    isLoadingActiveProducts.value = false;
  }

  void clearInactiveProductsState() {
    inactiveProductsErrorMessage.value = '';
    myInactiveProducts.clear();
    isLoadingInactiveProducts.value = false;
  }

  void clearProductVisibilityState() {
    productVisibilityErrorMessage.value = '';
    isChangingProductVisibility.value = false;
    changingVisibilityProductId.value = 0;
  }

  void clearProductCountsState() {
    productCountsErrorMessage.value = '';
    activeProductsCountFromServer.value = 0;
    inactiveProductsCountFromServer.value = 0;
    hasLoadedProductCounts.value = false;
    isLoadingProductCounts.value = false;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
