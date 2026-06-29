import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'تم شحن طلبك الجديد 📦',
        'desc': 'قام البائع بشحن حذاء الجري الرياضي الخاص بك، تتبع الشحنة الآن.',
        'time': 'منذ 5 دقائق',
        'isRead': false,
        'icon': Icons.local_shipping_outlined,
        'color': activeColor,
      },
      {
        'title': 'رصيد جديد متاح 💰',
        'desc': 'تمت إضافة 99,000 ل.س إلى مستحقاتك بعد اكتمال طلب الجاكيت الرجالي.',
        'time': 'منذ ساعتين',
        'isRead': false,
        'icon': Icons.account_balance_wallet_outlined,
        'color': Colors.green,
      },
      {
        'title': 'تخفيض على مفضلتك! 🔥',
        'desc': 'المنتج "فستان نسائي ناعم" المضاف للمفضلة لديه خصم لفترة محدودة.',
        'time': 'منذ يوم',
        'isRead': true,
        'icon': Icons.favorite_outline,
        'color': Colors.red,
      },
    ];

    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_forward : Icons.arrow_back,
            color: AppTheme.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).translate('Notifications Title'),
          style: const TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: AppTheme.white, size: 20),
            onPressed: () {},
            tooltip: AppLocalizations.of(context).translate('Mark all as read tooltip'),
          )
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context, isDarkMode)
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = notifications[index];
          final bool unread = !item['isRead'];

          return Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: unread
                    ? activeColor.withOpacity(0.5)
                    : (isDarkMode ? Colors.transparent : AppTheme.border),
                width: unread ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              leading: isArabic ? null : Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(item['icon'], color: item['color'], size: 22),
              ),
              trailing: isArabic ? Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(item['icon'], color: item['color'], size: 22),
              ) : null,
              title: Text(
                item['title'],
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: unread ? FontWeight.bold : FontWeight.w500,
                  color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    item['desc'],
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: isArabic
                        ? [
                      if (unread)
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(color: activeColor, shape: BoxShape.circle),
                        ),
                      const Spacer(),
                      Text(
                        item['time'],
                        style: TextStyle(fontSize: 10, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
                      ),
                    ]
                        : [
                      Text(
                        item['time'],
                        style: TextStyle(fontSize: 10, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
                      ),
                      const Spacer(),
                      if (unread)
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(color: activeColor, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 70,
            color: isDarkMode ? AppTheme.textSecondary.withOpacity(0.3) : AppTheme.textLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).translate('No new notifications'),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context).translate('Notifications placeholder description'),
            style: TextStyle(fontSize: 12, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
          ),
        ],
      ),
    );
  }
}