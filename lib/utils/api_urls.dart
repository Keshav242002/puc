/// Centralised API endpoint constants.
class ApiUrls {
  ApiUrls._();

  // Auth
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String forgotPassword = '/auth/forgotPassword';
  static const String verifyOtp = '/auth/verifyOtp';

  // Dashboard
  static const String dashboard = '/dashboard';

  // Orders
  static const String createOrder = '/order/create';

  // PUC
  static const String applyPUC = '/for/applyPUC';

  // Dynamic paths
  static String getPuc(String userId) => '/for/getPuc/$userId';
  static String uploadPuc(String userId) => '/uploadpuc/$userId';
}
