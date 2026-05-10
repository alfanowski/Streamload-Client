// test/plugins/host/html_host_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/plugins/host/html_host.dart';

void main() {
  const sample = '''
<html>
  <body>
    <ul class="titles">
      <li data-id="42"><a href="/title/42">First</a></li>
      <li data-id="43"><a href="/title/43">Second</a></li>
    </ul>
  </body>
</html>
''';

  test('find returns matching elements with text + attr access', () {
    final doc = HtmlHost.parse(sample);
    final items = doc.find('li');
    expect(items, hasLength(2));
    expect(items[0].text(), 'First');
    expect(items[0].attr('data-id'), '42');
    expect(items[1].attr('data-id'), '43');
  });

  test('querySelector returns first match or null', () {
    final doc = HtmlHost.parse(sample);
    expect(doc.querySelector('a')?.attr('href'), '/title/42');
    expect(doc.querySelector('.does-not-exist'), isNull);
  });

  test('html() returns inner HTML of an element', () {
    final doc = HtmlHost.parse(sample);
    final ul = doc.find('ul.titles').single;
    expect(ul.html(), contains('<li data-id="42">'));
  });
}
