Map<String, String> parseUriParameters(Uri uri) {
  Uri _uri = uri;
  if (_uri.hasQuery) {
    final decoded = _uri.toString().replaceAll('#', '&');
    _uri = Uri.parse(decoded);
  } else {
    final uriStr = _uri.toString();
    String decoded;
    // %23 is the encoded of #hash
    // support custom redirect to on flutter web
    if (uriStr.contains('/#%23')) {
      decoded = uriStr.replaceAll('/#%23', '/?');
    } else if (uriStr.contains('/#/')) {
      decoded = uriStr.replaceAll('/#/', '/').replaceAll('%23', '?');
    } else {
      decoded = uriStr.replaceAll('#', '?');
    }
    _uri = Uri.parse(decoded);
  }
  return _uri.queryParameters;
}
