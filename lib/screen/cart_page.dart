import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/customer/controllers/customer_controller.dart';
import 'package:shamstore/features/customer/repositories/customer_repository.dart';
import 'package:shamstore/features/products/models/product_model.dart';
import 'package:shamstore/screen/checkout_page.dart';
import 'package:shamstore/screen/notifications_page.dart';
import 'package:shamstore/screen/product_details_Page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_feedback.dart';
import 'package:shamstore/utils/app_localizations.dart';
import 'package:shamstore/utils/localized_content.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late final CustomerController _customerController;

  final double _deliveryFee = 50;

  bool get _isArabic {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  @override
  void initState() {
    super.initState();

    _customerController = Get.isRegistered<CustomerController>()
        ? Get.find<CustomerController>()
        : Get.put(CustomerController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadCart();
    });
  }

  Future<void> _loadCart() async {
    await _customerController.fetchCart();
  }

  double get _subtotal => _customerController.cartTotal.value;

  double get _total => _subtotal + _deliveryFee;

  Future<void> _increaseQty(CustomerCartItem item) async {
    final int availableQuantity = _availableQuantity(item);

    if (availableQuantity <= 0) {
      _showError('هذا المنتج غير متوفر حالياً');
      return;
    }

    if (item.quantity >= availableQuantity) {
      _showError('الكمية المتوفرة من هذا المنتج هي $availableQuantity فقط');
      return;
    }

    final int newQuantity = item.quantity + 1;

    final bool success = await _customerController.updateCartItem(
      cartItemId: item.id,
      quantity: newQuantity,
    );

    if (!mounted) return;

    if (!success) {
      _showError(
        _customerController.updateCartItemErrorMessage.value.isNotEmpty
            ? _customerController.updateCartItemErrorMessage.value
            : 'حدث خطأ أثناء زيادة الكمية',
      );
    }
  }

  Future<void> _decreaseQty(CustomerCartItem item) async {
    if (item.quantity <= 1) {
      return;
    }

    final newQuantity = item.quantity - 1;

    final bool success = await _customerController.updateCartItem(
      cartItemId: item.id,
      quantity: newQuantity,
    );

    if (!mounted) return;

    if (!success) {
      _showError(
        _customerController.updateCartItemErrorMessage.value.isNotEmpty
            ? _customerController.updateCartItemErrorMessage.value
            : 'حدث خطأ أثناء إنقاص الكمية',
      );
    }
  }

  Future<void> _removeItem(CustomerCartItem item) async {
    final bool success = await _customerController.removeCartItem(
      cartItemId: item.id,
    );

    if (!mounted) return;

    if (!success) {
      _showError(
        _customerController.removeCartItemErrorMessage.value.isNotEmpty
            ? _customerController.removeCartItemErrorMessage.value
            : 'حدث خطأ أثناء حذف المنتج من السلة',
      );
      return;
    }

    AppFeedback.success(context, 'تم حذف المنتج من السلة');
  }

  void _showError(String message) {
    AppFeedback.error(context, message);
  }

  Future<void> _openCheckout(CustomerCartItem item) async {
    final ProductModel? product = item.product;
    final int availableQuantity = _availableQuantity(item);

    if (product == null) {
      _showError('تعذر قراءة بيانات المنتج. حدّث السلة ثم أعد المحاولة');
      return;
    }

    if (!product.isActive) {
      _showError('هذا المنتج غير متاح للبيع حالياً');
      return;
    }

    if (availableQuantity <= 0) {
      _showError('نفدت كمية هذا المنتج');
      return;
    }

    if (item.quantity > availableQuantity) {
      _showError(
        'الكمية المطلوبة ${item.quantity} بينما المتوفر $availableQuantity فقط',
      );
      return;
    }

    final bool? orderCreated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(item: _cartItemToCheckoutMap(item)),
      ),
    );

    if (!mounted || orderCreated != true) {
      return;
    }

    final bool refreshed = await _customerController.fetchCart();

    if (!mounted) {
      return;
    }

    if (!refreshed) {
      _showError(
        _customerController.cartErrorMessage.value.isNotEmpty
            ? _customerController.cartErrorMessage.value
            : 'تم إنشاء الطلب، لكن تعذر تحديث السلة تلقائياً',
      );
    }
  }

  void _openProductDetails(CustomerCartItem item) {
    final product = item.product;

    if (product == null) {
      _showError('لا يمكن فتح تفاصيل هذا المنتج حالياً');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProductDetailsPage(product: _cartItemToProductDetailsMap(item)),
      ),
    );
  }

  Map<String, dynamic> _cartItemToProductDetailsMap(CustomerCartItem item) {
    final product = item.product;

    return {
      'id': product?.id ?? item.productId,
      'seller_id': product?.sellerId ?? 0,
      'category_id': product?.categoryId ?? 0,
      'name': product?.title ?? 'منتج غير معروف',
      'title': product?.title ?? 'منتج غير معروف',
      'description': product?.description ?? '',
      'city': product?.governorate ?? '',
      'governorate': product?.governorate ?? '',
      'price': _formatPrice(_getUnitPrice(item)),
      'quantity': product?.quantity ?? 0,
      'product_image_url': product?.productImageUrl ?? '',
      'imageUrl': product?.fullImageUrl ?? '',
      'product_url': product?.productUrl ?? '',
      'is_active': product?.isActive ?? true,
      'created_at': product?.createdAt,
      'updated_at': product?.updatedAt,
      'sellerRating': 0.0,
      'sellerName': 'Seller #${product?.sellerId ?? 0}',
    };
  }

  Map<String, dynamic> _cartItemToCheckoutMap(CustomerCartItem item) {
    final product = item.product;

    return {
      'cart_item_id': item.id,
      'cart_id': item.cartId,
      'product_id': item.productId,
      'name': product?.title ?? 'منتج غير معروف',
      'title': product?.title ?? 'منتج غير معروف',
      'description': product?.description ?? '',
      'city': product?.governorate ?? '',
      'governorate': product?.governorate ?? '',
      'area': '',
      'price': _getUnitPrice(item),
      'qty': item.quantity,
      'quantity': item.quantity,
      'available_quantity': product?.quantity ?? 0,
      'is_active': product?.isActive ?? false,
      'total_price': item.totalPrice,
      'imageUrl': product?.fullImageUrl ?? '',
      'product_image_url': product?.productImageUrl ?? '',
      'seller_id': product?.sellerId ?? 0,
      'category_id': product?.categoryId ?? 0,
      'icon': Icons.inventory_2_outlined,
    };
  }

  double _getUnitPrice(CustomerCartItem item) {
    final productPrice = item.product?.price ?? 0;

    if (productPrice > 0) {
      return productPrice;
    }

    if (item.quantity > 0) {
      return item.totalPrice / item.quantity;
    }

    return item.totalPrice;
  }

  String _formatPrice(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  int _availableQuantity(CustomerCartItem item) {
    return item.product?.quantity ?? 0;
  }

  bool _canPurchase(CustomerCartItem item) {
    final ProductModel? product = item.product;
    final int availableQuantity = _availableQuantity(item);

    return product != null &&
        product.isActive &&
        availableQuantity > 0 &&
        item.quantity > 0 &&
        item.quantity <= availableQuantity;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppTheme.darkBackground
          : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('Shopping Cart'),
          style: const TextStyle(
            color: AppTheme.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            _isArabic
                ? Icons.arrow_forward_ios_rounded
                : Icons.arrow_back_ios_new_rounded,
            color: AppTheme.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: AppTheme.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsPage(),
                    ),
                  );
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (_customerController.isLoadingCart.value &&
            _customerController.cartItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_customerController.cartErrorMessage.value.isNotEmpty &&
            _customerController.cartItems.isEmpty) {
          return _buildError(isDarkMode);
        }

        if (_customerController.cartItems.isEmpty) {
          return RefreshIndicator(
            onRefresh: _loadCart,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: _buildEmpty(isDarkMode),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadCart,
          child: _buildCart(isDarkMode),
        );
      }),
    );
  }

  Widget _buildCart(bool isDarkMode) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(14),
            itemCount: _customerController.cartItems.length,
            itemBuilder: (context, index) {
              final item = _customerController.cartItems[index];

              return _buildCartItem(item: item, isDarkMode: isDarkMode);
            },
          ),
        ),
        _buildSummary(isDarkMode),
      ],
    );
  }

  Widget _buildCartItem({
    required CustomerCartItem item,
    required bool isDarkMode,
  }) {
    final ProductModel? product = item.product;

    final String productName = product?.title.trim().isNotEmpty == true
        ? product!.title
        : AppLocalizations.of(context).translate('unknown_product');

    final String city = product?.governorate.trim().isNotEmpty == true
        ? LocalizedContent.value(context, product!.governorate)
        : AppLocalizations.of(context).translate('not_available');

    final double unitPrice = _getUnitPrice(item);
    final int availableQuantity = _availableQuantity(item);
    final bool canPurchase = _canPurchase(item);
    final bool outOfStock = availableQuantity <= 0;

    final Color activeColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode ? Colors.transparent : AppTheme.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Obx(() {
                final bool isRemovingThisItem =
                    _customerController.isRemovingCartItem.value &&
                    _customerController.removingCartItemId.value == item.id;

                return GestureDetector(
                  onTap: isRemovingThisItem
                      ? null
                      : () async {
                          await _removeItem(item);
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0x1FFF4444)
                          : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDarkMode
                            ? const Color(0x3FFF4444)
                            : const Color(0xFFFECACA),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (isRemovingThisItem)
                          const SizedBox(
                            width: 13,
                            height: 13,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFEF4444),
                            ),
                          )
                        else
                          const Icon(
                            Icons.delete_outline,
                            size: 13,
                            color: Color(0xFFEF4444),
                          ),
                        const SizedBox(width: 3),
                        Text(
                          AppLocalizations.of(context).translate('Delete'),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: canPurchase ? () => _openCheckout(item) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: canPurchase
                        ? (isDarkMode
                              ? activeColor.withValues(alpha: 0.08)
                              : const Color(0xFFEEF4FC))
                        : (isDarkMode
                              ? AppTheme.inputFieldBg
                              : const Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: canPurchase
                          ? activeColor.withValues(alpha: 0.3)
                          : AppTheme.textLight.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        canPurchase
                            ? Icons.payment_outlined
                            : Icons.block_rounded,
                        size: 13,
                        color: canPurchase ? activeColor : AppTheme.textLight,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        canPurchase
                            ? AppLocalizations.of(context).translate('Pay')
                            : 'غير متاح',
                        style: TextStyle(
                          fontSize: 10,
                          color: canPurchase ? activeColor : AppTheme.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _openProductDetails(item),
            child: _buildProductImage(
              product: product,
              isDarkMode: isDarkMode,
              activeColor: activeColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: _isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _openProductDetails(item),
                  child: Column(
                    crossAxisAlignment: _isArabic
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? AppTheme.textPrimary
                              : AppTheme.textDark,
                        ),
                        textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: _isArabic
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: _isArabic
                            ? [
                                Text(
                                  city,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDarkMode
                                        ? AppTheme.textSecondary
                                        : AppTheme.textLight,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.location_on,
                                  size: 11,
                                  color: activeColor,
                                ),
                              ]
                            : [
                                Icon(
                                  Icons.location_on,
                                  size: 11,
                                  color: activeColor,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  city,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDarkMode
                                        ? AppTheme.textSecondary
                                        : AppTheme.textLight,
                                  ),
                                ),
                              ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: _isArabic
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    _buildQuantityControls(
                      item: item,
                      isDarkMode: isDarkMode,
                      activeColor: activeColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_formatPrice(unitPrice)} ${AppLocalizations.of(context).translate('SYP')}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: activeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  outOfStock ? 'نفد المخزون' : 'المتوفر: $availableQuantity',
                  style: TextStyle(
                    fontSize: 10,
                    color: outOfStock
                        ? Colors.red
                        : (isDarkMode
                              ? AppTheme.textSecondary
                              : AppTheme.textGrey),
                    fontWeight: outOfStock ? FontWeight.w700 : FontWeight.w500,
                  ),
                  textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: 3),
                GestureDetector(
                  onTap: () => _openProductDetails(item),
                  child: Text(
                    'الإجمالي: ${_formatPrice(item.totalPrice)} ${AppLocalizations.of(context).translate('SYP')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDarkMode
                          ? AppTheme.textSecondary
                          : AppTheme.textGrey,
                    ),
                    textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls({
    required CustomerCartItem item,
    required bool isDarkMode,
    required Color activeColor,
  }) {
    return Obx(() {
      final bool isUpdatingThisItem =
          _customerController.isUpdatingCartItem.value &&
          _customerController.updatingCartItemId.value == item.id;

      final int availableQuantity = _availableQuantity(item);
      final bool reachedAvailableQuantity =
          availableQuantity <= 0 || item.quantity >= availableQuantity;

      return Row(
        children: [
          GestureDetector(
            onTap: isUpdatingThisItem || reachedAvailableQuantity
                ? null
                : () async {
                    await _increaseQty(item);
                  },
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDarkMode ? Colors.transparent : AppTheme.border,
                ),
              ),
              child: Icon(
                Icons.add,
                size: 14,
                color: reachedAvailableQuantity
                    ? (isDarkMode ? AppTheme.textSecondary : AppTheme.textLight)
                    : activeColor,
              ),
            ),
          ),
          Container(
            width: 34,
            alignment: Alignment.center,
            child: isUpdatingThisItem
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    '${item.quantity}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? AppTheme.textPrimary
                          : AppTheme.textDark,
                    ),
                  ),
          ),
          GestureDetector(
            onTap: isUpdatingThisItem || item.quantity <= 1
                ? null
                : () async {
                    await _decreaseQty(item);
                  },
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDarkMode ? Colors.transparent : AppTheme.border,
                ),
              ),
              child: Icon(
                Icons.remove,
                size: 14,
                color: item.quantity <= 1
                    ? (isDarkMode ? AppTheme.textSecondary : AppTheme.textLight)
                    : activeColor,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildProductImage({
    required ProductModel? product,
    required bool isDarkMode,
    required Color activeColor,
  }) {
    final imageUrl = product?.fullImageUrl ?? '';

    if (imageUrl.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.inventory_2_outlined,
          size: 32,
          color: activeColor.withValues(alpha: 0.6),
        ),
      );
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Icon(
            Icons.broken_image_outlined,
            size: 32,
            color: activeColor.withValues(alpha: 0.6),
          );
        },
      ),
    );
  }

  Widget _buildSummary(bool isDarkMode) {
    final Color activeColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        border: Border(
          top: BorderSide(
            color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.18 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow(
            label: AppLocalizations.of(context).translate('Total'),
            value:
                '${_formatPrice(_subtotal)} ${AppLocalizations.of(context).translate('SYP')}',
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 6),
          _summaryRow(
            label: AppLocalizations.of(context).translate('Delivery Fee'),
            value:
                '${_formatPrice(_deliveryFee)} ${AppLocalizations.of(context).translate('SYP')}',
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 8),
          Divider(color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: _isArabic
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Text(
                '${_formatPrice(_total)} ${AppLocalizations.of(context).translate('SYP')}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: activeColor,
                ),
              ),
              const Spacer(),
              Text(
                'الإجمالي النهائي',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
          ),
        ),
        const Spacer(),
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

  Widget _buildError(bool isDarkMode) {
    final Color activeColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 58,
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
            ),
            const SizedBox(height: 14),
            Text(
              _customerController.cartErrorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _loadCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: activeColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 70,
            color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).translate('Your cart is empty'),
            style: TextStyle(
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
