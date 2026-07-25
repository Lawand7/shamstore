import 'package:get/get.dart';

import 'package:shamstore/features/seller/models/seller_order_model.dart';
import 'package:shamstore/features/seller/repositories/seller_orders_repository.dart';

class SellerOrdersController extends GetxController {
  SellerOrdersController({SellerOrdersRepository? repository})
    : _repository = repository ?? SellerOrdersRepository();

  final SellerOrdersRepository _repository;

  final RxList<SellerOrderModel> orders = <SellerOrderModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedStatus = 'pending'.obs;

  final RxBool isRejectingOrder = false.obs;
  final RxInt rejectingOrderId = 0.obs;

  final RxBool isShippingOrder = false.obs;
  final RxInt shippingOrderId = 0.obs;

  final RxString lastActionMessage = ''.obs;
  final RxString lastActionError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<bool> fetchOrders({String? status}) async {
    if (isLoading.value) {
      return false;
    }

    final String requestedStatus = (status ?? selectedStatus.value)
        .trim()
        .toLowerCase();

    if (!_isValidStatus(requestedStatus)) {
      errorMessage.value = 'حالة الطلب غير صحيحة';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final List<SellerOrderModel> result = await _repository.getOrders(
        status: requestedStatus,
      );

      selectedStatus.value = requestedStatus;
      orders.assignAll(result);

      return true;
    } catch (error) {
      orders.clear();
      errorMessage.value = _cleanErrorMessage(error);

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectStatus(String status) async {
    final String normalizedStatus = status.trim().toLowerCase();

    if (!_isValidStatus(normalizedStatus)) {
      errorMessage.value = 'حالة الطلب غير صحيحة';
      return;
    }

    if (normalizedStatus == selectedStatus.value && orders.isNotEmpty) {
      return;
    }

    await fetchOrders(status: normalizedStatus);
  }

  Future<void> refreshOrders() async {
    await fetchOrders(status: selectedStatus.value);
  }

  Future<bool> rejectOrder({required int orderId}) async {
    if (orderId <= 0) {
      lastActionError.value = 'معرّف الطلب غير صالح';
      return false;
    }

    if (isRejectingOrder.value || isShippingOrder.value) {
      return false;
    }

    isRejectingOrder.value = true;
    rejectingOrderId.value = orderId;
    lastActionMessage.value = '';
    lastActionError.value = '';

    try {
      final String message = await _repository.rejectOrder(orderId: orderId);

      orders.removeWhere((SellerOrderModel order) => order.id == orderId);

      lastActionMessage.value = message.isEmpty
          ? 'تم رفض الطلب بنجاح'
          : message;

      return true;
    } catch (error) {
      lastActionError.value = _cleanErrorMessage(error);

      return false;
    } finally {
      isRejectingOrder.value = false;
      rejectingOrderId.value = 0;
    }
  }

  Future<bool> shipOrder({
    required int orderId,
    required String period,
    required String imagePath,
  }) async {
    if (orderId <= 0) {
      lastActionError.value = 'معرّف الطلب غير صالح';
      return false;
    }

    final String normalizedPeriod = period.trim();

    final String normalizedImagePath = imagePath.trim();

    if (normalizedPeriod.isEmpty) {
      lastActionError.value = 'مدة الشحن مطلوبة';
      return false;
    }

    if (normalizedImagePath.isEmpty) {
      lastActionError.value = 'صورة إثبات الشحن مطلوبة';
      return false;
    }

    if (isShippingOrder.value || isRejectingOrder.value) {
      return false;
    }

    isShippingOrder.value = true;
    shippingOrderId.value = orderId;
    lastActionMessage.value = '';
    lastActionError.value = '';

    try {
      final String message = await _repository.shipOrder(
        orderId: orderId,
        period: normalizedPeriod,
        imagePath: normalizedImagePath,
      );

      lastActionMessage.value = message.isEmpty
          ? 'تم إرسال معلومات الشحن بنجاح'
          : message;

      await _refreshAfterSuccessfulAction();

      return true;
    } catch (error) {
      lastActionError.value = _cleanErrorMessage(error);

      return false;
    } finally {
      isShippingOrder.value = false;
      shippingOrderId.value = 0;
    }
  }

  Future<void> _refreshAfterSuccessfulAction() async {
    if (isLoading.value) {
      return;
    }

    final String currentStatus = selectedStatus.value;

    try {
      final List<SellerOrderModel> result = await _repository.getOrders(
        status: currentStatus,
      );

      orders.assignAll(result);
      errorMessage.value = '';
    } catch (_) {
      // نجاح الإجراء أهم من فشل التحديث اللاحق.
      // تبقى القائمة الحالية كما هي ويمكن للمستخدم تحديثها يدوياً.
    }
  }

  bool isRejecting({required int orderId}) {
    return isRejectingOrder.value && rejectingOrderId.value == orderId;
  }

  bool isShipping({required int orderId}) {
    return isShippingOrder.value && shippingOrderId.value == orderId;
  }

  bool isActionRunning({required int orderId}) {
    return isRejecting(orderId: orderId) || isShipping(orderId: orderId);
  }

  bool get isPendingSelected {
    return selectedStatus.value == 'pending';
  }

  bool get isCompleteSelected {
    return selectedStatus.value == 'complete';
  }

  int get ordersCount {
    return orders.length;
  }

  bool _isValidStatus(String status) {
    return status == 'pending' || status == 'complete';
  }

  String _cleanErrorMessage(Object error) {
    final String message = error.toString().trim();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length).trim();
    }

    if (message.isEmpty) {
      return 'حدث خطأ غير متوقع أثناء تنفيذ العملية';
    }

    return message;
  }
}
