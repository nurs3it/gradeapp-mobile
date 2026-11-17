import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp_native/gradeapp_native.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('is a no-op off Android (the host running tests)', () async {
    var called = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('kz.gradeapp/notif_native'),
      (_) async => called = true,
    );
    expect(await GradeappNative.addPublicVersion(id: 1, title: 'GradeApp', body: 'x'), isFalse);
    expect(
      await GradeappNative.promoteLessonLive(id: 1, startMs: 0, endMs: 1, shortText: '5 min'),
      isFalse,
    );
    expect(called, isFalse);
  });
}
