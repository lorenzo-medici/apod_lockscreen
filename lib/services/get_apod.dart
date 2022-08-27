import 'dart:io';

import 'package:date_format/date_format.dart' show formatDate, yy, mm, dd;
import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' show Response, get;

import '../models/space_media.dart';
import '../utils.dart';

Future<SpaceMedia?> getAPOD({required DateTime date}) async {
  String hdImageUrl;
  String title;
  String description;

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

  // Get title and credits
  final List centerList = document.getElementsByTagName('center');
  if (centerList.isNotEmpty) {
    title =
        document.getElementsByTagName('center')[1].children[0].innerHtml.trim();
  } else {
    title = '';
  }
  // Get description
  final List paraList = document.getElementsByTagName('p');
  if (paraList.isNotEmpty) {
    description = Utils.removeNewLinesAndExtraSpace(
        document.getElementsByTagName('p')[2].innerHtml.substring(24).trim());
  } else {
    description = '';
  }

  return SpaceMedia(
    date: date,
    hdImageUrl: hdImageUrl,
    title: title,
    description: description,
  );
}
