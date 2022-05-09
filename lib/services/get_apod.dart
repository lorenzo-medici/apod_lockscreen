import 'dart:io';

import 'package:date_format/date_format.dart' show formatDate, yy, mm, dd;
import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' show Response, get;

import '../models/space_media.dart';

Future<SpaceMedia?> getAPOD({required DateTime date}) async {
  String hdImageUrl;

  // Convert date to correct format for url
  final String dateString = formatDate(date, [yy, mm, dd]);

  // Get page and parse it
  Response response;
  Document document;
  try {
    response =
        await get(Uri.parse('https://apod.nasa.gov/apod/ap$dateString.html'));
    document = parse(response.body);
  } on SocketException {
    rethrow;
  }
  // If encounter error, return null
  if (response.statusCode >= 400) return null;

  final imageHtmlList = document.getElementsByTagName('img');

  // Check for images and if find it, store it's information
  if (imageHtmlList.isNotEmpty) {
    hdImageUrl =
        'https://apod.nasa.gov/apod/${document.getElementsByTagName('a')[1].attributes['href']}';
  } else {
    hdImageUrl = '';
  }

  return SpaceMedia(
    date: date,
    hdImageUrl: hdImageUrl,
  );
}
