import 'package:flutter/material.dart';

import 'package:shamstore/utils/app_localizations.dart';

class LocalizedContent {
  LocalizedContent._();

  static const Map<String, String> _englishForArabicMessage = {
    'تعذر اختيار الصورة': 'Unable to select the image.',
    'يرجى اختيار صورة المنتج': 'Please select a product image.',
    'يرجى إدخال اسم المنتج': 'Please enter the product name.',
    'يرجى إدخال السعر': 'Please enter the price.',
    'يرجى إدخال الكمية': 'Please enter the quantity.',
    'يرجى اختيار التصنيف': 'Please select a category.',
    'يرجى اختيار المحافظة': 'Please select a governorate.',
    'السعر غير صالح': 'Please enter a valid price.',
    'الكمية غير صالحة': 'Please enter a valid quantity.',
    'معرّف المنتج غير صالح': 'The product identifier is invalid.',
    'حدث خطأ أثناء إضافة المنتج': 'An error occurred while adding the product.',
    'حدث خطأ أثناء تعديل المنتج':
        'An error occurred while updating the product.',
    'تمت إضافة المنتج بنجاح': 'The product was added successfully.',
    'تم تعديل المنتج بنجاح': 'The product was updated successfully.',
    'تم حذف المنتج من السلة': 'The product was removed from the cart.',
    'أدخل مبلغ شحن صحيحًا أكبر من الصفر':
        'Enter a valid deposit amount greater than zero.',
    'أدخل رقم عملية التحويل': 'Enter the transfer transaction number.',
    'يرجى إدخال رقم الهاتف': 'Please enter the phone number.',
    'رقم الهاتف غير صحيح': 'Please enter a valid phone number.',
    'هذا المنتج غير متاح للبيع حالياً':
        'This product is currently unavailable for sale.',
    'نفدت كمية هذا المنتج': 'This product is out of stock.',
    'كلمة المرور الجديدة وتأكيدها غير متطابقين':
        'The new password and its confirmation do not match.',
    'رمز PIN الجديد وتأكيده غير متطابقين':
        'The new PIN and its confirmation do not match.',
    'يرجى إدخال البريد الإلكتروني': 'Please enter your email address.',
    'يرجى إدخال بريد إلكتروني صحيح': 'Please enter a valid email address.',
    'يرجى إدخال البريد الإلكتروني وكلمة المرور':
        'Please enter your email address and password.',
    'تم إرسال رمز التحقق إلى البريد الإلكتروني':
        'A verification code was sent to your email address.',
    'تم إرسال رمز جديد إلى البريد الإلكتروني':
        'A new verification code was sent to your email address.',
    'يرجى إدخال رمز التحقق المكون من 6 أرقام':
        'Please enter the 6-digit verification code.',
    'رمز التحقق غير صحيح': 'The verification code is incorrect.',
    'تم التحقق من الحساب بنجاح': 'Your account was verified successfully.',
    'يرجى تعبئة جميع الحقول المطلوبة': 'Please complete all required fields.',
    'يرجى اختيار صورة الملف الشخصي': 'Please select a profile image.',
    'يرجى اختيار صورة الهوية للبائع':
        'Please select the seller identity image.',
    'كلمة المرور وتأكيد كلمة المرور غير متطابقين':
        'The password and its confirmation do not match.',
    'كلمة المرور يجب أن تكون 8 أحرف على الأقل':
        'Password must be at least 8 characters.',
    'رمز المحفظة يجب أن يكون 4 أرقام': 'The wallet PIN must be 4 digits.',
    'يجب أن يتكون رمز PIN من أربعة أرقام': 'The wallet PIN must be 4 digits.',
    'يرجى كتابة تفاصيل المشكلة': 'Please describe the problem.',
    'تعذر تحديد المنتج': 'Unable to identify the product.',
    'تمت إضافة المنتج إلى السلة': 'The product was added to the cart.',
    'تم حذف المنتج بنجاح': 'The product was deleted successfully.',
    'تم إخفاء المنتج بنجاح': 'The product was hidden successfully.',
    'تم نشر المنتج بنجاح': 'The product was published successfully.',
    'يرجى إدخال الحد الأدنى والأعلى للسعر معاً':
        'Please enter both the minimum and maximum price.',
    'الحد الأدنى للسعر يجب أن يكون أقل من الحد الأعلى':
        'The minimum price must be lower than the maximum price.',
    'رقم التصنيف غير صحيح': 'The category identifier is invalid.',
  };

