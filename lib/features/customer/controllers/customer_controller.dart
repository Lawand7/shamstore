import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/customer/repositories/customer_repository.dart';
import 'package:shamstore/features/products/models/product_model.dart';

class CustomerController extends GetxController {
  final CustomerRepository _customerRepository = CustomerRepository();

  final RxBool isLoadingFavorites = false.obs;
  final RxBool isLoadingMoreFavorites = false.obs;
  final RxString favoriteProductsErrorMessage = ''.obs;

  final RxList<ProductModel> favoriteProducts = <ProductModel>[].obs;
  final RxList<int> favoriteProductIds = <int>[].obs;

  final RxInt favoriteProductsCurrentPage = 1.obs;
  final RxInt favoriteProductsLastPage = 1.obs;
  final RxInt favoriteProductsPerPage = 10.obs;
  final RxInt favoriteProductsTotal = 0.obs;

  final RxBool isChangingFavorite = false.obs;
  final RxInt changingFavoriteProductId = 0.obs;
  final RxString favoriteActionErrorMessage = ''.obs;

  final RxBool isLoadingCart = false.obs;
  final RxString cartErrorMessage = ''.obs;
  final RxList<CustomerCartItem> cartItems = <CustomerCartItem>[].obs;
  final RxnInt cartId = RxnInt();
  final RxDouble cartTotal = 0.0.obs;

  final RxBool isAddingCartItem = false.obs;
  final RxInt addingCartProductId = 0.obs;
  final RxString addCartItemErrorMessage = ''.obs;

  final RxBool isUpdatingCartItem = false.obs;
  final RxInt updatingCartItemId = 0.obs;
  final RxString updateCartItemErrorMessage = ''.obs;

  final RxBool isRemovingCartItem = false.obs;
  final RxInt removingCartItemId = 0.obs;
  final RxString removeCartItemErrorMessage = ''.obs;

  bool get hasMoreFavoriteProducts {
    return favoriteProductsCurrentPage.value < favoriteProductsLastPage.value;
  }

