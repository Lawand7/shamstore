import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/products/models/product_model.dart';
import 'package:shamstore/features/products/repositories/product_repository.dart';

class ProductController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<ProductModel> products = <ProductModel>[].obs;

  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt perPage = 10.obs;
  final RxInt total = 0.obs;

  final RxBool isCategoryLoading = false.obs;
  final RxBool isCategoryLoadingMore = false.obs;
  final RxString categoryErrorMessage = ''.obs;

  final RxList<ProductModel> categoryProducts = <ProductModel>[].obs;

  final RxInt categoryCurrentPage = 1.obs;
  final RxInt categoryLastPage = 1.obs;
  final RxInt categoryPerPage = 10.obs;
  final RxInt categoryTotal = 0.obs;

  final RxBool isSearchLoading = false.obs;
  final RxString searchErrorMessage = ''.obs;
  final RxList<ProductModel> searchProducts = <ProductModel>[].obs;

  final RxBool isFilterLoading = false.obs;
  final RxBool isFilterLoadingMore = false.obs;
  final RxString filterErrorMessage = ''.obs;

  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  final RxInt filterCurrentPage = 1.obs;
  final RxInt filterLastPage = 1.obs;
  final RxInt filterPerPage = 10.obs;
  final RxInt filterTotal = 0.obs;

  int? selectedCategoryId;

  int? activeFilterCategoryId;
  double? activeFilterMinPrice;
  double? activeFilterMaxPrice;
  String? activeFilterGovernorate;

  bool get hasMorePages => currentPage.value < lastPage.value;

  bool get hasMoreCategoryPages =>
      categoryCurrentPage.value < categoryLastPage.value;

  bool get hasMoreFilterPages => filterCurrentPage.value < filterLastPage.value;

  bool get hasActiveFilter {
    final governorate = activeFilterGovernorate?.trim();

    return (activeFilterCategoryId != null && activeFilterCategoryId! > 0) ||
        (activeFilterMinPrice != null && activeFilterMaxPrice != null) ||
        (governorate != null &&
            governorate.isNotEmpty &&
            governorate != 'الكل');
  }

  Future<void> fetchProducts({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        lastPage.value = 1;
        total.value = 0;
        products.clear();
      }

      isLoading.value = true;
      errorMessage.value = '';

      final result = await _productRepository.getAllProducts(
        page: currentPage.value,
      );

      products.assignAll(result.products);

      currentPage.value = result.currentPage;
      lastPage.value = result.lastPage;
      perPage.value = result.perPage;
      total.value = result.total;

      debugPrint('========== PRODUCTS LOADED ==========');
      debugPrint('Products count: ${products.length}');
      debugPrint('Current page: ${currentPage.value}');
      debugPrint('Last page: ${lastPage.value}');
      debugPrint('Total: ${total.value}');
      debugPrint('=====================================');
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');

      debugPrint('========== PRODUCTS LOAD ERROR ==========');
      debugPrint(errorMessage.value);
      debugPrint('=========================================');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreProducts() async {
    if (isLoadingMore.value || isLoading.value || !hasMorePages) {
      return;
    }

    try {
      isLoadingMore.value = true;
      errorMessage.value = '';

      final nextPage = currentPage.value + 1;

      final result = await _productRepository.getAllProducts(page: nextPage);

      products.addAll(result.products);

      currentPage.value = result.currentPage;
      lastPage.value = result.lastPage;
      perPage.value = result.perPage;
      total.value = result.total;

      debugPrint('========== MORE PRODUCTS LOADED ==========');
      debugPrint('Products count: ${products.length}');
      debugPrint('Current page: ${currentPage.value}');
      debugPrint('Last page: ${lastPage.value}');
      debugPrint('==========================================');
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');

      debugPrint('========== LOAD MORE PRODUCTS ERROR ==========');
      debugPrint(errorMessage.value);
      debugPrint('==============================================');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> fetchProductsByCategory({
    required int categoryId,
    bool refresh = false,
  }) async {
    try {
      if (refresh || selectedCategoryId != categoryId) {
        selectedCategoryId = categoryId;

        categoryCurrentPage.value = 1;
        categoryLastPage.value = 1;
        categoryTotal.value = 0;
        categoryProducts.clear();
      }

      isCategoryLoading.value = true;
      categoryErrorMessage.value = '';

      final result = await _productRepository.getProductsByCategory(
        categoryId: categoryId,
        page: categoryCurrentPage.value,
      );

      categoryProducts.assignAll(result.products);

      categoryCurrentPage.value = result.currentPage;
      categoryLastPage.value = result.lastPage;
      categoryPerPage.value = result.perPage;
      categoryTotal.value = result.total;

      debugPrint('========== CATEGORY PRODUCTS LOADED ==========');
      debugPrint('Category ID: $categoryId');
      debugPrint('Products count: ${categoryProducts.length}');
      debugPrint('Current page: ${categoryCurrentPage.value}');
      debugPrint('Last page: ${categoryLastPage.value}');
      debugPrint('Total: ${categoryTotal.value}');
      debugPrint('==============================================');
    } catch (e) {
      categoryErrorMessage.value = e.toString().replaceFirst('Exception: ', '');

      debugPrint('========== CATEGORY PRODUCTS LOAD ERROR ==========');
      debugPrint(categoryErrorMessage.value);
      debugPrint('==================================================');
    } finally {
      isCategoryLoading.value = false;
    }
  }

  Future<void> loadMoreCategoryProducts() async {
    final categoryId = selectedCategoryId;

    if (categoryId == null) {
      return;
    }

    if (isCategoryLoadingMore.value ||
        isCategoryLoading.value ||
        !hasMoreCategoryPages) {
      return;
    }

    try {
      isCategoryLoadingMore.value = true;
      categoryErrorMessage.value = '';

      final nextPage = categoryCurrentPage.value + 1;

      final result = await _productRepository.getProductsByCategory(
        categoryId: categoryId,
        page: nextPage,
      );

      categoryProducts.addAll(result.products);

      categoryCurrentPage.value = result.currentPage;
      categoryLastPage.value = result.lastPage;
      categoryPerPage.value = result.perPage;
      categoryTotal.value = result.total;

      debugPrint('========== MORE CATEGORY PRODUCTS LOADED ==========');
      debugPrint('Category ID: $categoryId');
      debugPrint('Products count: ${categoryProducts.length}');
      debugPrint('Current page: ${categoryCurrentPage.value}');
      debugPrint('Last page: ${categoryLastPage.value}');
      debugPrint('===================================================');
    } catch (e) {
      categoryErrorMessage.value = e.toString().replaceFirst('Exception: ', '');

      debugPrint('========== LOAD MORE CATEGORY PRODUCTS ERROR ==========');
      debugPrint(categoryErrorMessage.value);
      debugPrint('=======================================================');
    } finally {
      isCategoryLoadingMore.value = false;
    }
  }

  Future<void> searchProductsByProductUrl({required String query}) async {
    final cleanedQuery = query.trim();

    if (cleanedQuery.isEmpty) {
      clearSearchProducts();
      return;
    }

    try {
      isSearchLoading.value = true;
      searchErrorMessage.value = '';

      final result = await _productRepository.searchProductsByProductUrl(
        query: cleanedQuery,
      );

      searchProducts.assignAll(result);

      debugPrint('========== SEARCH PRODUCTS LOADED ==========');
      debugPrint('Query: $cleanedQuery');
      debugPrint('Products count: ${searchProducts.length}');
      debugPrint('============================================');
    } catch (e) {
      searchErrorMessage.value = e.toString().replaceFirst('Exception: ', '');

      debugPrint('========== SEARCH PRODUCTS ERROR ==========');
      debugPrint(searchErrorMessage.value);
      debugPrint('===========================================');
    } finally {
      isSearchLoading.value = false;
    }
  }

  void clearSearchProducts() {
    searchProducts.clear();
    searchErrorMessage.value = '';
    isSearchLoading.value = false;
  }

  Future<void> filterProducts({
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? governorate,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        filterCurrentPage.value = 1;
        filterLastPage.value = 1;
        filterTotal.value = 0;
        filteredProducts.clear();
      }

      activeFilterCategoryId = categoryId;
      activeFilterMinPrice = minPrice;
      activeFilterMaxPrice = maxPrice;
      activeFilterGovernorate = governorate;

      isFilterLoading.value = true;
      filterErrorMessage.value = '';

      final result = await _productRepository.filterProducts(
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        governorate: governorate,
        page: filterCurrentPage.value,
      );

      filteredProducts.assignAll(result.products);

      filterCurrentPage.value = result.currentPage;
      filterLastPage.value = result.lastPage;
      filterPerPage.value = result.perPage;
      filterTotal.value = result.total;

      debugPrint('========== FILTER PRODUCTS LOADED ==========');
      debugPrint('Category ID: $categoryId');
      debugPrint('Min Price: $minPrice');
      debugPrint('Max Price: $maxPrice');
      debugPrint('Governorate: $governorate');
      debugPrint('Products count: ${filteredProducts.length}');
      debugPrint('Current page: ${filterCurrentPage.value}');
      debugPrint('Last page: ${filterLastPage.value}');
      debugPrint('Total: ${filterTotal.value}');
      debugPrint('============================================');
    } catch (e) {
      filterErrorMessage.value = e.toString().replaceFirst('Exception: ', '');

      debugPrint('========== FILTER PRODUCTS ERROR ==========');
      debugPrint(filterErrorMessage.value);
      debugPrint('===========================================');
    } finally {
      isFilterLoading.value = false;
    }
  }

  Future<void> loadMoreFilteredProducts() async {
    if (isFilterLoadingMore.value ||
        isFilterLoading.value ||
        !hasMoreFilterPages) {
      return;
    }

    try {
      isFilterLoadingMore.value = true;
      filterErrorMessage.value = '';

      final nextPage = filterCurrentPage.value + 1;

      final result = await _productRepository.filterProducts(
        categoryId: activeFilterCategoryId,
        minPrice: activeFilterMinPrice,
        maxPrice: activeFilterMaxPrice,
        governorate: activeFilterGovernorate,
        page: nextPage,
      );

      filteredProducts.addAll(result.products);

      filterCurrentPage.value = result.currentPage;
      filterLastPage.value = result.lastPage;
      filterPerPage.value = result.perPage;
      filterTotal.value = result.total;

      debugPrint('========== MORE FILTER PRODUCTS LOADED ==========');
      debugPrint('Products count: ${filteredProducts.length}');
      debugPrint('Current page: ${filterCurrentPage.value}');
      debugPrint('Last page: ${filterLastPage.value}');
      debugPrint('=================================================');
    } catch (e) {
      filterErrorMessage.value = e.toString().replaceFirst('Exception: ', '');

      debugPrint('========== LOAD MORE FILTER PRODUCTS ERROR ==========');
      debugPrint(filterErrorMessage.value);
      debugPrint('=====================================================');
    } finally {
      isFilterLoadingMore.value = false;
    }
  }

  void clearFilteredProducts() {
    filteredProducts.clear();
    filterErrorMessage.value = '';
    isFilterLoading.value = false;
    isFilterLoadingMore.value = false;

    filterCurrentPage.value = 1;
    filterLastPage.value = 1;
    filterPerPage.value = 10;
    filterTotal.value = 0;

    activeFilterCategoryId = null;
    activeFilterMinPrice = null;
    activeFilterMaxPrice = null;
    activeFilterGovernorate = null;
  }
}