  static const Map<String, String> _valueAliases = {
    'tartus': 'Tartous',
    'tartous': 'Tartous',
    'deir ez-zor': 'Deir el-Zor',
    'deir el-zor': 'Deir el-Zor',
    'al-hasakah': 'Hasakah',
    'hasakah': 'Hasakah',
    'sweida': 'Suwayda',
    'suwayda': 'Suwayda',
    'rif dimashq': 'Rif Dimashq',
    'all': 'value_all',
    'الكل': 'value_all',
    'pending': 'status_pending',
    'complete': 'status_completed',
    'completed': 'status_completed',
    'approved': 'status_approved',
    'declined': 'status_declined',
    'answered': 'status_answered',
    'active': 'status_active',
    'inactive': 'status_inactive',
    'payment': 'transaction_payment',
    'deposit': 'transaction_deposit',
    'withdraw': 'transaction_withdraw',
    'refund': 'transaction_refund',
    'electronics': 'category_electronics',
    'clothes': 'category_clothes',
    'clothing': 'category_clothes',
    'shoes': 'category_shoes',
    'books': 'category_books',
    'furniture': 'category_furniture',
    'sports': 'category_sports',
    'beauty': 'category_beauty',
    'accessories': 'category_accessories',
    'toys': 'category_toys',
    'games': 'category_games',
  };

  static String value(BuildContext context, Object? rawValue) {
    final raw = rawValue?.toString().trim() ?? '';
    if (raw.isEmpty) return '';

    final localizations = AppLocalizations.of(context);
    final alias = _valueAliases[raw.toLowerCase()] ?? raw;

    return localizations.translateOrOriginal(alias);
  }

  static String message(
    BuildContext context,
    Object? rawMessage, {
    required bool isError,
  }) {
    final localizations = AppLocalizations.of(context);
    final raw = _cleanMessage(rawMessage);
    final normalized = raw.toLowerCase();
    final key = _messageKey(normalized);
    final isArabicLocale = Localizations.localeOf(context).languageCode == 'ar';

    if (key != null) {
      return localizations.translate(key);
    }

    if (!isArabicLocale && _englishForArabicMessage.containsKey(raw)) {
      return _englishForArabicMessage[raw]!;
    }

    if (isArabicLocale) {
      final backendMessage = _arabicBackendMessage(raw);
      if (backendMessage != null) return backendMessage;
    }

    if (localizations.containsKey(raw)) {
      return localizations.translate(raw);
    }

    if (_isTechnicalMessage(normalized)) {
      return localizations.translate('message_safe_server_error');
    }

    final isArabicText = RegExp(r'[\u0600-\u06FF]').hasMatch(raw);
    if ((isArabicLocale && isArabicText) ||
        (!isArabicLocale && !isArabicText)) {
      return raw;
    }

    return localizations.translate(
      isError ? 'message_generic_error' : 'message_generic_success',
    );
  }

  static String notificationTitle(BuildContext context, String rawTitle) {
    final localizations = AppLocalizations.of(context);
    final normalized = rawTitle.trim().toLowerCase().replaceAll(' ', '');
    final key = <String, String>{
      'paymentsuccessful': 'notification_payment_successful_title',
      'neworderreceived': 'notification_new_order_title',
      'ordershipped': 'notification_order_shipped_title',
      'paymentreceived': 'notification_payment_received_title',
      'orderrejected': 'notification_order_rejected_title',
      'neworderreport': 'notification_new_report_title',
      'productremoved': 'notification_product_removed_title',
      'reportaccepted': 'notification_report_accepted_title',
      'ordercancelled': 'notification_order_cancelled_title',
      'reportrejected': 'notification_report_rejected_title',
      'acceptedadvertisment': 'notification_ad_approved_title',
      'acceptedadvertisement': 'notification_ad_approved_title',
      'unacceptedadvertisment': 'notification_ad_declined_title',
      'unacceptedadvertisement': 'notification_ad_declined_title',
      'deposittransaction': 'notification_deposit_title',
      'withdrawtransaction': 'notification_withdraw_title',
      'newadvertisment': 'notification_new_ad_title',
      'newadvertisement': 'notification_new_ad_title',
      'newdeposittransaction': 'notification_new_deposit_title',
      'newwithdrawtransaction': 'notification_new_withdraw_title',
      'newquestion': 'notification_new_question_title',
    }[normalized];

    if (key != null) return localizations.translate(key);

    return value(context, rawTitle);
  }

