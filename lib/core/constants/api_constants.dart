class ApiConstants {
  ApiConstants._();

  /*
   * إذا كنت تستخدم:
   *
   * adb reverse tcp:8000 tcp:8000
   *
   * أبقِ 127.0.0.1.
   *
   * أما Android Emulator بدون adb reverse:
   * http://10.0.2.2:8000/api
   */
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // =========================================================
  // Authentication
  // =========================================================

  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';

  static const String sendOtp = '/otp/send';

  // التحقق العام من OTP
  static const String verifyOtp = '/otp/verify';

  // تأكيد الحساب بعد التسجيل
  static const String verifyRegister = '/verifyRegister';

  static const String forgotPassword = '/forgotPassword';
  static const String changePassword = '/changePassword';

  // =========================================================
  // Profile
  // =========================================================

  static const String updateProfile = '/updateProfile';

  // =========================================================
  // Wallet
  // =========================================================

  static const String changePin = '/changePin';
  static const String checkPin = '/checkPin';

  static const String deposit = '/deposit';
  static const String withdraw = '/withdraw';
  static const String myTransactions = '/getMyTransactionByStatus';
  static const String myBalance = '/getMyBalance';

  // =========================================================
  // Public Products
  // =========================================================

  static const String showAllProducts = '/showallproducts';

  static String productsByCategory(int categoryId) {
    return '/products/$categoryId/categories';
  }

  static const String searchProductsByProductUrl =
      '/products/searchByProductUrl';

  static const String filterProducts = '/products/filter';

  static String reportProduct(int productId) {
    return '/products/$productId/report';
  }

  static String sellerRating(int sellerId) {
    return '/sellers/$sellerId/rating';
  }

  // =========================================================
  // Customer Favorites
  // =========================================================

  static String addToFavorites(int productId) {
    return '/addToFavorites/$productId';
  }

  static String removeFromFavorites(int productId) {
    return '/removeFromFavorites/$productId';
  }

  static const String favoriteProducts = '/getFavoriteProducts';

  // =========================================================
  // Customer Cart
  // =========================================================

  static const String cart = '/cart';
  static const String cartItems = '/cart/items';

  static String cartItem(int cartItemId) {
    return '/cart/items/$cartItemId';
  }

  // =========================================================
  // Customer Orders
  // =========================================================

  static const String createOrder = '/storeorders';
  static const String customerOrders = '/ShowOrderByCustomer';
  static const String storeOrder = '/storeorders';
  static String confirmOrder(int orderId) {
    return '/order/$orderId/confirm';
  }

  static String reportOrder(int orderId) {
    return '/order/$orderId/report';
  }

  static const String rateSeller = '/rate-seller';

  // =========================================================
  // Seller Products
  // =========================================================

  static const String sellerProducts = '/products';

  static String sellerProduct(int productId) {
    return '/products/$productId';
  }

  static String hideProduct(int productId) {
    return '/product/$productId/hide';
  }

  static String activateProduct(int productId) {
    return '/product/$productId/show';
  }

  static const String allMyProducts = '/getAllMyProducts';
  static const String activeMyProducts = '/getMyActiveProducts';
  static const String inactiveMyProducts = '/getMyInactiveProducts';

  static const String activeProductsCount = '/countMyActiveProducts';
  static const String inactiveProductsCount = '/countMyInactiveProducts';

  // =========================================================
  // Seller Orders
  // =========================================================

  static const String sellerOrders = '/ShowOrderBySeller';

  static const String sellerCompletedOrdersCount = '/orders/completed-count';

  static String shipSellerOrder(int orderId) {
    return '/orders/$orderId/ship';
  }

  static String rejectSellerOrder(int orderId) {
    return '/orders/$orderId/reject';
  }

  static String shipOrder(int orderId) {
    return '/orders/$orderId/ship';
  }

  static String rejectOrder(int orderId) {
    return '/orders/$orderId/reject';
  }

  static const String completedOrdersCount = '/orders/completed-count';

  // =========================================================
  // Notifications
  // =========================================================

  static const String notifications = '/getAllMynotification';

  static String markNotificationAsRead(int notificationId) {
    return '/markasread/$notificationId';
  }

  static String deleteNotification(int notificationId) {
    return '/deleteNotification/$notificationId';
  }

  // =========================================================
  // Support
  // =========================================================

  static const String askQuestion = '/askQuestion';
  static const String myQuestions = '/getMyQuestionsByStatus';

  // =========================================================
  // Advertisements
  // =========================================================

  static const String createAd = '/createAd';

  static String deleteAd(int adId) {
    return '/deleteAd/$adId';
  }

  static const String myAds = '/getMyAdsByStatus';
  static const String allApprovedAds = '/showAllAdvertisment';

  // =========================================================
  // Admin - Users
  // =========================================================

  static const String adminUsers = '/showUsers';
  static const String blockUser = '/blockUser';
  static const String blockedUsers = '/getBlockedUsers';

  static String unblockUser(int userId) {
    return '/unBlockUser/$userId';
  }

  static String checkUserBlocked(int userId) {
    return '/checkIfUserBlocked/$userId';
  }

  // =========================================================
  // Admin - Transactions
  // =========================================================

  static const String transactionsByType = '/getTransactionsByType';

  static const String transactionsByStatus = '/getTransactionsByStatus';

  static String handleDepositTransaction(int transactionId) {
    return '/handleDepositTransaction/$transactionId';
  }

  static String handleWithdrawTransaction(int transactionId) {
    return '/handleWithdrawTransaction/$transactionId';
  }

  // =========================================================
  // Admin - Advertisements
  // =========================================================

  static const String adsByStatus = '/getAdsByStatus';

  static String handleAd(int adId) {
    return '/handleAd/$adId';
  }

  // =========================================================
  // Admin - Support
  // =========================================================

  static const String questionsByStatus = '/getQuestionsByStatus';

  static String handleQuestion(int questionId) {
    return '/handleQuestion/$questionId';
  }

  // =========================================================
  // Admin - Product Reports
  // =========================================================

  static const String productReports = '/product-reports';

  static String dismissProductReport(int reportId) {
    return '/product-reports/$reportId/dismiss';
  }

  static String deleteReportedProduct(int reportId) {
    return '/product-reports/$reportId/delete-product';
  }

  // =========================================================
  // Admin - Order Reports
  // =========================================================

  static const String orderReports = '/order-reports';

  static String acceptOrderReport(int reportId) {
    return '/order-reports/$reportId/accept';
  }

  static String rejectOrderReport(int reportId) {
    return '/order-reports/$reportId/reject';
  }

  // =========================================================
  // Testing Only
  // =========================================================

  static const String sendNotification = '/sendNotification';
}
