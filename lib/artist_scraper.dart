import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:scraper_poc/utils.dart';

Duration throttleDuration = const Duration(milliseconds: 500);

class Artist {
  String imgUrl;
  String pageUrl;
  String name;
  String website;
  String facebook;
  String twitter;

  Map toJson() => {
        'imgUrl': imgUrl,
        'pageUrl': pageUrl,
        'name': name,
        'website': website,
        'facebook': facebook,
        'twitter': twitter,
      };
}

Future scrapeArtistDetails(String artistUrl, Artist artist) async {
  print('Scraping $artistUrl');

  var client = new Client();
  var response = await client.get(artistUrl);

  var body = response.body;

  client.close();

  var parsedBody = parse(body);

  var links =
      parsedBody.querySelectorAll('#informationArtiste > a').toList();

  for (var link in links) {
    var url = link.attributes['href'];
    print(url);

    if (url.contains("facebook")) {
      artist.facebook = url;
    }
    else if (url.contains("twitter")) {
      artist.twitter = url;
    }
    else if (url.contains("youtube")) {
      //Don't keep youtube for now
    }
    else {
      artist.website = url;
    }
  }

  /*var price = trimWhitespace(querySelector.text);

  var priceTypeElement =
      parsedBody.querySelector('.price > ul > li > span.price-label');
  var priceType =
      priceTypeElement != null ? trimWhitespace(priceTypeElement.text) : null;

  var buyLink =
      parsedBody.querySelector('.purchase-button > a').attributes['href'];

  var description = trimWhitespace(parsedBody
      .querySelector('.event-details > article > .inner-description')
      .text);

  var name = parsedBody.querySelector('section > .inner-summary > h1').text;

  return new EventDetails()
    ..price = price
    ..priceType = priceType
    ..buyLink = buyLink
    ..description = description
    ..name = name;*/
}

Future<Null> scrapeArtists() async {
  var client = new Client();

  var allArtists = [];

  int pageId = 1;
  bool hasContent = true;
  while (hasContent) {
    print('Scraping page $pageId');
    await new Future.delayed(throttleDuration);
    var response = await client.get(
        'http://www.repertoiredesartistesquebecois.org/section.asp?page=$pageId&no=20');

    var body = response.body;
    var parsedBody = parse(body);

    var artists = parsedBody.querySelectorAll("span.cropCompanie").toList();

    if (artists.length == 0) {
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
        imageUrl = "http://www.repertoiredesartistesquebecois.org/$imageUrl";
      }

      pageUrl = "http://www.repertoiredesartistesquebecois.org/$pageUrl";

      print(name);
      print(imageUrl);
      print(pageUrl);

      var artist = new Artist()
        ..name = trimWhitespace(name)
        ..imgUrl = imageUrl
        ..pageUrl = pageUrl;

      await scrapeArtistDetails(pageUrl, artist);
      allArtists.add(artist);
    }
  }

  client.close();

  var out = new File('out.json');
  const jsonEncoder = const JsonEncoder.withIndent('    ');
  out.writeAsStringSync(jsonEncoder.convert(allArtists));

  print('Scraping done!');
}
