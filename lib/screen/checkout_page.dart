import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/orders/controllers/order_controller.dart';
import 'package:shamstore/screen/notifications_page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_feedback.dart';
import 'package:shamstore/utils/app_localizations.dart';

class CheckoutPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const CheckoutPage({super.key, required this.item});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();

  final OrderController _orderController = OrderController();

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
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
          icon: const Icon(Icons.close, color: AppTheme.white),
          onPressed: () {
            if (!_orderController.isPlacingOrder.value) {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildDeliveryForm(context, isDarkMode),
                  const SizedBox(height: 14),
                  _buildOrderSummary(context, isDarkMode),
                  const SizedBox(height: 20),
                  _buildConfirmButton(context, isDarkMode),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryForm(BuildContext context, bool isDarkMode) {
    final Color activeColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.transparent : AppTheme.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            AppLocalizations.of(context).translate('Delivery Details'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 14),

          Text(
            AppLocalizations.of(context).translate('Phone Number'),
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
            ),
          ),
          const SizedBox(height: 6),

          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            textAlign: _textInputLeftRight(),
            style: TextStyle(
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              fontSize: 13,
            ),
            validator: _validatePhone,
            decoration: InputDecoration(
              hintText: '0930000000',
              prefixIcon: Icon(
                Icons.phone_outlined,
                color: activeColor,
                size: 18,
              ),
              filled: true,
              fillColor: isDarkMode
                  ? AppTheme.inputFieldBg
                  : AppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: isDarkMode
                    ? BorderSide.none
                    : const BorderSide(color: AppTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: isDarkMode
                    ? BorderSide.none
                    : const BorderSide(color: AppTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? AppTheme.selectedBorder
                      : AppTheme.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            AppLocalizations.of(context).translate('Address'),
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
            ),
          ),
          const SizedBox(height: 6),

          TextFormField(
            controller: _addressController,
            maxLines: 2,
            textInputAction: TextInputAction.done,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              fontSize: 13,
            ),
            validator: _validateAddress,
            onFieldSubmitted: (_) {
              _submitOrder();
            },
            decoration: InputDecoration(
              hintText: 'Damascus - Al-Mezzeh',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: Icon(
                  Icons.location_on_outlined,
                  color: activeColor,
                  size: 18,
                ),
              ),
              filled: true,
              fillColor: isDarkMode
                  ? AppTheme.inputFieldBg
                  : AppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: isDarkMode
                    ? BorderSide.none
                    : const BorderSide(color: AppTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: isDarkMode
                    ? BorderSide.none
                    : const BorderSide(color: AppTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? AppTheme.selectedBorder
                      : AppTheme.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, bool isDarkMode) {
    final String productName = _extractProductName();
    final dynamic price = _extractProductPrice();
    final int quantity = _extractOrderQuantity();
    final int availableQuantity = _extractAvailableQuantity();
    final bool stockIsValid = _isStockValid();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.transparent : AppTheme.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            AppLocalizations.of(context).translate('Order Summary'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Divider(color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border),
          const SizedBox(height: 6),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${_formatPrice(price)} '
                  '${AppLocalizations.of(context).translate('SP')}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  productName,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode
                        ? AppTheme.textPrimary
                        : AppTheme.textDark,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                quantity.toString(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
                ),
              ),
              Text(
                'الكمية',
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode
                      ? AppTheme.textSecondary
                      : AppTheme.textGrey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                availableQuantity.toString(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: stockIsValid
                      ? (isDarkMode ? AppTheme.accentBlue : AppTheme.primary)
                      : Colors.red,
                ),
              ),
              Text(
                availableQuantity > 0 ? 'الكمية المتوفرة' : 'نفد المخزون',
                style: TextStyle(
                  fontSize: 13,
                  color: stockIsValid
                      ? (isDarkMode
                            ? AppTheme.textSecondary
                            : AppTheme.textGrey)
                      : Colors.red,
                  fontWeight: stockIsValid
                      ? FontWeight.normal
                      : FontWeight.w700,
                ),
              ),
            ],
          ),

          if (!stockIsValid) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
              ),
              child: Text(
                availableQuantity <= 0
                    ? 'لا يمكن متابعة الطلب لأن المنتج غير متوفر حالياً.'
                    : 'الكمية المطلوبة $quantity بينما المتوفر $availableQuantity فقط.',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],

          if (_calculateTotal() != null) ...[
            const SizedBox(height: 12),
            Divider(
              color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatPrice(_calculateTotal())} '
                  '${AppLocalizations.of(context).translate('SP')}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
                  ),
                ),
                Text(
                  'الإجمالي',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? AppTheme.textPrimary
                        : AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() {
        final bool isLoading = _orderController.isPlacingOrder.value;
        final bool stockIsValid = _isStockValid();

        return ElevatedButton(
          onPressed: isLoading || !stockIsValid ? null : _submitOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode
                ? AppTheme.selectedBorder
                : AppTheme.primary,
            foregroundColor: AppTheme.white,
            disabledBackgroundColor: isDarkMode
                ? AppTheme.inputFieldBg
                : AppTheme.textGrey,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                  ),
                )
              : Text(
                  AppLocalizations.of(context).translate('Confirm Order'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        );
      }),
    );
  }

  Future<void> _submitOrder() async {
    FocusScope.of(context).unfocus();

    if (_orderController.isPlacingOrder.value) {
      return;
    }

    final bool isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      return;
    }

    final int productId = _extractProductId();
    final int quantity = _extractOrderQuantity();
    final int availableQuantity = _extractAvailableQuantity();

    if (!_extractIsActive()) {
      _showErrorMessage('هذا المنتج غير متاح للبيع حالياً.');
      return;
    }

    if (availableQuantity <= 0) {
      _showErrorMessage('نفدت كمية هذا المنتج.');
      return;
    }

    if (quantity > availableQuantity) {
      _showErrorMessage(
        'الكمية المطلوبة $quantity بينما المتوفر $availableQuantity فقط.',
      );
      return;
    }

    if (productId <= 0) {
      _showErrorMessage(
        'تعذر تحديد رقم المنتج. بيانات المنتج المرسلة إلى صفحة الدفع غير صحيحة.',
      );
      return;
    }

    if (quantity <= 0) {
      _showErrorMessage('الكمية المطلوبة غير صحيحة.');
      return;
    }

    final bool success = await _orderController.placeOrder(
      productId: productId,
      quantity: quantity,
      phone: _phoneController.text,
      address: _addressController.text,
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      _showErrorMessage(
        _orderController.errorMessage.value ?? 'فشل إنشاء الطلب',
      );
      return;
    }

    final String successMessage =
        _orderController.lastOrder.value?.message ?? 'تم إنشاء الطلب بنجاح';

    await _showSuccessDialog(successMessage);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  Future<void> _showSuccessDialog(String message) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(child: Text(_text('تم إنشاء الطلب', 'Order created'))),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(_text('موافق', 'OK')),
            ),
          ],
        );
      },
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) {
      return;
    }

    AppFeedback.error(context, message);
  }

  String? _validatePhone(String? value) {
    final String phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return _text('يرجى إدخال رقم الهاتف', 'Please enter the phone number');
    }

    final String digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length < 8) {
      return _text('رقم الهاتف غير صحيح', 'Please enter a valid phone number');
    }

    return null;
  }

  String? _validateAddress(String? value) {
    final String address = value?.trim() ?? '';

    if (address.isEmpty) {
      return _text(
        'يرجى إدخال عنوان التوصيل',
        'Please enter the delivery address',
      );
    }

    if (address.length < 5) {
      return _text(
        'عنوان التوصيل قصير جداً',
        'The delivery address is too short',
      );
    }

    return null;
  }

  int _extractProductId() {
    final int directProductId = _toInt(widget.item['product_id']);

    if (directProductId > 0) {
      return directProductId;
    }

    final Map<String, dynamic>? product = _extractNestedProduct();

    final int nestedProductId = _toInt(product?['id']);

    if (nestedProductId > 0) {
      return nestedProductId;
    }

    return _toInt(widget.item['id']);
  }

  int _extractOrderQuantity() {
    final List<dynamic> possibleValues = [
      widget.item['selected_quantity'],
      widget.item['cart_quantity'],
      widget.item['order_quantity'],
      widget.item['quantity'],
    ];

    for (final dynamic value in possibleValues) {
      final int quantity = _toInt(value);

      if (quantity > 0) {
        return quantity;
      }
    }

    return 1;
  }

  int _extractAvailableQuantity() {
    final Map<String, dynamic>? product = _extractNestedProduct();

    final List<dynamic> possibleValues = [
      widget.item['available_quantity'],
      widget.item['stock_quantity'],
      widget.item['product_quantity'],
      product?['quantity'],
    ];

    for (final dynamic value in possibleValues) {
      if (value == null) {
        continue;
      }

      return _toInt(value);
    }

    return 0;
  }

  bool _extractIsActive() {
    final Map<String, dynamic>? product = _extractNestedProduct();

    final dynamic value =
        widget.item['is_active'] ?? product?['is_active'] ?? true;

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value.toInt() == 1;
    }

    final String normalized = value.toString().trim().toLowerCase();

    return normalized == '1' || normalized == 'true' || normalized == 'active';
  }

  bool _isStockValid() {
    final int quantity = _extractOrderQuantity();
    final int availableQuantity = _extractAvailableQuantity();

    return _extractIsActive() &&
        quantity > 0 &&
        availableQuantity > 0 &&
        quantity <= availableQuantity;
  }

  String _extractProductName() {
    final Map<String, dynamic>? product = _extractNestedProduct();

    final List<dynamic> possibleValues = [
      widget.item['name'],
      widget.item['title'],
      widget.item['product_name'],
      product?['name'],
      product?['title'],
    ];

    for (final dynamic value in possibleValues) {
      final String text = value?.toString().trim() ?? '';

      if (text.isNotEmpty) {
        return text;
      }
    }

    return _text('المنتج', 'Product');
  }

  dynamic _extractProductPrice() {
    final Map<String, dynamic>? product = _extractNestedProduct();

    return widget.item['price'] ??
        widget.item['product_price'] ??
        product?['price'] ??
        0;
  }

  Map<String, dynamic>? _extractNestedProduct() {
    final dynamic product = widget.item['product'];

    if (product is Map<String, dynamic>) {
      return product;
    }

    if (product is Map) {
      return Map<String, dynamic>.from(product);
    }

    return null;
  }

  double? _calculateTotal() {
    final double? price = _toDouble(_extractProductPrice());

    if (price == null) {
      return null;
    }

    return price * _extractOrderQuantity();
  }

  String _formatPrice(dynamic value) {
    final double? number = _toDouble(value);

    if (number == null) {
      return value?.toString() ?? '0';
    }

    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }

    return number.toStringAsFixed(2);
  }

  int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  String _text(String arabic, String english) {
    return Localizations.localeOf(context).languageCode == 'ar'
        ? arabic
        : english;
  }

  TextAlign _textInputLeftRight() {
    return Localizations.localeOf(context).languageCode == 'ar'
        ? TextAlign.left
        : TextAlign.right;
  }
}
