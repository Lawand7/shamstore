import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shamstore/core/constants/api_constants.dart';
import 'package:shamstore/features/seller/controllers/seller_orders_controller.dart';
import 'package:shamstore/features/seller/models/seller_order_model.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_feedback.dart';
import 'package:shamstore/utils/localized_content.dart';

class SellerOrdersPage extends StatefulWidget {
  const SellerOrdersPage({super.key});

  @override
  State<SellerOrdersPage> createState() => _SellerOrdersPageState();
}

class _SellerOrdersPageState extends State<SellerOrdersPage> {
  late final SellerOrdersController _controller;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _controller = Get.isRegistered<SellerOrdersController>()
        ? Get.find<SellerOrdersController>()
        : Get.put(SellerOrdersController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.refreshOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color backgroundColor = isDarkMode
        ? AppTheme.darkBackground
        : AppTheme.background;

    final Color appBarColor = isDarkMode
        ? AppTheme.topBottomBar
        : AppTheme.white;

    final Color primaryColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: appBarColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'طلبات متجري',
            style: TextStyle(
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            tooltip: 'رجوع',
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              size: 20,
            ),
          ),
          actions: [
            Obx(
              () => IconButton(
                tooltip: 'تحديث',
                onPressed: _controller.isLoading.value
                    ? null
                    : _controller.refreshOrders,
                icon: _controller.isLoading.value
                    ? SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryColor,
                        ),
                      )
                    : Icon(Icons.refresh_rounded, color: primaryColor),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildStatusTabs(
              isDarkMode: isDarkMode,
              primaryColor: primaryColor,
            ),
            Expanded(
              child: Obx(
                () => _buildOrdersBody(
                  isDarkMode: isDarkMode,
                  primaryColor: primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTabs({
    required bool isDarkMode,
    required Color primaryColor,
  }) {
    return Obx(() {
      final String selectedStatus = _controller.selectedStatus.value;

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabButton(
                title: _text('قيد التنفيذ', 'In progress'),
                icon: Icons.pending_actions_rounded,
                status: 'pending',
                selectedStatus: selectedStatus,
                isDarkMode: isDarkMode,
                primaryColor: primaryColor,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildTabButton(
                title: _text('مكتملة', 'Completed'),
                icon: Icons.task_alt_rounded,
                status: 'complete',
                selectedStatus: selectedStatus,
                isDarkMode: isDarkMode,
                primaryColor: primaryColor,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required String status,
    required String selectedStatus,
    required bool isDarkMode,
    required Color primaryColor,
  }) {
    final bool isSelected = selectedStatus == status;
    final String displayedTitle = status == 'complete'
        ? '$title (${_controller.completedOrdersCount.value ?? '—'})'
        : title;

    return Material(
      color: isSelected ? primaryColor : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _controller.isLoading.value
            ? null
            : () => _controller.selectStatus(status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : isDarkMode
                    ? AppTheme.textSecondary
                    : AppTheme.textGrey,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  displayedTitle,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isDarkMode
                        ? AppTheme.textPrimary
                        : AppTheme.textDark,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersBody({
    required bool isDarkMode,
    required Color primaryColor,
  }) {
    if (_controller.isLoading.value && _controller.orders.isEmpty) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (_controller.errorMessage.value.isNotEmpty &&
        _controller.orders.isEmpty) {
      return RefreshIndicator(
        color: primaryColor,
        onRefresh: _controller.refreshOrders,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 90),
            Icon(
              Icons.cloud_off_rounded,
              size: 70,
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
            ),
            const SizedBox(height: 18),
            Text(
              LocalizedContent.message(
                context,
                _controller.errorMessage.value,
                isError: true,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: FilledButton.icon(
                onPressed: _controller.refreshOrders,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(_text('إعادة المحاولة', 'Try again')),
                style: FilledButton.styleFrom(backgroundColor: primaryColor),
              ),
            ),
          ],
        ),
      );
    }

    if (_controller.orders.isEmpty) {
      final bool pendingSelected =
          _controller.selectedStatus.value == 'pending';

      return RefreshIndicator(
        color: primaryColor,
        onRefresh: _controller.refreshOrders,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 90),
            Icon(
              pendingSelected
                  ? Icons.inventory_2_outlined
                  : Icons.task_alt_rounded,
              size: 76,
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
            ),
            const SizedBox(height: 18),
            Text(
              pendingSelected
                  ? 'لا توجد طلبات قيد التنفيذ حالياً'
                  : 'لا توجد طلبات مكتملة حالياً',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pendingSelected
                  ? 'ستظهر هنا الطلبات الجديدة التي يرسلها المشترون.'
                  : 'ستظهر هنا الطلبات بعد اكتمالها وتأكيدها.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: _controller.refreshOrders,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _controller.orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final SellerOrderModel order = _controller.orders[index];

          return _buildOrderCard(
            order: order,
            isDarkMode: isDarkMode,
            primaryColor: primaryColor,
          );
        },
      ),
    );
  }

  Widget _buildOrderCard({
    required SellerOrderModel order,
    required bool isDarkMode,
    required Color primaryColor,
  }) {
    final Map<String, dynamic> raw = order.rawData;

    final Map<String, dynamic> product = _nestedMap(raw, const [
      'product',
      'item',
      'product_data',
    ]);

    final Map<String, dynamic> customer = _nestedMap(raw, const [
      'customer',
      'buyer',
      'user',
      'customer_data',
    ]);

    final Map<String, dynamic> shipping = _nestedMap(raw, const [
      'shipping',
      'shipment',
      'shipping_data',
    ]);

    final String productName = _firstText([
      product['name'],
      product['title'],
      raw['product_name'],
      raw['name'],
      raw['title'],
    ], fallback: 'منتج غير معروف');

    final String customerName = _firstText([
      order.customerName,
      customer['name'],
      customer['full_name'],
      customer['first_name'] != null || customer['last_name'] != null
          ? '${customer['first_name'] ?? ''} ${customer['last_name'] ?? ''}'
          : null,
      customer['email'],
      raw['customer_name'],
      raw['buyer_name'],
      raw['customer_email'],
      raw['buyer_email'],
    ], fallback: order.displayCustomerName);

    final int quantity = _firstInt([
      raw['quantity'],
      raw['qty'],
      raw['count'],
    ], fallback: 1);

    final double unitPrice = _firstDouble([
      raw['unit_price'],
      raw['price'],
      product['price'],
    ]);

    final double totalPrice = _firstDouble([
      raw['total_price'],
      raw['total'],
      raw['amount'],
    ], fallback: unitPrice * quantity);

    final String phone = _firstText([
      raw['phone'],
      customer['phone'],
      shipping['phone'],
    ]);

    final String governorate = _firstText([
      raw['governorate'],
      raw['city'],
      customer['governorate'],
      customer['city'],
      shipping['governorate'],
      shipping['city'],
    ]);

    final String address = _firstText([
      raw['address'],
      customer['address'],
      shipping['address'],
    ]);

    final String createdAt = _formatDate(
      _firstValue([
        raw['created_at'],
        raw['createdAt'],
        raw['order_date'],
        raw['date'],
      ]),
    );

    final String status = _firstText([
      raw['status'],
      order.status,
    ], fallback: 'pending').toLowerCase();

    final bool isPending = status == 'pending';
    final bool isCompleted = status == 'complete' || status == 'completed';

    final String productImage = _normalizeImageUrl(
      _firstText([
        product['full_image_url'],
        product['product_image_url'],
        product['image_url'],
        product['image'],
        raw['product_image'],
        raw['image'],
      ]),
    );

    final String shippingPeriod = _firstText([
      shipping['period'],
      shipping['shipping_period'],
      raw['shipping_period'],
      raw['period'],
    ]);

    final String shippingImage = _normalizeImageUrl(
      _firstText([
        shipping['image_url'],
        shipping['shipping_image_url'],
        shipping['image'],
        raw['shipping_image'],
      ]),
    );

    final bool hasShippingInformation =
        shippingPeriod.isNotEmpty || shippingImage.isNotEmpty;

    final bool isWaitingForSeller = isPending && !hasShippingInformation;

    final bool isShipped = isPending && hasShippingInformation;

    final bool rejecting = _controller.isRejecting(orderId: order.id);

    final bool shippingOrder = _controller.isShipping(orderId: order.id);

    final bool actionRunning = _controller.isActionRunning(orderId: order.id);

    final Color cardColor = isDarkMode
        ? AppTheme.cardBackground
        : AppTheme.white;

    final Color mainTextColor = isDarkMode
        ? AppTheme.textPrimary
        : AppTheme.textDark;

    final Color secondaryTextColor = isDarkMode
        ? AppTheme.textSecondary
        : AppTheme.textGrey;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.12 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: isCompleted
                  ? AppTheme.success.withValues(alpha: 0.10)
                  : isShipped
                  ? primaryColor.withValues(alpha: 0.10)
                  : AppTheme.warning.withValues(alpha: 0.10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.success.withValues(alpha: 0.14)
                          : isShipped
                          ? primaryColor.withValues(alpha: 0.14)
                          : AppTheme.warning.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted
                              ? Icons.check_circle_rounded
                              : isShipped
                              ? Icons.local_shipping_rounded
                              : Icons.schedule_rounded,
                          size: 15,
                          color: isCompleted
                              ? AppTheme.success
                              : isShipped
                              ? primaryColor
                              : AppTheme.warning,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isCompleted
                              ? 'مكتمل'
                              : isShipped
                              ? 'تم الشحن'
                              : 'قيد التنفيذ',
                          style: TextStyle(
                            color: isCompleted
                                ? AppTheme.success
                                : isShipped
                                ? primaryColor
                                : AppTheme.warning,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'طلب #${order.id}',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductImage(
                        imageUrl: productImage,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: mainTextColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'الكمية: $quantity',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'الإجمالي: ${_formatPrice(totalPrice)} ل.س',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(
                    height: 1,
                    color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border,
                  ),
                  const SizedBox(height: 13),
                  _buildInfoRow(
                    icon: Icons.person_outline_rounded,
                    title: _text('العميل', 'Customer'),
                    value: customerName,
                    isDarkMode: isDarkMode,
                  ),
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 9),
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      title: _text('الهاتف', 'Phone'),
                      value: phone,
                      isDarkMode: isDarkMode,
                    ),
                  ],
                  if (governorate.isNotEmpty || address.isNotEmpty) ...[
                    const SizedBox(height: 9),
                    _buildInfoRow(
                      icon: Icons.location_on_outlined,
                      title: _text('العنوان', 'Address'),
                      value: [
                        LocalizedContent.value(context, governorate),
                        address,
                      ].where((value) => value.isNotEmpty).join(' - '),
                      isDarkMode: isDarkMode,
                    ),
                  ],
                  if (createdAt.isNotEmpty) ...[
                    const SizedBox(height: 9),
                    _buildInfoRow(
                      icon: Icons.calendar_today_outlined,
                      title: _text('تاريخ الطلب', 'Order date'),
                      value: createdAt,
                      isDarkMode: isDarkMode,
                    ),
                  ],
                  if (hasShippingInformation) ...[
                    const SizedBox(height: 13),
                    Divider(
                      height: 1,
                      color: isDarkMode
                          ? AppTheme.inputFieldBg
                          : AppTheme.border,
                    ),
                    const SizedBox(height: 13),
                    Text(
                      'معلومات الشحن',
                      style: TextStyle(
                        color: mainTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (shippingPeriod.isNotEmpty) ...[
                      const SizedBox(height: 9),
                      _buildInfoRow(
                        icon: Icons.local_shipping_outlined,
                        title: _text('التاريخ المتوقع', 'Expected date'),
                        value: _formatDate(shippingPeriod),
                        isDarkMode: isDarkMode,
                      ),
                    ],
                    if (shippingImage.isNotEmpty) ...[
                      const SizedBox(height: 11),
                      _buildShippingImage(
                        imageUrl: shippingImage,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ],
                  if (isShipped) ...[
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.hourglass_top_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              'تم شحن الطلب، وبانتظار تأكيد الاستلام من المشتري.',
                              style: TextStyle(
                                color: mainTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (isWaitingForSeller) ...[
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: actionRunning
                                ? null
                                : () => _confirmReject(order),
                            icon: rejecting
                                ? const SizedBox(
                                    width: 17,
                                    height: 17,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.close_rounded, size: 19),
                            label: Text(
                              rejecting ? 'جارٍ الرفض...' : 'رفض الطلب',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.error,
                              side: BorderSide(
                                color: AppTheme.error.withValues(alpha: 0.75),
                              ),
                              minimumSize: const Size.fromHeight(46),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: actionRunning
                                ? null
                                : () => _openShippingSheet(order),
                            icon: shippingOrder
                                ? const SizedBox(
                                    width: 17,
                                    height: 17,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.local_shipping_outlined,
                                    size: 19,
                                  ),
                            label: Text(
                              shippingOrder ? 'جارٍ الإرسال...' : 'شحن الطلب',
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(46),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage({
    required String imageUrl,
    required bool isDarkMode,
  }) {
    final Color placeholderColor = isDarkMode
        ? AppTheme.inputFieldBg
        : AppTheme.primaryLight;

    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: placeholderColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? Icon(
              Icons.image_outlined,
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.primarySoft,
              size: 34,
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Icon(
                Icons.broken_image_outlined,
                color: isDarkMode
                    ? AppTheme.textSecondary
                    : AppTheme.primarySoft,
                size: 34,
              ),
            ),
    );
  }

  Widget _buildShippingImage({
    required String imageUrl,
    required bool isDarkMode,
  }) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: isDarkMode ? AppTheme.textSecondary : AppTheme.primarySoft,
            size: 38,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required bool isDarkMode,
  }) {
    final Color titleColor = isDarkMode
        ? AppTheme.textSecondary
        : AppTheme.textGrey;

    final Color valueColor = isDarkMode
        ? AppTheme.textPrimary
        : AppTheme.textDark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: titleColor),
        const SizedBox(width: 8),
        Text(
          '$title:',
          style: TextStyle(
            color: titleColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmReject(SellerOrderModel order) async {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: isDarkMode
                ? AppTheme.cardBackground
                : AppTheme.white,
            title: Text(
              'رفض الطلب',
              style: TextStyle(
                color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              'هل أنت متأكد من رفض الطلب رقم #${order.id}؟ لا يمكن التراجع عن هذه العملية.',
              style: TextStyle(
                color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(_text('إلغاء', 'Cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  foregroundColor: Colors.white,
                ),
                child: Text(_text('تأكيد الرفض', 'Confirm rejection')),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final bool success = await _controller.rejectOrder(orderId: order.id);

    if (!mounted) return;

    if (success) {
      _showMessage(
        title: 'تم الرفض',
        message: _controller.lastActionMessage.value,
        isError: false,
      );
      return;
    }

    _showMessage(
      title: 'فشل رفض الطلب',
      message: _controller.lastActionError.value,
      isError: true,
    );
  }

  Future<void> _openShippingSheet(SellerOrderModel order) async {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color primaryColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    DateTime? selectedDate;
    XFile? selectedImage;
    bool isPickingImage = false;
    bool isSubmitting = false;
    String localError = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Future<void> chooseDate() async {
              final DateTime now = DateTime.now();

              final DateTime? result = await showDatePicker(
                context: sheetContext,
                initialDate: selectedDate ?? now.add(const Duration(days: 1)),
                firstDate: DateTime(now.year, now.month, now.day),
                lastDate: now.add(const Duration(days: 365)),
                helpText: 'اختر التاريخ المتوقع',
                cancelText: 'إلغاء',
                confirmText: 'اختيار',
              );

              if (result == null || !sheetContext.mounted) {
                return;
              }

              setSheetState(() {
                selectedDate = result;
                localError = '';
              });
            }

            Future<void> chooseImage() async {
              if (isPickingImage || isSubmitting) return;

              setSheetState(() {
                isPickingImage = true;
                localError = '';
              });

              try {
                final XFile? image = await _imagePicker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                  maxWidth: 1800,
                );

                if (image == null || !sheetContext.mounted) {
                  return;
                }

                setSheetState(() {
                  selectedImage = image;
                });
              } catch (_) {
                if (!sheetContext.mounted) return;

                setSheetState(() {
                  localError =
                      'تعذر اختيار الصورة. تحقق من صلاحية الوصول للصور.';
                });
              } finally {
                if (sheetContext.mounted) {
                  setSheetState(() {
                    isPickingImage = false;
                  });
                }
              }
            }

            Future<void> submit() async {
              if (isSubmitting) return;

              if (selectedDate == null) {
                setSheetState(() {
                  localError = 'اختر تاريخ الشحن أو التسليم المتوقع';
                });
                return;
              }

              if (selectedImage == null) {
                setSheetState(() {
                  localError = 'اختر صورة إثبات الشحن';
                });
                return;
              }

              setSheetState(() {
                isSubmitting = true;
                localError = '';
              });

              final bool success = await _controller.shipOrder(
                orderId: order.id,
                period: _formatDateForApi(selectedDate!),
                imagePath: selectedImage!.path,
              );

              if (!sheetContext.mounted) {
                return;
              }

              if (!success) {
                setSheetState(() {
                  isSubmitting = false;
                  localError = _controller.lastActionError.value;
                });
                return;
              }

              Navigator.pop(sheetContext);

              if (!mounted) return;

              _showMessage(
                title: 'تم إرسال الشحن',
                message: _controller.lastActionMessage.value,
                isError: false,
              );
            }

            final Color sheetColor = isDarkMode
                ? AppTheme.cardBackground
                : AppTheme.white;

            final Color mainTextColor = isDarkMode
                ? AppTheme.textPrimary
                : AppTheme.textDark;

            final Color secondaryTextColor = isDarkMode
                ? AppTheme.textSecondary
                : AppTheme.textGrey;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(sheetContext).size.height * 0.88,
                ),
                decoration: BoxDecoration(
                  color: sheetColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    18,
                    10,
                    18,
                    MediaQuery.of(sheetContext).viewInsets.bottom + 22,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: secondaryTextColor.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.local_shipping_outlined,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'شحن الطلب #${order.id}',
                                  style: TextStyle(
                                    color: mainTextColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'أدخل معلومات الشحن بدقة قبل الإرسال.',
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.pop(sheetContext),
                            icon: Icon(
                              Icons.close_rounded,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'التاريخ المتوقع',
                        style: TextStyle(
                          color: mainTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(13),
                        onTap: isSubmitting ? null : chooseDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppTheme.inputFieldBg
                                : AppTheme.background,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: selectedDate == null
                                  ? isDarkMode
                                        ? AppTheme.inputFieldBg
                                        : AppTheme.border
                                  : primaryColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                color: primaryColor,
                                size: 21,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  selectedDate == null
                                      ? 'اضغط لاختيار التاريخ'
                                      : _formatDateForApi(selectedDate!),
                                  style: TextStyle(
                                    color: selectedDate == null
                                        ? secondaryTextColor
                                        : mainTextColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: secondaryTextColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'صورة إثبات الشحن',
                        style: TextStyle(
                          color: mainTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: isSubmitting ? null : chooseImage,
                        child: Container(
                          height: selectedImage == null ? 145 : 210,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppTheme.inputFieldBg
                                : AppTheme.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selectedImage == null
                                  ? isDarkMode
                                        ? AppTheme.inputFieldBg
                                        : AppTheme.border
                                  : primaryColor,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: selectedImage == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    isPickingImage
                                        ? CircularProgressIndicator(
                                            color: primaryColor,
                                            strokeWidth: 2,
                                          )
                                        : Icon(
                                            Icons.add_photo_alternate_outlined,
                                            size: 40,
                                            color: primaryColor,
                                          ),
                                    const SizedBox(height: 10),
                                    Text(
                                      isPickingImage
                                          ? 'جارٍ فتح الصور...'
                                          : 'اختر صورة من الجهاز',
                                      style: TextStyle(
                                        color: mainTextColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'يفضل أن تكون الصورة واضحة',
                                      style: TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                )
                              : Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(
                                      File(selectedImage!.path),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Center(
                                        child: Icon(
                                          Icons.broken_image_outlined,
                                          color: secondaryTextColor,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 9,
                                      left: 9,
                                      child: Material(
                                        color: Colors.black.withValues(
                                          alpha: 0.65,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          onTap: isSubmitting
                                              ? null
                                              : () {
                                                  setSheetState(() {
                                                    selectedImage = null;
                                                  });
                                                },
                                          child: const Padding(
                                            padding: EdgeInsets.all(7),
                                            child: Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      if (localError.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: AppTheme.error.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppTheme.error,
                                size: 19,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  localError,
                                  style: const TextStyle(
                                    color: AppTheme.error,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: isSubmitting ? null : submit,
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 19,
                                height: 19,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(
                          isSubmitting
                              ? 'جارٍ إرسال معلومات الشحن...'
                              : 'إرسال معلومات الشحن',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: primaryColor.withValues(
                            alpha: 0.55,
                          ),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMessage({
    required String title,
    required String message,
    required bool isError,
  }) {
    if (isError) {
      AppFeedback.error(context, message);
    } else {
      AppFeedback.success(context, message);
    }
  }

  Map<String, dynamic> _nestedMap(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final String key in keys) {
      final dynamic value = source[key];

      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }

    return <String, dynamic>{};
  }

  dynamic _firstValue(List<dynamic> values) {
    for (final dynamic value in values) {
      if (value == null) continue;

      if (value is String && value.trim().isEmpty) {
        continue;
      }

      return value;
    }

    return null;
  }

  String _firstText(List<dynamic> values, {String fallback = ''}) {
    final dynamic value = _firstValue(values);

    if (value == null) {
      return fallback;
    }

    final String text = value.toString().trim();

    return text.isEmpty ? fallback : text;
  }

  int _firstInt(List<dynamic> values, {int fallback = 0}) {
    final dynamic value = _firstValue(values);

    if (value == null) {
      return fallback;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString().trim()) ?? fallback;
  }

  double _firstDouble(List<dynamic> values, {double fallback = 0}) {
    final dynamic value = _firstValue(values);

    if (value == null) {
      return fallback;
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString().trim()) ?? fallback;
  }

  String _formatPrice(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  String _formatDate(dynamic value) {
    if (value == null) {
      return '';
    }

    final String raw = value.toString().trim();

    if (raw.isEmpty) {
      return '';
    }

    final DateTime? parsed = DateTime.tryParse(raw);

    if (parsed == null) {
      return raw;
    }

    final DateTime localDate = parsed.toLocal();

    final String day = localDate.day.toString().padLeft(2, '0');

    final String month = localDate.month.toString().padLeft(2, '0');

    return '$day/$month/${localDate.year}';
  }

  String _formatDateForApi(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');

    final String day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  String _normalizeImageUrl(String value) {
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

  String _text(String arabic, String english) {
    return Localizations.localeOf(context).languageCode == 'ar'
        ? arabic
        : english;
  }
}
