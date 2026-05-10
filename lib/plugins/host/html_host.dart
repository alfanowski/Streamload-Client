// lib/plugins/host/html_host.dart
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

/// Minimal cheerio-shaped Element wrapper. Each method matches what the
/// plugin contract documents.
class HtmlElement {
  HtmlElement(this._node);
  final dom.Element _node;

  String text() => _node.text;
  String html() => _node.innerHtml;

  String? attr(String name) => _node.attributes[name];

  List<HtmlElement> find(String selector) {
    return _node.querySelectorAll(selector).map(HtmlElement.new).toList();
  }
}

class HtmlDocument {
  HtmlDocument(this._doc);
  final dom.Document _doc;

  List<HtmlElement> find(String selector) {
    return _doc.querySelectorAll(selector).map(HtmlElement.new).toList();
  }

  HtmlElement? querySelector(String selector) {
    final node = _doc.querySelector(selector);
    return node == null ? null : HtmlElement(node);
  }
}

class HtmlHost {
  HtmlHost._();

  static HtmlDocument parse(String text) {
    return HtmlDocument(parser.parse(text));
  }
}
