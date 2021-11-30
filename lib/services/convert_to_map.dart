class ConvertToMap {
  Map<String, dynamic> convertDecksToMap(List<dynamic> decoded) {
    final Map<String, dynamic> decodedMap = {
      for (final item in decoded)
        item['_id'].toString(): {
          'lastUpdated': item['lastUpdated'],
          'title': item['title']
        }
    };

    return decodedMap;
  }

  Map<String, dynamic> convertCardsToMap(Map<String, dynamic> decoded) {
    final Map<String, dynamic> decodedMap = {
      for (final item in decoded['cards'])
        item['_id'].toString(): {
          'lastUpdated': item['lastUpdated'],
          'front': item['front'],
          'back': item['back'],
        }
    };
    return decodedMap;
  }
}
