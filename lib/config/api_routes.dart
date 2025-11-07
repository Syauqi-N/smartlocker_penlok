import 'env.dart';

class ApiRoutes {
  ApiRoutes._();

  static String get _base => Env.apiBaseUrl;

  static String get usersLogin => '$_base/users/login/';
  static String get usersRegister => '$_base/users/register/';
  static String get usersRefresh => '$_base/users/login/refresh/';
  static String get notifications => '$_base/notifications/';
  static String get lockersLogs => '$_base/lockers/logs/';
  static String get lockersValidateOtp => '$_base/lockers/otp/validate/';
  static String get marketplaceProducts => '$_base/marketplace/products/';
  static String get marketplaceTransactions =>
      '$_base/marketplace/transactions/';

  static String transactionDetail(int id) => '${marketplaceTransactions}$id/';
  static String transactionApprove(int id) =>
      '${marketplaceTransactions}$id/approve/';
  static String transactionReject(int id) =>
      '${marketplaceTransactions}$id/reject/';
  static String transactionPaymentProof(int id) =>
      '${marketplaceTransactions}$id/payment-proof/';
  static String transactionGenerateOtp(int id) =>
      '${marketplaceTransactions}$id/generate-otp/';
}