  int get cartItemsCount {
    return cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  int get cartDistinctProductsCount {
    return cartItems.length;
  }

  bool isFavorite(int productId) {
    return favoriteProductIds.contains(productId);
  }

  bool isInCart(int productId) {
    return cartItems.any((item) => item.productId == productId);
  }

  CustomerCartItem? findCartItemByProductId(int productId) {
    try {
      return cartItems.firstWhere((item) => item.productId == productId);
    } catch (_) {
      return null;
    }
  }

  CustomerCartItem? findCartItemById(int cartItemId) {
    try {
      return cartItems.firstWhere((item) => item.id == cartItemId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> fetchFavoriteProducts({
    bool refresh = false,
    int page = 1,
  }) async {
    try {
      if (refresh) {
        favoriteProductsCurrentPage.value = 1;
        favoriteProductsLastPage.value = 1;
        favoriteProductsPerPage.value = 10;
        favoriteProductsTotal.value = 0;
        favoriteProducts.clear();
        favoriteProductIds.clear();
      }

      isLoadingFavorites.value = true;
      favoriteProductsErrorMessage.value = '';

      final result = await _customerRepository.getFavoriteProducts(page: page);

      favoriteProducts.assignAll(result.products);

      favoriteProductIds.assignAll(
        result.products.map((product) => product.id).where((id) => id > 0),
      );

      favoriteProductsCurrentPage.value = result.currentPage;
      favoriteProductsLastPage.value = result.lastPage;
      favoriteProductsPerPage.value = result.perPage;
      favoriteProductsTotal.value = result.total;

      debugPrint('========== FAVORITE PRODUCTS LOADED ==========');
      debugPrint('Count: ${favoriteProducts.length}');
      debugPrint('IDs: ${favoriteProductIds.toList()}');
      debugPrint('Current Page: ${favoriteProductsCurrentPage.value}');
      debugPrint('Last Page: ${favoriteProductsLastPage.value}');
      debugPrint('==============================================');

      return true;
    } catch (e) {
      favoriteProductsErrorMessage.value = e.toString().replaceFirst(
        'Exception: ',
        '',
      );

      debugPrint('========== GET FAVORITE PRODUCTS ERROR ==========');
      debugPrint(favoriteProductsErrorMessage.value);
      debugPrint('=================================================');

      return false;
    } finally {
      isLoadingFavorites.value = false;
    }
  }

  Future<bool> loadMoreFavoriteProducts() async {
    if (isLoadingMoreFavorites.value || !hasMoreFavoriteProducts) {
      return false;
    }

    try {
      isLoadingMoreFavorites.value = true;
      favoriteProductsErrorMessage.value = '';

      final nextPage = favoriteProductsCurrentPage.value + 1;

      final result = await _customerRepository.getFavoriteProducts(
        page: nextPage,
      );

      favoriteProducts.addAll(result.products);

      for (final product in result.products) {
        if (product.id > 0 && !favoriteProductIds.contains(product.id)) {
          favoriteProductIds.add(product.id);
        }
      }

      favoriteProductsCurrentPage.value = result.currentPage;
      favoriteProductsLastPage.value = result.lastPage;
      favoriteProductsPerPage.value = result.perPage;
      favoriteProductsTotal.value = result.total;

      debugPrint('========== MORE FAVORITE PRODUCTS LOADED ==========');
      debugPrint('Added Count: ${result.products.length}');
      debugPrint('Total Loaded: ${favoriteProducts.length}');
      debugPrint('Current Page: ${favoriteProductsCurrentPage.value}');
      debugPrint('===================================================');

      return true;
    } catch (e) {
      favoriteProductsErrorMessage.value = e.toString().replaceFirst(
        'Exception: ',
        '',
      );

      debugPrint('========== LOAD MORE FAVORITES ERROR ==========');
      debugPrint(favoriteProductsErrorMessage.value);
      debugPrint('===============================================');

      return false;
    } finally {
      isLoadingMoreFavorites.value = false;
    }
  }

  Future<bool> addToFavorites({
    required int productId,
    ProductModel? product,
  }) async {
    try {
      if (productId <= 0) {
        throw Exception('معرّف المنتج غير صالح');
      }

      isChangingFavorite.value = true;
      changingFavoriteProductId.value = productId;
      favoriteActionErrorMessage.value = '';

      final response = await _customerRepository.addToFavorites(
        productId: productId,
      );

      if (!favoriteProductIds.contains(productId)) {
        favoriteProductIds.add(productId);
      }

      if (product != null &&
          !favoriteProducts.any((item) => item.id == product.id)) {
        favoriteProducts.insert(0, product);
      }

      debugPrint('========== PRODUCT ADDED TO FAVORITES ==========');
      debugPrint(response.toString());
      debugPrint('Product ID: $productId');
      debugPrint('================================================');

      return true;
    } catch (e) {
      favoriteActionErrorMessage.value = e.toString().replaceFirst(
        'Exception: ',
        '',
      );

      debugPrint('========== ADD FAVORITE ERROR ==========');
      debugPrint(favoriteActionErrorMessage.value);
      debugPrint('========================================');

      return false;
    } finally {
      isChangingFavorite.value = false;
      changingFavoriteProductId.value = 0;
    }
  }

  Future<bool> removeFromFavorites({required int productId}) async {
    try {
      if (productId <= 0) {
        throw Exception('معرّف المنتج غير صالح');
      }

      isChangingFavorite.value = true;
      changingFavoriteProductId.value = productId;
      favoriteActionErrorMessage.value = '';

      final response = await _customerRepository.removeFromFavorites(
        productId: productId,
      );

      favoriteProductIds.remove(productId);
      favoriteProducts.removeWhere((product) => product.id == productId);

      debugPrint('========== PRODUCT REMOVED FROM FAVORITES ==========');
      debugPrint(response.toString());
      debugPrint('Product ID: $productId');
      debugPrint('====================================================');

      return true;
    } catch (e) {
      favoriteActionErrorMessage.value = e.toString().replaceFirst(
        'Exception: ',
        '',
      );

      debugPrint('========== REMOVE FAVORITE ERROR ==========');
      debugPrint(favoriteActionErrorMessage.value);
      debugPrint('===========================================');

      return false;
    } finally {
      isChangingFavorite.value = false;
      changingFavoriteProductId.value = 0;
    }
  }

  Future<bool> toggleFavorite({required ProductModel product}) async {
    final productId = product.id;

    if (isFavorite(productId)) {
      return removeFromFavorites(productId: productId);
    }

    return addToFavorites(productId: productId, product: product);
  }

  Future<bool> fetchCart() async {
    try {
      isLoadingCart.value = true;
      cartErrorMessage.value = '';

      final result = await _customerRepository.getCart();

      cartId.value = result.cartId;
      cartItems.assignAll(result.items);
      cartTotal.value = result.total;

      debugPrint('========== CART LOADED ==========');
      debugPrint('Cart ID: ${cartId.value}');
      debugPrint('Items Count: ${cartItems.length}');
      debugPrint('Total: ${cartTotal.value}');
      debugPrint('===============================');

      return true;
    } catch (e) {
      cartErrorMessage.value = e.toString().replaceFirst('Exception: ', '');

      debugPrint('========== GET CART ERROR ==========');
      debugPrint(cartErrorMessage.value);
      debugPrint('====================================');

      return false;
    } finally {
      isLoadingCart.value = false;
    }
  }

  Future<bool> addCartItem({required int productId, int quantity = 1}) async {
    try {
      if (productId <= 0) {
        throw Exception('معرّف المنتج غير صالح');
      }

      if (quantity <= 0) {
        throw Exception('الكمية يجب أن تكون أكبر من صفر');
      }

      isAddingCartItem.value = true;
      addingCartProductId.value = productId;
      addCartItemErrorMessage.value = '';

      final item = await _customerRepository.addCartItem(
        productId: productId,
        quantity: quantity,
      );

      _upsertCartItem(item);
      _recalculateCartTotal();

      debugPrint('========== CART ITEM ADDED ==========');
      debugPrint('Cart Item ID: ${item.id}');
      debugPrint('Product ID: ${item.productId}');
      debugPrint('Quantity: ${item.quantity}');
      debugPrint('=====================================');

      return true;
    } catch (e) {
      addCartItemErrorMessage.value = e.toString().replaceFirst(
        'Exception: ',
        '',
      );

      debugPrint('========== ADD CART ITEM ERROR ==========');
      debugPrint(addCartItemErrorMessage.value);
      debugPrint('=========================================');

      return false;
    } finally {
      isAddingCartItem.value = false;
      addingCartProductId.value = 0;
    }
  }

  Future<bool> updateCartItem({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      if (cartItemId <= 0) {
        throw Exception('معرّف عنصر السلة غير صالح');
      }

      if (quantity <= 0) {
        throw Exception('الكمية يجب أن تكون أكبر من صفر');
      }

      isUpdatingCartItem.value = true;
      updatingCartItemId.value = cartItemId;
      updateCartItemErrorMessage.value = '';

      final item = await _customerRepository.updateCartItem(
        cartItemId: cartItemId,
        quantity: quantity,
      );

      _upsertCartItem(item);
      _recalculateCartTotal();

      debugPrint('========== CART ITEM UPDATED ==========');
      debugPrint('Cart Item ID: ${item.id}');
      debugPrint('Product ID: ${item.productId}');
      debugPrint('Quantity: ${item.quantity}');
      debugPrint('======================================');

      return true;
    } catch (e) {
      updateCartItemErrorMessage.value = e.toString().replaceFirst(
        'Exception: ',
        '',
      );

      debugPrint('========== UPDATE CART ITEM ERROR ==========');
      debugPrint(updateCartItemErrorMessage.value);
      debugPrint('============================================');

      return false;
    } finally {
      isUpdatingCartItem.value = false;
      updatingCartItemId.value = 0;
    }
  }

  Future<bool> removeCartItem({required int cartItemId}) async {
    try {
      if (cartItemId <= 0) {
        throw Exception('معرّف عنصر السلة غير صالح');
      }

      isRemovingCartItem.value = true;
      removingCartItemId.value = cartItemId;
      removeCartItemErrorMessage.value = '';

      final response = await _customerRepository.removeCartItem(
        cartItemId: cartItemId,
      );

      cartItems.removeWhere((item) => item.id == cartItemId);
      _recalculateCartTotal();

      debugPrint('========== CART ITEM REMOVED ==========');
      debugPrint(response.toString());
      debugPrint('Cart Item ID: $cartItemId');
      debugPrint('======================================');

      return true;
    } catch (e) {
      removeCartItemErrorMessage.value = e.toString().replaceFirst(
        'Exception: ',
        '',
      );

      debugPrint('========== REMOVE CART ITEM ERROR ==========');
      debugPrint(removeCartItemErrorMessage.value);
      debugPrint('============================================');

      return false;
    } finally {
      isRemovingCartItem.value = false;
      removingCartItemId.value = 0;
    }
  }

  void markProductAsFavorite(ProductModel product) {
    if (product.id <= 0) return;

    if (!favoriteProductIds.contains(product.id)) {
      favoriteProductIds.add(product.id);
    }

    if (!favoriteProducts.any((item) => item.id == product.id)) {
      favoriteProducts.insert(0, product);
    }
  }

  void unmarkProductAsFavorite(int productId) {
    favoriteProductIds.remove(productId);
    favoriteProducts.removeWhere((product) => product.id == productId);
  }

  void _upsertCartItem(CustomerCartItem item) {
    final index = cartItems.indexWhere((cartItem) => cartItem.id == item.id);

    if (index >= 0) {
      cartItems[index] = item;
      return;
    }

    final productIndex = cartItems.indexWhere(
      (cartItem) => cartItem.productId == item.productId,
    );

    if (productIndex >= 0) {
      cartItems[productIndex] = item;
      return;
    }

    cartItems.insert(0, item);
  }

  void _recalculateCartTotal() {
    cartTotal.value = cartItems.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
  }

  void clearFavoritesState() {
    isLoadingFavorites.value = false;
    isLoadingMoreFavorites.value = false;
    favoriteProductsErrorMessage.value = '';

    favoriteProducts.clear();
    favoriteProductIds.clear();

    favoriteProductsCurrentPage.value = 1;
    favoriteProductsLastPage.value = 1;
    favoriteProductsPerPage.value = 10;
    favoriteProductsTotal.value = 0;
  }

  void clearFavoriteActionState() {
    isChangingFavorite.value = false;
    changingFavoriteProductId.value = 0;
    favoriteActionErrorMessage.value = '';
  }

  void clearCartState() {
    isLoadingCart.value = false;
    cartErrorMessage.value = '';

    cartItems.clear();
    cartId.value = null;
    cartTotal.value = 0.0;
  }

  void clearCartActionState() {
    isAddingCartItem.value = false;
    addingCartProductId.value = 0;
    addCartItemErrorMessage.value = '';

    isUpdatingCartItem.value = false;
    updatingCartItemId.value = 0;
    updateCartItemErrorMessage.value = '';

    isRemovingCartItem.value = false;
    removingCartItemId.value = 0;
    removeCartItemErrorMessage.value = '';
  }
}
