import 'package:get/get.dart';

import 'package:shamstore/features/orders/repositories/order_repository.dart';

class OrderController extends GetxController {
  OrderController({OrderRepository? repository})
    : _repository = repository ?? OrderRepository();

  final OrderRepository _repository;

  final RxBool isPlacingOrder = false.obs;

  final Rxn<PlaceOrderResult> lastOrder = Rxn<PlaceOrderResult>();

  final RxnString errorMessage = RxnString();

  Future<bool> placeOrder({
    required int productId,
    required int quantity,
    required String phone,
    required String address,
  }) async {
    // منع الضغط المتكرر وإنشاء أكثر من طلب.
    if (isPlacingOrder.value) {
      return false;
    }

    errorMessage.value = null;
    lastOrder.value = null;
    isPlacingOrder.value = true;

    try {
      final result = await _repository.placeOrder(
        productId: productId,
        quantity: quantity,
        phone: phone,
        address: address,
      );

      lastOrder.value = result;

      return true;
    } catch (error) {
      errorMessage.value = _cleanErrorMessage(error);

      return false;
    } finally {
      isPlacingOrder.value = false;
    }
  }

  void clearError() {
    errorMessage.value = null;
  }

  void clearLastOrder() {
    lastOrder.value = null;
  }

  String _cleanErrorMessage(Object error) {
    final message = error.toString().trim();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length).trim();
    }

    if (message.isEmpty) {
      return 'حدث خطأ غير متوقع أثناء إنشاء الطلب';
    }

    return message;
  }
}
