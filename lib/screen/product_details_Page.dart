import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/customer/controllers/customer_controller.dart';
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

    final double sellerRating = _toDouble(
      product['sellerRating'] ?? product['seller_rating'] ?? product['rating'],
    );

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
                  sellerRating: sellerRating,
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
    required double sellerRating,
  }) {
    final ratingText = sellerRating > 0
        ? sellerRating.toStringAsFixed(1)
        : '0.0';

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
              Text(
                ratingText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, color: Colors.orange, size: 16),
            ]
          : [
              const Icon(Icons.star, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(
                ratingText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.orange,
                ),
              ),
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

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is double) return value;

    if (value is int) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }
}
