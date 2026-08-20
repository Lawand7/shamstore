import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/core/constants/api_constants.dart';
import 'package:shamstore/features/orders/controllers/customer_orders_controller.dart';
import 'package:shamstore/features/orders/models/customer_order_model.dart';
import 'package:shamstore/screen/notifications_page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_feedback.dart';
import 'package:shamstore/utils/app_localizations.dart';
import 'package:shamstore/utils/localized_content.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  static const String _controllerTag = 'my-orders-page';

  late final CustomerOrdersController _controller;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<CustomerOrdersController>(tag: _controllerTag)) {
      _controller = Get.find<CustomerOrdersController>(tag: _controllerTag);
    } else {
      _controller = Get.put(CustomerOrdersController(), tag: _controllerTag);
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<CustomerOrdersController>(tag: _controllerTag)) {
      Get.delete<CustomerOrdersController>(tag: _controllerTag, force: true);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppTheme.darkBackground
          : AppTheme.background,
      appBar: _buildAppBar(context, isDarkMode),
      body: SafeArea(
        child: Column(
          children: [
            _buildStatusSelector(isDarkMode),
            Expanded(child: _buildOrdersBody(isDarkMode)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
      elevation: 0,
      centerTitle: true,
      title: Text(
        AppLocalizations.of(context).translate('My Orders'),
        style: const TextStyle(
          color: AppTheme.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward, color: AppTheme.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppTheme.white),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            );

            if (mounted) {
              await _controller.refreshOrders();
            }
          },
        ),
      ],
    );
  }

  Widget _buildStatusSelector(bool isDarkMode) {
    return Obx(() {
      final String selectedStatus = _controller.selectedStatus.value;

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDarkMode ? Colors.transparent : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatusButton(
                label: _text('المكتملة', 'Completed'),
                status: 'complete',
                isSelected: selectedStatus == 'complete',
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildStatusButton(
                label: _text('قيد التنفيذ', 'In progress'),
                status: 'pending',
                isSelected: selectedStatus == 'pending',
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatusButton({
    required String label,
    required String status,
    required bool isSelected,
    required bool isDarkMode,
  }) {
    final Color activeColor = isDarkMode
        ? AppTheme.selectedBorder
        : AppTheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          _controller.selectStatus(status);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? AppTheme.white
                  : isDarkMode
                  ? AppTheme.textSecondary
                  : AppTheme.textGrey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersBody(bool isDarkMode) {
    return Obx(() {
      final bool isLoading = _controller.isLoading.value;

      final String errorMessage = _controller.errorMessage.value;

      final List<CustomerOrderModel> orders = _controller.orders.toList();

      if (isLoading && orders.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (errorMessage.isNotEmpty && orders.isEmpty) {
        return _buildErrorState(errorMessage, isDarkMode);
      }

      if (orders.isEmpty) {
        return _buildEmptyState(isDarkMode);
      }

      return Stack(
        children: [
          RefreshIndicator(
            onRefresh: _controller.refreshOrders,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(orders[index], isDarkMode);
              },
            ),
          ),
          if (isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      );
    });
  }

  Widget _buildEmptyState(bool isDarkMode) {
    final bool isPending = _controller.selectedStatus.value == 'pending';

    return RefreshIndicator(
      onRefresh: _controller.refreshOrders,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.52,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppTheme.cardBackground
                        : AppTheme.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPending
                        ? Icons.local_shipping_outlined
                        : Icons.inventory_2_outlined,
                    size: 44,
                    color: isDarkMode
                        ? AppTheme.textSecondary
                        : AppTheme.textGrey,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  isPending
                      ? _text(
                          'لا توجد طلبات قيد التنفيذ',
                          'No orders in progress',
                        )
                      : _text('لا توجد طلبات مكتملة', 'No completed orders'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? AppTheme.textPrimary
                        : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isPending
                      ? _text(
                          'ستظهر هنا الطلبات التي تنتظر تجهيز البائع أو أصبحت قيد التوصيل.',
                          'Orders awaiting seller preparation or currently in delivery will appear here.',
                        )
                      : _text(
                          'ستظهر هنا الطلبات التي تم تأكيد استلامها.',
                          'Orders whose receipt has been confirmed will appear here.',
                        ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDarkMode
                        ? AppTheme.textSecondary
                        : AppTheme.textGrey,
                  ),
                ),
                const SizedBox(height: 14),
                TextButton.icon(
                  onPressed: _controller.refreshOrders,
                  icon: const Icon(Icons.refresh),
                  label: Text(_text('تحديث الطلبات', 'Refresh orders')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, bool isDarkMode) {
    return RefreshIndicator(
      onRefresh: _controller.refreshOrders,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.52,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 58, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  _text('تعذر تحميل الطلبات', 'Unable to load orders'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? AppTheme.textPrimary
                        : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  LocalizedContent.message(context, message, isError: true),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDarkMode
                        ? AppTheme.textSecondary
                        : AppTheme.textGrey,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _controller.refreshOrders,
                  icon: const Icon(Icons.refresh),
                  label: Text(_text('إعادة المحاولة', 'Try again')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? AppTheme.selectedBorder
                        : AppTheme.primary,
                    foregroundColor: AppTheme.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(CustomerOrderModel order, bool isDarkMode) {
    final Color activeColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    final String location = order.address.isNotEmpty
        ? order.address
        : LocalizedContent.value(context, order.governorate);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.transparent : AppTheme.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppTheme.inputFieldBg
                      : AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  order.isCompleted
                      ? Icons.inventory_2_outlined
                      : order.isInDelivery
                      ? Icons.local_shipping_outlined
                      : Icons.schedule_rounded,
                  size: 32,
                  color: activeColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      order.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? AppTheme.textPrimary
                            : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'طلب رقم #${order.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? AppTheme.textSecondary
                            : AppTheme.textGrey,
                      ),
                    ),
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? AppTheme.textSecondary
                                    : AppTheme.textGrey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: isDarkMode
                                ? AppTheme.textSecondary
                                : AppTheme.textGrey,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(
            color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border,
            height: 1,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: _text('الكمية', 'Quantity'),
            value: order.quantity.toString(),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            label: _text('الإجمالي', 'Total'),
            value:
                '${_formatPrice(order.totalPrice)} '
                '${AppLocalizations.of(context).translate('SP')}',
            isDarkMode: isDarkMode,
            valueColor: activeColor,
          ),
          if (order.phone.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              label: _text('رقم الهاتف', 'Phone number'),
              value: order.phone,
              isDarkMode: isDarkMode,
            ),
          ],
          if (order.isInDelivery && order.shippingPeriod.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              label: _text('مدة أو موعد التوصيل', 'Delivery time'),
              value: order.shippingPeriod,
              isDarkMode: isDarkMode,
            ),
          ],
          if (order.shippingImage.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildShippingProof(order, isDarkMode),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: _buildStatusBadge(order, isDarkMode),
          ),
          if (order.isPending) ...[
            const SizedBox(height: 10),
            _buildShippingStageNotice(order, isDarkMode),
          ],
          const SizedBox(height: 12),
          Divider(
            color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border,
            height: 1,
          ),
          const SizedBox(height: 10),
          _buildOrderActions(order, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildShippingProof(CustomerOrderModel order, bool isDarkMode) {
    final String imageUrl = _normalizeShippingImageUrl(order.shippingImage);

    final Color borderColor = isDarkMode
        ? AppTheme.inputFieldBg
        : AppTheme.border;

    final Color backgroundColor = isDarkMode
        ? AppTheme.inputFieldBg
        : AppTheme.background;

    final Color primaryColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              _text('صورة إثبات الشحن', 'Shipping proof image'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.receipt_long_outlined, size: 17, color: primaryColor),
          ],
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: imageUrl.isEmpty
                ? null
                : () {
                    _showShippingImageDialog(
                      imageUrl: imageUrl,
                      isDarkMode: isDarkMode,
                    );
                  },
            child: Container(
              width: double.infinity,
              height: 155,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl.isEmpty
                  ? Center(
                      child: Text(
                        _text(
                          'مسار صورة الشحن غير صالح',
                          'The shipping image path is invalid',
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode
                              ? AppTheme.textSecondary
                              : AppTheme.textGrey,
                        ),
                      ),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder:
                              (
                                BuildContext context,
                                Widget child,
                                ImageChunkEvent? loadingProgress,
                              ) {
                                if (loadingProgress == null) {
                                  return child;
                                }

                                return Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: primaryColor,
                                    ),
                                  ),
                                );
                              },
                          errorBuilder:
                              (
                                BuildContext context,
                                Object error,
                                StackTrace? stackTrace,
                              ) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.broken_image_outlined,
                                          size: 38,
                                          color: isDarkMode
                                              ? AppTheme.textSecondary
                                              : AppTheme.textGrey,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _text(
                                            'تعذر تحميل صورة إثبات الشحن',
                                            'Unable to load the shipping proof image',
                                          ),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDarkMode
                                                ? AppTheme.textSecondary
                                                : AppTheme.textGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                        ),
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.zoom_in_rounded,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _text('اضغط للتكبير', 'Tap to enlarge'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          _text(
            'هذه الصورة أرسلها البائع كإثبات للشحن، ولا تعني وحدها أنك استلمت المنتج.',
            'The seller provided this image as shipping proof. It does not confirm that you received the product.',
          ),
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 10.5,
            height: 1.45,
            color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
          ),
        ),
      ],
    );
  }

  Future<void> _showShippingImageDialog({
    required String imageUrl,
    required bool isDarkMode,
  }) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.82,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.antiAlias,
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    loadingBuilder:
                        (
                          BuildContext context,
                          Widget child,
                          ImageChunkEvent? loadingProgress,
                        ) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return const SizedBox(
                            height: 360,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return SizedBox(
                            height: 360,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'تعذر فتح صورة إثبات الشحن',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? AppTheme.textPrimary
                                        : AppTheme.textDark,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.62),
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'إغلاق',
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _normalizeShippingImageUrl(String value) {
    final String raw = value.trim();

    if (raw.isEmpty) {
      return '';
    }

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    final String serverBase = ApiConstants.baseUrl
        .replaceFirst(RegExp(r'/api/?$'), '')
        .replaceAll(RegExp(r'/$'), '');

    final String cleanPath = raw
        .replaceAll(r'\', '/')
        .replaceFirst(RegExp(r'^/+'), '')
        .replaceFirst(RegExp(r'^public/storage/'), '')
        .replaceFirst(RegExp(r'^storage/'), '');

    return '$serverBase/storage/$cleanPath';
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required bool isDarkMode,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color:
                valueColor ??
                (isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(CustomerOrderModel order, bool isDarkMode) {
    late final Color statusColor;
    late final String label;
    late final IconData icon;

    if (order.isCompleted) {
      statusColor = Colors.green;
      label = _text('مكتمل', 'Completed');
      icon = Icons.check_circle_outline;
    } else if (order.isInDelivery) {
      statusColor = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;
      label = _text('قيد التوصيل', 'In delivery');
      icon = Icons.local_shipping_outlined;
    } else {
      statusColor = Colors.orange;
      label = _text('بانتظار البائع', 'Awaiting seller');
      icon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: isDarkMode ? 0.16 : 0.11),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 5),
          Icon(icon, size: 15, color: statusColor),
        ],
      ),
    );
  }

  Widget _buildShippingStageNotice(CustomerOrderModel order, bool isDarkMode) {
    final bool isInDelivery = order.isInDelivery;

    final Color noticeColor = isInDelivery
        ? (isDarkMode ? AppTheme.accentBlue : AppTheme.primary)
        : Colors.orange;

    final String message = isInDelivery
        ? _text(
            'أرسل البائع بيانات الشحن. أكد الاستلام فقط بعد وصول الطلب إليك فعلياً.',
            'The seller sent the shipping details. Confirm receipt only after the order actually arrives.',
          )
        : _text(
            'الطلب بانتظار البائع لتجهيزه وإرسال صورة الشحن ومدة التوصيل.',
            'The order is waiting for the seller to prepare it and provide shipping proof and a delivery time.',
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: noticeColor.withValues(alpha: isDarkMode ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: noticeColor.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.5,
                color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            isInDelivery
                ? Icons.local_shipping_outlined
                : Icons.schedule_rounded,
            size: 18,
            color: noticeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderActions(CustomerOrderModel order, bool isDarkMode) {
    return Obx(() {
      final bool isReporting = _controller.isReporting(order.id);

      final bool isConfirming = _controller.isConfirming(order.id);

      final bool isRating = _controller.isRatingSeller(order.id);

      return Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: [
          _actionButton(
            label: _text('إبلاغ', 'Report'),
            icon: Icons.flag_outlined,
            color: Colors.red,
            isLoading: isReporting,
            onTap: isReporting
                ? null
                : () {
                    _showReportBottomSheet(order, isDarkMode);
                  },
          ),
          if (order.canRateSeller)
            _actionButton(
              label: _text('تقييم', 'Rate'),
              icon: Icons.star_border,
              color: Colors.orange,
              isLoading: isRating,
              onTap: isRating
                  ? null
                  : () {
                      _showRatingDialog(order, isDarkMode);
                    },
            ),
          if (order.canConfirmDelivery)
            _actionButton(
              label: _text('تأكيد الاستلام', 'Confirm receipt'),
              icon: Icons.check,
              color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
              isLoading: isConfirming,
              onTap: isConfirming
                  ? null
                  : () {
                      _confirmOrderDelivery(order, isDarkMode);
                    },
            ),
        ],
      );
    });
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: onTap == null ? 0.65 : 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              border: Border.all(color: color.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(20),
              color: color.withValues(alpha: 0.06),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 5),
                if (isLoading)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                else
                  Icon(icon, size: 14, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmOrderDelivery(
    CustomerOrderModel order,
    bool isDarkMode,
  ) async {
    if (!order.canConfirmDelivery) {
      _showErrorMessage(
        'لا يمكن تأكيد الاستلام قبل أن يرسل البائع بيانات الشحن كاملة',
      );
      return;
    }

    final bool? shouldConfirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDarkMode
              ? AppTheme.cardBackground
              : AppTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            _text('تأكيد استلام الطلب', 'Confirm order receipt'),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            ),
          ),
          content: Text(
            _text(
              'هل استلمت الطلب رقم #${order.id} بالفعل؟\n\nلا تؤكد قبل استلام المنتج وفحصه. بعد التأكيد سيتم تحويل قيمة الطلب إلى محفظة البائع.',
              'Have you received order #${order.id}?\n\nDo not confirm before receiving and inspecting the product. Once confirmed, the order amount will be transferred to the seller wallet.',
            ),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(_text('إلغاء', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode
                    ? AppTheme.selectedBorder
                    : AppTheme.primary,
                foregroundColor: AppTheme.white,
              ),
              child: Text(_text('تأكيد الاستلام', 'Confirm receipt')),
            ),
          ],
        );
      },
    );

    if (shouldConfirm != true || !mounted) {
      return;
    }

    if (_controller.isLoading.value) {
      _showErrorMessage('انتظر حتى ينتهي تحديث الطلبات ثم أعد المحاولة');
      return;
    }

    await _controller.refreshOrders();

    if (!mounted) {
      return;
    }

    if (_controller.errorMessage.value.isNotEmpty) {
      _showErrorMessage(
        'تعذر التحقق من حالة الطلب الحالية. حدّث الصفحة ثم أعد المحاولة.',
      );
      return;
    }

    CustomerOrderModel? latestOrder;

    for (final CustomerOrderModel currentOrder in _controller.orders) {
      if (currentOrder.id == order.id) {
        latestOrder = currentOrder;
        break;
      }
    }

    if (latestOrder == null) {
      _showErrorMessage(
        'تغيرت حالة الطلب أو لم يعد موجوداً ضمن الطلبات قيد التنفيذ',
      );
      return;
    }

    if (!latestOrder.canConfirmDelivery) {
      _showErrorMessage(
        'بيانات الشحن غير مكتملة حتى الآن، لذلك لا يمكن تأكيد الاستلام',
      );
      return;
    }

    final String? message = await _controller.confirmOrder(
      orderId: latestOrder.id,
    );

    if (!mounted) {
      return;
    }

    if (message != null) {
      _showSuccessMessage(message);
      return;
    }

    _showErrorMessage(
      _controller.lastActionError.value.isNotEmpty
          ? _controller.lastActionError.value
          : 'فشل تأكيد استلام الطلب',
    );
  }

  Future<void> _showReportBottomSheet(
    CustomerOrderModel order,
    bool isDarkMode,
  ) async {
    final TextEditingController reportController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 22,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                    },
                    icon: Icon(
                      Icons.close,
                      color: isDarkMode
                          ? AppTheme.textSecondary
                          : AppTheme.textGrey,
                    ),
                  ),
                  Text(
                    _text('الإبلاغ عن مشكلة', 'Report a problem'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _text(
                  'الطلب #${order.id} - ${order.productName}',
                  'Order #${order.id} - ${order.productName}',
                ),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode
                      ? AppTheme.textSecondary
                      : AppTheme.textGrey,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reportController,
                maxLines: 4,
                minLines: 4,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                ),
                decoration: InputDecoration(
                  hintText: _text(
                    'اكتب تفاصيل المشكلة بشكل واضح...',
                    'Describe the problem clearly...',
                  ),
                  filled: true,
                  fillColor: isDarkMode
                      ? AppTheme.inputFieldBg
                      : AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: isDarkMode
                        ? BorderSide.none
                        : const BorderSide(color: AppTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: isDarkMode
                        ? BorderSide.none
                        : const BorderSide(color: AppTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Obx(() {
                final bool isSending = _controller.isReporting(order.id);

                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isSending
                        ? null
                        : () async {
                            final String description = reportController.text
                                .trim();

                            if (description.isEmpty) {
                              _showErrorMessage('يرجى كتابة تفاصيل المشكلة');
                              return;
                            }

                            final String? message = await _controller
                                .reportOrder(
                                  orderId: order.id,
                                  description: description,
                                );

                            if (!mounted) {
                              return;
                            }

                            if (message != null) {
                              if (sheetContext.mounted) {
                                Navigator.of(sheetContext).pop();
                              }

                              _showSuccessMessage(message);
                              return;
                            }

                            _showErrorMessage(
                              _controller.lastActionError.value.isNotEmpty
                                  ? _controller.lastActionError.value
                                  : 'فشل إرسال البلاغ',
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? AppTheme.selectedBorder
                          : AppTheme.primary,
                      foregroundColor: AppTheme.white,
                      disabledBackgroundColor: AppTheme.textGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.white,
                              ),
                            ),
                          )
                        : Text(
                            _text('إرسال إلى الإدارة', 'Send report'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );

    reportController.dispose();
  }

  Future<void> _showRatingDialog(
    CustomerOrderModel order,
    bool isDarkMode,
  ) async {
    if (order.sellerId <= 0) {
      _showErrorMessage('تعذر تحديد البائع المرتبط بهذا الطلب');
      return;
    }

    int selectedRating = 0;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDarkMode
                  ? AppTheme.cardBackground
                  : AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                _text('تقييم البائع', 'Rate seller'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    order.productName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode
                          ? AppTheme.textSecondary
                          : AppTheme.textGrey,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final int starValue = index + 1;

                      return IconButton(
                        onPressed: () {
                          setDialogState(() {
                            selectedRating = starValue;
                          });
                        },
                        icon: Icon(
                          starValue <= selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.orange,
                          size: 31,
                        ),
                      );
                    }),
                  ),
                  if (selectedRating > 0)
                    Text(
                      _text('$selectedRating من 5', '$selectedRating out of 5'),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? AppTheme.textSecondary
                            : AppTheme.textGrey,
                      ),
                    ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(_text('إلغاء', 'Cancel')),
                ),
                Obx(() {
                  final bool isSending = _controller.isRatingSeller(order.id);

                  return ElevatedButton(
                    onPressed: isSending
                        ? null
                        : () async {
                            if (selectedRating == 0) {
                              _showErrorMessage('يرجى اختيار عدد النجوم');
                              return;
                            }

                            final String? message = await _controller
                                .rateSeller(
                                  orderId: order.id,
                                  value: selectedRating,
                                );

                            if (!mounted) {
                              return;
                            }

                            if (message != null) {
                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                              }

                              _showSuccessMessage(message);
                              return;
                            }

                            _showErrorMessage(
                              _controller.lastActionError.value.isNotEmpty
                                  ? _controller.lastActionError.value
                                  : 'فشل إرسال التقييم',
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? AppTheme.selectedBorder
                          : AppTheme.primary,
                      foregroundColor: AppTheme.white,
                    ),
                    child: isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.white,
                              ),
                            ),
                          )
                        : Text(_text('إرسال التقييم', 'Submit rating')),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    if (!mounted) {
      return;
    }

    AppFeedback.success(context, message);
  }

  void _showErrorMessage(String message) {
    if (!mounted) {
      return;
    }

    AppFeedback.error(context, message);
  }

  String _formatPrice(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  String _text(String arabic, String english) {
    return Localizations.localeOf(context).languageCode == 'ar'
        ? arabic
        : english;
  }
}
