import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<String> getFirstImageUrlFromGoogleApi(String searchText) async {
  var url = _getGoogleApiUrl("015237388199217754610:yx9xdnmqab8",
      "AIzaSyDRqG50Bhw2s-5qCxTLibIo-KwL-jUtvac");
  url += _getImageQueryParameters(searchText, imageSize: "large");

  dynamic jsonResponse = await _executeGetRequest(url);

  /*for (var item in jsonResponse["items"]) {
    print(item["link"]);
  }*/

  if (jsonResponse != null && jsonResponse["items"] != null)
    return jsonResponse["items"][0]["link"];

  return null;
}

String _getGoogleApiUrl(String customSearchEngineId, String apiKey) =>
    "https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$customSearchEngineId";

String _getImageQueryParameters(String searchText, {String imageSize}) {
  var result = "&q=$searchText&searchType=image";

  if (imageSize != null) {
    result += "&imgSize=$imageSize";
  }

  return result;
}

Future<dynamic> _executeGetRequest(String url) async {
  HttpClient client = new HttpClient();

  final uri = Uri.parse(url);
  final request = await client.getUrl(uri);
  final response = await request.close();

  dynamic responseData;
  final contents = await response.transform(UTF8.decoder).join();

  if (response.headers.contentType.value == ContentType.JSON.value) {
    responseData = JSON.decode(contents);
  }

  client.close();

  return responseData;
}
