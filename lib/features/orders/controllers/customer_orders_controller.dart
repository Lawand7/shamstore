import 'package:get/get.dart';

import 'package:shamstore/features/orders/models/customer_order_model.dart';
import 'package:shamstore/features/orders/repositories/customer_orders_repository.dart';

class CustomerOrdersController extends GetxController {
  CustomerOrdersController({CustomerOrdersRepository? repository})
    : _repository = repository ?? CustomerOrdersRepository();

  final CustomerOrdersRepository _repository;

  final RxList<CustomerOrderModel> orders = <CustomerOrderModel>[].obs;

  final RxBool isLoading = false.obs;

  final RxString errorMessage = ''.obs;

  final RxString selectedStatus = 'pending'.obs;

  final RxString lastActionMessage = ''.obs;

  final RxString lastActionError = ''.obs;

  /*
   * نخزن العمليات الجارية بهذه الصيغة:
   *
   * confirm:12
   * report:12
   * rating:5
   *
   * هذا يمنع تنفيذ نفس العملية أكثر من مرة
   * عند الضغط السريع على الزر.
   */
  final RxList<String> runningActions = <String>[].obs;

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
      final List<CustomerOrderModel> result = await _repository.getOrders(
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

  Future<String?> confirmOrder({required int orderId}) async {
    final String actionKey = _buildActionKey('confirm', orderId);

    if (!_startAction(actionKey)) {
      return null;
    }

    _clearActionMessages();

    try {
      final String message = await _repository.confirmOrder(orderId: orderId);

      lastActionMessage.value = message;

      /*
       * بعد تأكيد الاستلام يتحول الطلب من pending
       * إلى complete، لذلك نحذفه فوراً من قائمة pending.
       */
      if (selectedStatus.value == 'pending') {
        orders.removeWhere((order) => order.id == orderId);
      } else {
        await refreshOrders();
      }

      return message;
    } catch (error) {
      lastActionError.value = _cleanErrorMessage(error);

      return null;
    } finally {
      _finishAction(actionKey);
    }
  }

  Future<String?> reportOrder({
    required int orderId,
    required String description,
  }) async {
    final String actionKey = _buildActionKey('report', orderId);

    if (!_startAction(actionKey)) {
      return null;
    }

    _clearActionMessages();

    try {
      final String message = await _repository.reportOrder(
        orderId: orderId,
        description: description,
      );

      lastActionMessage.value = message;

      return message;
    } catch (error) {
      lastActionError.value = _cleanErrorMessage(error);

      return null;
    } finally {
      _finishAction(actionKey);
    }
  }

  Future<String?> rateSeller({
    required int sellerId,
    required int value,
  }) async {
    final String actionKey = _buildActionKey('rating', sellerId);

    if (!_startAction(actionKey)) {
      return null;
    }

    _clearActionMessages();

    try {
      final String message = await _repository.rateSeller(
        sellerId: sellerId,
        value: value,
      );

      lastActionMessage.value = message;

      return message;
    } catch (error) {
      lastActionError.value = _cleanErrorMessage(error);

      return null;
    } finally {
      _finishAction(actionKey);
    }
  }

  bool isConfirming(int orderId) {
    return runningActions.contains(_buildActionKey('confirm', orderId));
  }

  bool isReporting(int orderId) {
    return runningActions.contains(_buildActionKey('report', orderId));
  }

  bool isRatingSeller(int sellerId) {
    return runningActions.contains(_buildActionKey('rating', sellerId));
  }

  bool isAnyActionRunningForOrder(CustomerOrderModel order) {
    return isConfirming(order.id) ||
        isReporting(order.id) ||
        isRatingSeller(order.sellerId);
  }

  void clearActionMessages() {
    _clearActionMessages();
  }

  bool _startAction(String actionKey) {
    if (runningActions.contains(actionKey)) {
      return false;
    }

    runningActions.add(actionKey);

    return true;
  }

  void _finishAction(String actionKey) {
    runningActions.remove(actionKey);
  }

  String _buildActionKey(String action, int id) {
    return '$action:$id';
  }

  bool _isValidStatus(String status) {
    return status == 'pending' || status == 'complete';
  }

  void _clearActionMessages() {
    lastActionMessage.value = '';
    lastActionError.value = '';
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
