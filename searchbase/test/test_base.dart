import 'package:searchbase/src/base.dart';
import 'package:test/test.dart';

void main() {
  test('Must throw error if index is not defined', () {
    try {
      new Base("", "", "");
    } catch (e) {
      expect(e, equals('SearchBase: Please provide a valid index.'));
    }
  });
  test('Must throw error if url is not defined', () {
    try {
      new Base("test", "", "");
    } catch (e) {
      expect(e, equals('SearchBase: Please provide a valid url.'));
    }
  });
  test('Must throw error if credential is not defined', () {
    try {
      new Base("test", "http://localhost:800", "");
    } catch (e) {
      expect(e, equals('SearchBase: Please provide valid credentials.'));
    }
  });
  test('Base: check required properties', () {
    var base = Base("test", "http://localhost:8000", "a:b");
    expect(base.index, equals('test'));
    expect(base.url, equals('http://localhost:8000'));
    expect(base.credentials, equals('a:b'));
  });
  test('Base: set headers', () {
    var base = Base("test", "http://localhost:8000", "a:b");
    base.setHeaders({"custom-header": "test"});
    expect(base.headers!['custom-header'], equals('test'));
  });
}
