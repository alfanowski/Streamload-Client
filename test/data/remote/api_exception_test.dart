// test/data/remote/api_exception_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/data/remote/api_exception.dart';

void main() {
  test('formats message with status', () {
    final e = ApiException(401, 'unauthorized');
    expect(e.toString(), 'ApiException(401): unauthorized');
  });

  test('exposes detail when provided', () {
    final e = ApiException(422, 'invalid', detail: {'field': 'email'});
    expect(e.detail, {'field': 'email'});
  });

  test('isUnauthorized helper', () {
    expect(ApiException(401, 'x').isUnauthorized, isTrue);
    expect(ApiException(403, 'x').isUnauthorized, isFalse);
  });

  test('isNotFound helper', () {
    expect(ApiException(404, 'x').isNotFound, isTrue);
    expect(ApiException(500, 'x').isNotFound, isFalse);
  });
}
