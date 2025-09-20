// Ini adalah test widget Flutter yang sudah disesuaikan.

import 'package:flutter_test/flutter_test.dart';

// Menggunakan nama proyek Anda yang benar: "smartlocker"
import 'package:smartlocker/main.dart'; 

void main() {
  testWidgets('Renders the landing screen smoke test', (WidgetTester tester) async {
    // Build aplikasi kita dan trigger sebuah frame.
    await tester.pumpWidget(const MyApp());

    // Verifikasi bahwa layar awal menampilkan teks "Welcome".
    expect(find.text('Welcome'), findsOneWidget);

    // Verifikasi bahwa ada tombol untuk Owner dan Buyer.
    expect(find.text('Login as Owner/Seller'), findsOneWidget);
    expect(find.text('Login as Buyer'), findsOneWidget);
  });
}