  static String notificationBody(BuildContext context, String rawBody) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    if (!isArabic) {
      return RegExp(r'[\u0600-\u06FF]').hasMatch(rawBody)
          ? message(context, rawBody, isError: false)
          : rawBody;
    }

    final trimmed = rawBody.trim();
    final patterns = <RegExp, String Function(Match)>{
      RegExp(
        r'^Your wallet was charged for purchasing:\s*(.+)\.?$',
        caseSensitive: false,
      ): (match) =>
          'تم خصم قيمة شراء ${match.group(1)} من محفظتك.',
      RegExp(
        r'^You have a new order for:\s*(.+)\.?$',
        caseSensitive: false,
      ): (match) =>
          'لديك طلب جديد على ${match.group(1)}.',
      RegExp(
        r'^Your order for (.+) has been shipped\.?$',
        caseSensitive: false,
      ): (match) =>
          'تم شحن طلبك للمنتج ${match.group(1)}.',
      RegExp(
        r'^An amount has been deposited into your wallet for selling:\s*(.+)\.?$',
        caseSensitive: false,
      ): (match) =>
          'تم إيداع قيمة بيع ${match.group(1)} في محفظتك.',
      RegExp(
        r'^Your order for (.+) was rejected by the seller\..*$',
        caseSensitive: false,
      ): (match) =>
          'رفض البائع طلب ${match.group(1)} وتمت إعادة المبلغ إلى محفظتك.',
      RegExp(
        r'^Your report on (.+) has been accepted.*$',
        caseSensitive: false,
      ): (match) =>
          'تم قبول بلاغك على ${match.group(1)} وإعادة المبلغ إلى محفظتك.',
      RegExp(
        r'^Your report on (.+) has been rejected.*$',
        caseSensitive: false,
      ): (match) =>
          'تم رفض بلاغك على ${match.group(1)} وإكمال الطلب.',
    };

    for (final entry in patterns.entries) {
      final match = entry.key.firstMatch(trimmed);
      if (match != null) return entry.value(match);
    }

