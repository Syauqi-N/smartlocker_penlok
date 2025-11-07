import 'package:smartlocker/models/package.dart';
import 'package:smartlocker/services/transaction_service.dart';

class PackageService {
  PackageService._internal();
  static final PackageService instance = PackageService._internal();

  final TransactionService _transactionService = TransactionService();

  Future<List<Package>> fetchPackages({bool asSeller = false}) async {
    final transactions = await _transactionService.fetchTransactions(
      role: asSeller ? 'seller' : 'buyer',
    );
    return transactions.map(Package.fromTransaction).toList();
  }

  Future<List<Package>> fetchActivePackages() async {
    final packages = await fetchPackages();
    return packages
        .where((p) =>
            p.status == PackageStatus.inTransit ||
            p.status == PackageStatus.delivered)
        .toList();
  }

  Future<List<Package>> fetchCompletedPackages() async {
    final packages = await fetchPackages();
    return packages.where((p) => p.status == PackageStatus.completed).toList();
  }
}
