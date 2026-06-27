import 'package:flutter/material.dart';
import 'package:shamstore/screen/checkout_page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/screen/notifications_page.dart';
import 'package:shamstore/utils/app_localizations.dart'; // استدعاء ملف الترجمة الخاص بك

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<Map<String, dynamic>> _cartItems = [
    {'name': 'Elegant Men Jacket', 'city': 'Damascus', 'area': 'Al-Mezzeh', 'price': 349, 'qty': 1, 'icon': Icons.checkroom},
    {'name': 'Sports Running Shoes', 'city': 'Damascus', 'area': 'Bab Touma', 'price': 299, 'qty': 1, 'icon': Icons.directions_run},
    {'name': 'Wireless Headphones', 'city': 'Aleppo', 'area': 'Al-Aziziyeh', 'price': 199, 'qty': 3, 'icon': Icons.headphones},
  ];

  final double _deliveryFee = 50;

  double get _subtotal => _cartItems.fold(0, (sum, item) => sum + item['price'] * item['qty']);
  double get _total => _subtotal + _deliveryFee;

  void _removeItem(int index) {
    setState(() => _cartItems.removeAt(index));
  }

  void _increaseQty(int index) {
    setState(() => _cartItems[index]['qty']++);
  }

  void _decreaseQty(int index) {
    if (_cartItems[index]['qty'] > 1) {
      setState(() => _cartItems[index]['qty']--);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 فحص حالة الدارك مود الحالية بالتطبيق ديناميكياً
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('Shopping Cart'),
          style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: AppTheme.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsPage()),
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
              ]  ),
        ],
      ),
      body: _cartItems.isEmpty ? _buildEmpty(isDarkMode) : _buildCart(isDarkMode),
    );
  }

  Widget _buildCart(bool isDarkMode) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) => _buildCartItem(index, isDarkMode),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(int index, bool isDarkMode) {
    final item = _cartItems[index];
    final Color activeColor = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // أزرار الحذف والدفع من السلة
          Column(
            children: [
              GestureDetector(
                onTap: () => _removeItem(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0x1FFF4444) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDarkMode ? const Color(0x3FFF4444) : const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline, size: 13, color: Color(0xFFEF4444)),
                      const SizedBox(width: 3),
                      Text(
                        AppLocalizations.of(context).translate('Delete'),
                        style: const TextStyle(fontSize: 10, color: Color(0xFFEF4444), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CheckoutPage(item: item)),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDarkMode ? activeColor.withOpacity(0.08) : const Color(0xFFEEF4FC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: activeColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.payment_outlined, size: 13, color: activeColor),
                      const SizedBox(width: 3),
                      Text(
                        AppLocalizations.of(context).translate('Pay'),
                        style: TextStyle(fontSize: 10, color: activeColor, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),

          // أيقونة المنتج الخلفية
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item['icon'], size: 32, color: activeColor.withOpacity(0.6)),
          ),
          const SizedBox(width: 10),

          // تفاصيل السلعة والكمية والسعر
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item['name'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${item['city']} - ${item['area']}',
                      style: TextStyle(fontSize: 10, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.location_on, size: 11, color: activeColor),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _increaseQty(index),
                          child: Container(
                            width: 26, height: 26,
                            decoration: BoxDecoration(
                              color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
                            ),
                            child: Icon(Icons.add, size: 14, color: activeColor),
                          ),
                        ),
                        Container(
                          width: 30,
                          alignment: Alignment.center,
                          child: Text(
                            '${item['qty']}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _decreaseQty(index),
                          child: Container(
                            width: 26, height: 26,
                            decoration: BoxDecoration(
                              color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
                            ),
                            child: Icon(Icons.remove, size: 14, color: activeColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${item['price']} ${AppLocalizations.of(context).translate('SYP')}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: activeColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 70, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).translate('Your cart is empty'),
            style: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey, fontSize: 15),
          ),
        ],
      ),
    );
  }
}