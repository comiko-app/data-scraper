import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';

var customSearchEngineId = Platform.environment['CUSTOM_SEARCH_ENGINE_ID'];
var apiKey = Platform.environment['API_KEY'];

Future<String> getFirstImageUrlFromGoogleApi(String searchText) async {
  var url = _getGoogleApiUrl();
  url += _getImageQueryParameters(searchText, imageSize: "large");

  dynamic jsonResponse = await _executeGetRequest(url);

  if (jsonResponse != null && jsonResponse["items"] != null)
    return jsonResponse["items"][0]["link"];

  return null;
}

String _getGoogleApiUrl() =>
    "https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$customSearchEngineId";

String _getImageQueryParameters(String searchText, {String imageSize}) {
  var result = "&q=$searchText&searchType=image";

  if (imageSize != null) {
    result += "&imgSize=$imageSize";
  }

  return result;
}

Future<Map<String, dynamic>> _executeGetRequest(String url) async {
  var client = new Client();

  final uri = Uri.parse(url);
  final response = await client.get(uri);

  var data = JSON.decode(response.body);

  client.close();

  return data;
}
