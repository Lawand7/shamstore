import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/customer/controllers/customer_controller.dart';
import 'package:shamstore/features/products/repositories/product_repository.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final CustomerController customerController =
        Get.isRegistered<CustomerController>()
        ? Get.find<CustomerController>()
        : Get.put(CustomerController());

    final Color activePrimary = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;
    final Color activeTextDark = isDarkMode
        ? AppTheme.textPrimary
        : AppTheme.textDark;

    final int productId = _toInt(product['id']);
    final int sellerId = _toInt(product['seller_id']);

    final String title = _readString([
      'title',
      'name',
    ], fallback: 'منتج بدون اسم');

    final String description = _readString([
      'description',
    ], fallback: 'لا يوجد وصف متوفر لهذا المنتج');

    final String governorate = _readString([
      'governorate',
      'city',
    ], fallback: 'غير متوفر');

    final String price = _readString(['price'], fallback: '0');

    final String quantity = _readString(['quantity'], fallback: '0');

    final String imageUrl = _readString([
      'imageUrl',
      'fullImageUrl',
      'product_image_url',
    ]);

    final String sellerName = _readString([
      'sellerName',
      'seller_name',
    ], fallback: sellerId > 0 ? 'Seller #$sellerId' : 'Seller');

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppTheme.darkBackground
          : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('Product Details'),
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            isArabic
                ? Icons.arrow_forward_ios_rounded
                : Icons.arrow_back_ios_new_rounded,
            color: AppTheme.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'إبلاغ عن المنتج',
            icon: const Icon(
              Icons.report_problem_outlined,
              color: AppTheme.white,
            ),
            onPressed: () => _showProductReportSheet(
              context: context,
              productId: productId,
              isDarkMode: isDarkMode,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: isDarkMode ? AppTheme.darkBackground : AppTheme.white,
              child: _buildProductImage(
                imageUrl: imageUrl,
                isDarkMode: isDarkMode,
                activePrimary: activePrimary,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              border: Border.all(
                color: isDarkMode
                    ? AppTheme.inputFieldBg.withOpacity(0.5)
                    : Colors.transparent,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: activeTextDark,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPriceRow(
                  context: context,
                  isArabic: isArabic,
                  isDarkMode: isDarkMode,
                  activePrimary: activePrimary,
                  price: price,
                ),
                const SizedBox(height: 12),
                Divider(
                  color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border,
                ),
                const SizedBox(height: 12),
                _buildMetaRow(
                  isArabic: isArabic,
                  isDarkMode: isDarkMode,
                  activePrimary: activePrimary,
                  governorate: governorate,
                  sellerName: sellerName,
                  sellerRatingFuture: ProductRepository().getSellerRating(
                    sellerId: sellerId,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  isArabic: isArabic,
                  isDarkMode: isDarkMode,
                  activePrimary: activePrimary,
                  sellerId: sellerId,
                  quantity: quantity,
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context).translate('Description Title'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: activeTextDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode
                        ? AppTheme.textSecondary
                        : AppTheme.textGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Obx(() {
                  final bool isAddingThisProduct =
                      customerController.isAddingCartItem.value &&
                      customerController.addingCartProductId.value == productId;

                  return SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: isAddingThisProduct
                          ? null
                          : () async {
                              await _addProductToCart(
                                context: context,
                                customerController: customerController,
                                productId: productId,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? AppTheme.selectedBorder
                            : AppTheme.primary,
                        disabledBackgroundColor: isDarkMode
                            ? AppTheme.selectedBorder.withOpacity(0.5)
                            : AppTheme.primary.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: isAddingThisProduct
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.add_shopping_cart,
                              color: Colors.white,
                              size: 18,
                            ),
                      label: Text(
                        isAddingThisProduct
                            ? 'جاري الإضافة...'
                            : AppLocalizations.of(
                                context,
                              ).translate('Add to Cart Button'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addProductToCart({
    required BuildContext context,
    required CustomerController customerController,
    required int productId,
  }) async {
    if (productId <= 0) {
      Get.snackbar(
        'خطأ',
        'معرّف المنتج غير صالح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final bool success = await customerController.addCartItem(
      productId: productId,
      quantity: 1,
    );

    if (!context.mounted) return;

    if (!success) {
      Get.snackbar(
        'فشل الإضافة',
        customerController.addCartItemErrorMessage.value.isNotEmpty
            ? customerController.addCartItemErrorMessage.value
            : 'حدث خطأ أثناء إضافة المنتج إلى السلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'نجاح',
      'تمت إضافة المنتج إلى السلة',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _showProductReportSheet({
    required BuildContext context,
    required int productId,
    required bool isDarkMode,
  }) async {
    if (productId <= 0) {
      Get.snackbar(
        'فشل الإبلاغ',
        'تعذر تحديد المنتج',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final TextEditingController reportController = TextEditingController();
    bool isSending = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 22,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: isSending
                            ? null
                            : () => Navigator.of(sheetContext).pop(),
                        icon: Icon(
                          Icons.close,
                          color: isDarkMode
                              ? AppTheme.textSecondary
                              : AppTheme.textGrey,
                        ),
                      ),
                      const Text(
                        'الإبلاغ عن المنتج',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reportController,
                    maxLines: 4,
                    minLines: 4,
                    textAlign: TextAlign.right,
                    enabled: !isSending,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode
                          ? AppTheme.textPrimary
                          : AppTheme.textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'اكتب تفاصيل المشكلة بشكل واضح...',
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
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSending
                          ? null
                          : () async {
                              final description = reportController.text.trim();

                              if (description.isEmpty) {
                                Get.snackbar(
                                  'فشل الإبلاغ',
                                  'يرجى كتابة تفاصيل المشكلة',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              setModalState(() => isSending = true);

                              try {
                                final message = await ProductRepository()
                                    .reportProduct(
                                      productId: productId,
                                      description: description,
                                    );

                                if (!sheetContext.mounted) return;

                                Navigator.of(sheetContext).pop();
                                Get.snackbar(
                                  'تم الإرسال',
                                  message,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              } catch (error) {
                                if (!sheetContext.mounted) return;

                                setModalState(() => isSending = false);
                                Get.snackbar(
                                  'فشل الإبلاغ',
                                  error.toString().replaceFirst(
                                    'Exception: ',
                                    '',
                                  ),
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
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
                          : const Text(
                              'إرسال البلاغ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    reportController.dispose();
  }

  Widget _buildProductImage({
    required String imageUrl,
    required bool isDarkMode,
    required Color activePrimary,
  }) {
    if (imageUrl.trim().isEmpty) {
      return Center(
        child: Icon(
          Icons.image_outlined,
          size: 110,
          color: activePrimary.withOpacity(isDarkMode ? 0.85 : 0.7),
        ),
      );
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 95,
            color: activePrimary.withOpacity(isDarkMode ? 0.85 : 0.7),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Center(
          child: CircularProgressIndicator(
            color: activePrimary,
            strokeWidth: 2,
          ),
        );
      },
    );
  }

  Widget _buildPriceRow({
    required BuildContext context,
    required bool isArabic,
    required bool isDarkMode,
    required Color activePrimary,
    required String price,
  }) {
    final currency = AppLocalizations.of(context).translate('SP');

    return Row(
      mainAxisAlignment: isArabic
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: isArabic
          ? [
              Text(
                currency,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode
                      ? AppTheme.textSecondary
                      : AppTheme.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                price,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: activePrimary,
                ),
              ),
            ]
          : [
              Text(
                price,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: activePrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                currency,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode
                      ? AppTheme.textSecondary
                      : AppTheme.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
    );
  }

  Widget _buildMetaRow({
    required bool isArabic,
    required bool isDarkMode,
    required Color activePrimary,
    required String governorate,
    required String sellerName,
    required Future<SellerRatingResult> sellerRatingFuture,
  }) {
    final locationWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: isArabic
          ? [
              Text(
                governorate,
                style: TextStyle(
                  color: isDarkMode
                      ? AppTheme.textSecondary
                      : AppTheme.textGrey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.location_on, color: activePrimary, size: 16),
            ]
          : [
              Icon(Icons.location_on, color: activePrimary, size: 16),
              const SizedBox(width: 4),
              Text(
                governorate,
                style: TextStyle(
                  color: isDarkMode
                      ? AppTheme.textSecondary
                      : AppTheme.textGrey,
                  fontSize: 13,
                ),
              ),
            ],
    );

    final sellerWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: isArabic
          ? [
              Flexible(
                child: Text(
                  sellerName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDarkMode
                        ? AppTheme.textSecondary
                        : AppTheme.textGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _buildSellerRating(sellerRatingFuture, isDarkMode: isDarkMode),
              const SizedBox(width: 4),
              const Icon(Icons.star, color: Colors.orange, size: 16),
            ]
          : [
              const Icon(Icons.star, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              _buildSellerRating(sellerRatingFuture, isDarkMode: isDarkMode),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  sellerName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDarkMode
                        ? AppTheme.textSecondary
                        : AppTheme.textGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: isArabic
          ? [
              Expanded(child: sellerWidget),
              const SizedBox(width: 8),
              locationWidget,
            ]
          : [
              locationWidget,
              const SizedBox(width: 8),
              Expanded(child: sellerWidget),
            ],
    );
  }

  Widget _buildSellerRating(
    Future<SellerRatingResult> sellerRatingFuture, {
    required bool isDarkMode,
  }) {
    return FutureBuilder<SellerRatingResult>(
      future: sellerRatingFuture,
      builder: (context, snapshot) {
        String ratingText = '...';

        if (snapshot.connectionState == ConnectionState.done) {
          final result = snapshot.data;

          if (result?.hasRating == true) {
            ratingText = result!.averageRating!.toStringAsFixed(2);
          } else if (result?.errorMessage != null) {
            ratingText = result!.errorMessage!;
          } else {
            ratingText = 'لا يوجد تقييم بعد';
          }
        }

        return Flexible(
          child: Text(
            ratingText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: snapshot.data?.errorMessage != null
                  ? (isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey)
                  : Colors.orange,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required bool isArabic,
    required bool isDarkMode,
    required Color activePrimary,
    required int sellerId,
    required String quantity,
  }) {
    final sellerIdText = sellerId > 0 ? sellerId.toString() : 'غير متوفر';

    final quantityWidget = _smallInfoChip(
      icon: Icons.inventory_2_outlined,
      label: 'الكمية',
      value: quantity,
      isArabic: isArabic,
      isDarkMode: isDarkMode,
      color: Colors.orange,
    );

    final sellerIdWidget = _smallInfoChip(
      icon: Icons.person_outline,
      label: 'Seller ID',
      value: sellerIdText,
      isArabic: isArabic,
      isDarkMode: isDarkMode,
      color: activePrimary,
    );

    return Row(
      children: isArabic
          ? [
              Expanded(child: sellerIdWidget),
              const SizedBox(width: 8),
              Expanded(child: quantityWidget),
            ]
          : [
              Expanded(child: quantityWidget),
              const SizedBox(width: 8),
              Expanded(child: sellerIdWidget),
            ],
    );
  }

  Widget _smallInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required bool isArabic,
    required bool isDarkMode,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(isDarkMode ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(isDarkMode ? 0.28 : 0.2)),
      ),
      child: Row(
        mainAxisAlignment: isArabic
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: isArabic
            ? [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: isDarkMode
                              ? AppTheme.textSecondary
                              : AppTheme.textGrey,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        value,
                        style: TextStyle(
                          color: isDarkMode
                              ? AppTheme.textPrimary
                              : AppTheme.textDark,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(icon, color: color, size: 17),
              ]
            : [
                Icon(icon, color: color, size: 17),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: isDarkMode
                              ? AppTheme.textSecondary
                              : AppTheme.textGrey,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        value,
                        style: TextStyle(
                          color: isDarkMode
                              ? AppTheme.textPrimary
                              : AppTheme.textDark,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
      ),
    );
  }

  String _readString(List<String> keys, {String fallback = ''}) {
    for (final key in keys) {
      final value = product[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }
}
