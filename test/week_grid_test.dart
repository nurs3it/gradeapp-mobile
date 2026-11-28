import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/features/common/week_view.dart';

void main() {
  test('week columns: a sixth of a wide screen, never narrower than a row', () {
    expect(weekColumnWidth(1194), 250); // iPad landscape: 199 is too narrow for a row
    expect(weekColumnWidth(1800), 300);
    expect(weekColumnWidth(800), 250);
  });
}
