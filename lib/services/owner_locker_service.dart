import 'dart:math';

class LockerActionResult {
  LockerActionResult({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;
}

class OwnerLockerService {
  OwnerLockerService._internal();
  static final OwnerLockerService instance = OwnerLockerService._internal();

  final Random _random = Random();

  Future<LockerActionResult> openLockerManually({
    required String lockerId,
    String? receiverName,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    final isSuccess = _random.nextInt(10) > 1; // 90% success rate for mock
    if (!isSuccess) {
      return LockerActionResult(
        success: false,
        message: 'Locker gagal dibuka. Silakan coba lagi.',
      );
    }

    final lockerLabel = lockerId.toUpperCase().replaceAll('LOCKER-', 'Locker ');
    return LockerActionResult(
      success: true,
      message: '$lockerLabel siap dibuka.',
    );
  }
}
