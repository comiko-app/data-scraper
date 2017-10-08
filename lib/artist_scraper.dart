import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:html/parser.dart';
import 'package:http/http.dart';

Duration throttleDuration = const Duration(milliseconds: 1);

class Artist {
  String imgUrl;
  String pageUrl;
  String name;
  String website;
  String facebook;
  String twitter;
  String youtube;
  String bio;

  Map toJson() => {
        'imgUrl': imgUrl,
        'pageUrl': pageUrl,
        'name': name,
        'website': website,
        'facebook': facebook,
        'twitter': twitter,
        'youtube': youtube,
        'bio': bio,
      };
}

const String artistsWebsite = "http://www.repertoiredesartistesquebecois.org";

Future<Null> scrapeArtists() async {
  var client = new Client();
  var allArtists = [];

  int pageId = 1;
  bool hasContent = true;

  while (hasContent) {
    var pageUrl = '$artistsWebsite/section.asp?page=$pageId&no=20';
    print('Scraping Url $pageUrl PageNumber $pageId');

    await new Future.delayed(throttleDuration);
    var response = await client.get(pageUrl);

    var body = response.body;

    var parsedBody = parse(body);
    var artists = parsedBody.querySelectorAll("span.cropCompanie").toList();

    if (artists.isEmpty) {
      print('Page is empty $pageId');
      hasContent = false;
      continue;
    } else {
      pageId++;
    }

    for (var artistElement in artists) {
      var name = artistElement.querySelector('img').attributes['title'];
      var imageUrl = artistElement.querySelector('img').attributes['src'];
      var pageUrl = artistElement.querySelector('a').attributes['href'];

      if (!imageUrl.startsWith("http")) {
        imageUrl = "$artistsWebsite/$imageUrl";
      }

      pageUrl = "$artistsWebsite/$pageUrl";

      var artist = new Artist()
        ..name = name.trim()
        ..imgUrl = imageUrl
        ..pageUrl = pageUrl;

      await _scrapeArtistDetails(client, pageUrl, artist);
      allArtists.add(artist);
    }
  }

  client.close();

  var out = new File('artists.json');
  const jsonEncoder = const JsonEncoder.withIndent('    ');
  out.writeAsStringSync(jsonEncoder.convert(allArtists));

  print('Scraping done!');
}

Future _scrapeArtistDetails(
    Client client, String artistUrl, Artist artist) async {
  print('Scraping Url $artistUrl');

  var response;

  var retryCount = 0;
  const maxRetry = 3;

  while (response == null && retryCount < maxRetry) {
    try {
      response = await client.get(artistUrl);
    } catch (e) {
      print(e);
      retryCount++;

      if (retryCount >= maxRetry) {
        rethrow;
      }
    }
  }

  var body = response.body;
  var parsedBody = parse(body);

  var bio = parsedBody.querySelector('#bio');
  artist.bio = bio.text.trim().replaceAll("", "'");

  var links = parsedBody.querySelectorAll('#informationArtiste > a').toList();
  for (var link in links) {
    var url = link.attributes['href'];

    if (url.contains("facebook")) {
      artist.facebook = url;
    } else if (url.contains("twitter")) {
      artist.twitter = url;
    } else if (url.contains("youtube")) {
      artist.youtube = url;
    } else {
      artist.website = url;
    }
  }
}
