import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/screen/notifications_page.dart';
import 'package:shamstore/utils/app_localizations.dart'; // استيراد ملف الترجمة

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final List<Map<String, dynamic>> orders = const [
    {
      'name': 'جاكيت رجالي أنيق',
      'shop': 'متجر الأناقة',
      'city': 'دمشق',
      'price': '349',
      'icon': Icons.checkroom,
      'status': 'pending',
    },
    {
      'name': 'حذاء جري رياضي',
      'shop': 'سبورت شوب',
      'city': 'دمشق',
      'price': '299',
      'icon': Icons.directions_run,
      'status': 'pending',
    },
    {
      'name': 'سماعات لاسلكية',
      'shop': 'تك ستور',
      'city': 'حلب',
      'price': '199',
      'icon': Icons.headphones,
      'status': 'delivered',
    },
  ];

  void _showReportBottomSheet(BuildContext context, String productName, bool isDarkMode) {
    final reportController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? AppTheme.cardBackground : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    AppLocalizations.of(context).translate('Report a Problem'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${AppLocalizations.of(context).translate('Product')}: $productName',
                style: TextStyle(fontSize: 12, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
              ),
              const SizedBox(height: 16),

              Text(
                AppLocalizations.of(context).translate('Describe your problem'),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reportController,
                maxLines: 4,
                textAlign: TextAlign.right,
                style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, fontSize: 13),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).translate('Write problem details here...'),
                  hintStyle: TextStyle(fontSize: 12, color: isDarkMode ? AppTheme.textSecondary.withOpacity(0.5) : AppTheme.textLight),
                  filled: true,
                  fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (reportController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context).translate('Please write the problem before sending'), textAlign: TextAlign.right)),
                      );
                    } else {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context).translate('Report sent successfully'), textAlign: TextAlign.right),
                          backgroundColor: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocalizations.of(context).translate('Send to Admin'),
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRatingDialog(BuildContext context, String productName, bool isDarkMode) {
    int selectedRating = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
          title: Text(
            AppLocalizations.of(context).translate('Rate Product'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
          ),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    productName,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      int starValue = 5 - index;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedRating = starValue;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            starValue <= selectedRating ? Icons.star : Icons.star_border,
                            color: Colors.orange,
                            size: 32,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).translate('Cancel'), style: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight, fontSize: 13)),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedRating == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context).translate('Please select at least one star'), textAlign: TextAlign.right)),
                  );
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${AppLocalizations.of(context).translate('Thanks for rating')} $selectedRating ⭐', textAlign: TextAlign.right),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: Text(AppLocalizations.of(context).translate('Confirm'), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        title: Text(AppLocalizations.of(context).translate('My Orders'), style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
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
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) => _buildOrderCard(orders[index], isDarkMode),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isDarkMode) {
    final isDelivered = order['status'] == 'delivered';
    final Color activeColor = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(order['icon'], size: 32, color: activeColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(order['name'], style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark)),
                    const SizedBox(height: 4),
                    Text('${order['shop']} | ${order['city']}', style: TextStyle(fontSize: 12, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey)),
                    const SizedBox(height: 4),
                    Text('${order['price']} ${AppLocalizations.of(context).translate('SP')}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: activeColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDelivered
                    ? (isDarkMode ? Colors.green.withOpacity(0.15) : const Color(0xFFE6F9F0))
                    : (isDarkMode ? Colors.orange.withOpacity(0.15) : const Color(0xFFFFF4E5)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isDelivered ? AppLocalizations.of(context).translate('Delivered') : AppLocalizations.of(context).translate('Pending Delivery'),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDelivered ? Colors.green : Colors.orange),
                  ),
                  const SizedBox(width: 4),
                  Icon(isDelivered ? Icons.check_circle : Icons.local_shipping_outlined, size: 14, color: isDelivered ? Colors.green : Colors.orange),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Divider(color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionButton(
                label: AppLocalizations.of(context).translate('Report'),
                icon: Icons.flag_outlined,
                color: Colors.red,
                onTap: () => _showReportBottomSheet(context, order['name'], isDarkMode),
              ),
              const SizedBox(width: 8),

              _actionButton(
                label: AppLocalizations.of(context).translate('Rate'),
                icon: Icons.star_border,
                color: Colors.orange,
                onTap: () => _showRatingDialog(context, order['name'], isDarkMode),
              ),
              const SizedBox(width: 8),
              if (!isDelivered)
                _actionButton(
                  label: AppLocalizations.of(context).translate('Confirm Button'),
                  icon: Icons.check,
                  color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
                  onTap: () {},
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(20),
          color: color.withOpacity(0.06),
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Icon(icon, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}