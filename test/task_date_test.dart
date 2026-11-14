import 'package:dayflow/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('valida dias reais, anos bissextos e formato brasileiro', () {
    expect(parseTaskDate('29/02/2028'), DateTime(2028, 2, 29));
    expect(parseTaskDate(' 14/11/2026 '), DateTime(2026, 11, 14));
    for (final value in [
      '',
      '29/02/2026',
      '31/04/2026',
      '00/01/2026',
      '01/13/2026',
      '1/1/2026',
      '01/01/1800',
    ]) {
      expect(parseTaskDate(value), isNull, reason: value);
    }
    expect(formatTaskDate(DateTime(2026, 1, 5)), '05/01/2026');
  });
}