    return message(context, trimmed, isError: false);
  }

  static String _cleanMessage(Object? rawMessage) {
    var message = rawMessage?.toString().trim() ?? '';
    message = message.replaceFirst(RegExp(r'^Exception:\s*'), '');

    if (message.isEmpty) return 'message_generic_error';

    return message;
  }

  static String? _messageKey(String message) {
    if (message == 'message_generic_error') return 'message_generic_error';
    if (message.contains('unauthenticated') ||
        message.contains('session expired') ||
        message.contains('انتهت جلسة')) {
      return 'message_session_expired';
    }
    if (message.contains('socketexception') ||
        message.contains('no internet') ||
        message.contains('network is unreachable') ||
        message.contains('connection error')) {
      return 'message_no_internet';
    }
    if (message.contains('timeout') || message.contains('timed out')) {
      return 'message_timeout';
    }
    if (message.contains('invalid credentials') ||
        message.contains('incorrect password') ||
        message.contains('credentials do not match')) {
      return 'message_invalid_credentials';
    }
    if (message.contains('insufficient wallet balance') ||
        message.contains("don't have enough money") ||
        (message.contains('رصيد') && message.contains('غير كاف'))) {
      return 'message_insufficient_balance';
    }
    if (message.contains('order placed successfully')) {
      return 'message_order_placed';
    }
    if (message.contains('order confirmed successfully') ||
        message.contains('تم تأكيد استلام')) {
      return 'message_order_confirmed';
    }
    if (message.contains('already completed') ||
        message.contains('already complete')) {
      return 'message_order_already_completed';
    }
    if (message.contains('order not found')) return 'message_order_not_found';
    if (message.contains('report submitted successfully') ||
        message.contains('تم إرسال البلاغ')) {
      return 'message_report_submitted';
    }
    if (message.contains('rating submitted successfully') ||
        message.contains('تم إرسال تقييم')) {
      return 'message_rating_submitted';
    }
    if (message.contains('already been rated') ||
        message.contains('سبق أن قيّمت')) {
      return 'message_already_rated';
    }
    if (message.contains('only completed orders can be rated')) {
      return 'message_rate_completed_only';
    }
    if (message.contains('ad created') && message.contains('pending')) {
      return 'message_ad_created_pending';
    }
    if (message.contains('ad deleted successfully')) {
      return 'message_ad_deleted';
    }
    if ((message.contains('transaction created') &&
            message.contains('pending')) ||
        message.contains('transaction created, and now it is pending')) {
      return 'message_transaction_pending';
    }
    if (message.contains('question sent to the support')) {
      return 'message_support_sent';
    }
    if (message.contains('password') && message.contains('success')) {
      return 'message_password_changed';
    }
    if (message.contains('pin') && message.contains('success')) {
      return 'message_pin_changed';
    }
    if (message.contains('profile') && message.contains('success')) {
      return 'message_profile_updated';
    }
    if (message.contains('added to favorites') ||
        message.contains('تمت الإضافة إلى المفضلة')) {
      return 'message_favorite_added';
    }
    if (message.contains('removed from favorites') ||
        message.contains('تمت الإزالة من المفضلة')) {
      return 'message_favorite_removed';
    }
    if (message.contains('required') ||
        message.contains('must be') ||
        message.contains('يرجى') ||
        message.contains('يجب')) {
      return null;
    }

    return null;
  }

  static bool _isTechnicalMessage(String message) {
    return message.contains('sqlstate') ||
        message.contains('stack trace') ||
        message.contains('exception') ||
        message.contains('vendor\\laravel') ||
        message.contains('app\\models') ||
        message.contains('column not found') ||
        message.contains('queryexception');
  }

  static String? _arabicBackendMessage(String message) {
    final requiredMatch = RegExp(
      r'^The (.+?) field is required\.?$',
      caseSensitive: false,
    ).firstMatch(message);
    if (requiredMatch != null) {
      return 'حقل ${_arabicFieldName(requiredMatch.group(1))} مطلوب.';
    }

    final emailMatch = RegExp(
      r'^The (.+?) field must be a valid email address\.?$',
      caseSensitive: false,
    ).firstMatch(message);
    if (emailMatch != null) {
      return 'يرجى إدخال بريد إلكتروني صحيح.';
    }

    final minimumMatch = RegExp(
      r'^The (.+?) field must be at least (\d+) characters?\.?$',
      caseSensitive: false,
    ).firstMatch(message);
    if (minimumMatch != null) {
      return 'يجب ألا يقل حقل ${_arabicFieldName(minimumMatch.group(1))} عن ${minimumMatch.group(2)} محارف.';
    }

    if (message.toLowerCase().contains('confirmation does not match')) {
      return 'القيمة وتأكيدها غير متطابقين.';
    }

    return null;
  }

  static String _arabicFieldName(String? field) {
    return <String, String>{
          'email': 'البريد الإلكتروني',
          'password': 'كلمة المرور',
          'password confirmation': 'تأكيد كلمة المرور',
          'phone': 'رقم الهاتف',
          'phone number': 'رقم الهاتف',
          'governorate': 'المحافظة',
          'amount': 'المبلغ',
          'quantity': 'الكمية',
          'title': 'العنوان',
          'description': 'الوصف',
        }[field?.trim().toLowerCase()] ??
        (field ?? 'المطلوب');
  }
}
