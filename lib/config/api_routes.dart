import 'env.dart';

class ApiRoutes {
  ApiRoutes._();

  static String get _base {
    final normalized = Env.apiBaseUrl.trim();
    if (normalized.isEmpty) {
      return normalized;
    }
    return normalized.replaceFirst(RegExp(r'/+$'), '');
  }

  static String get usersLogin => '$_base/users/login/';
  static String get usersRegister => '$_base/users/register/';
  static String get usersRegisterBuyer => '$_base/users/register/buyer/';
  static String get usersRegisterOwner => '$_base/users/register/owner/';
  static String get usersRefresh => '$_base/users/login/refresh/';
  static String get usersProfile => '$_base/users/profile/';
  static String get notifications => '$_base/notifications/';
  static String get lockersLogs => '$_base/lockers/logs/';
  static String get lockersValidateOtp => '$_base/lockers/otp/validate/';
  static String get marketplaceProducts => '$_base/marketplace/products/';
  static String get marketplaceStores => '$_base/marketplace/stores/';
  static String get marketplaceTransactions =>
      '$_base/marketplace/transactions/';
  static String get packageEntries => '$_base/package-center/packages/';

  static String transactionDetail(int id) => '$marketplaceTransactions$id/';
  static String transactionApprove(int id) =>
      '$marketplaceTransactions$id/approve/';
  static String transactionReject(int id) =>
      '$marketplaceTransactions$id/reject/';
  static String transactionPaymentProof(int id) =>
      '$marketplaceTransactions$id/payment-proof/';
  static String transactionGenerateOtp(int id) =>
      '$marketplaceTransactions$id/generate-otp/';
  static String transactionBuyerShipping(int id) =>
      '$marketplaceTransactions$id/buyer-shipping/';
  static String packageEntryDetail(int id) => '$packageEntries$id/';
}
