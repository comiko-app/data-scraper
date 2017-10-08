import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:html/parser.dart';
import 'package:http/http.dart';

Duration throttleDuration = const Duration(milliseconds: 1);

class Event {
  String imgUrl;
  String date;
  String time;
  String location;
  String name;
  String detailsUrl;
  EventDetails details;

  Map toJson() => {
        'imgUrl': imgUrl,
        'date': date,
        'time': time,
        'location': location,
        'name': name,
        'details_url': detailsUrl,
        'details': details,
      };
}

class EventDetails {
  String price;
  String priceType;
  String buyLink;
  String name;
  String description;

  Map toJson() => {
        'price': price,
        'priceType': priceType,
        'buyLink': buyLink,
        'name': name,
        'description': description,
      };
}

Future<Null> scrapeShows() async {
  var client = new Client();
  var allEvents = [];

  int pageId = 1;
  bool hasContent = true;

  while (hasContent) {
    print('Scraping page $pageId');
    await new Future.delayed(throttleDuration);
    var response = await client.get(
        'http://diffusion.saguenay.ca/programmation/humour_varietes/page/$pageId');

    if (response.statusCode == 404) {
      print('Page not found $pageId');
      hasContent = false;
      continue;
    } else {
      pageId++;
    }

    var body = response.body;
    var parsedBody = parse(body);

    var events =
        parsedBody.querySelectorAll("ul.event-grid > li.event").toList();

    for (var eventElement in events) {
      var imageUrl = eventElement.querySelector('img').attributes['src'];

      var date = eventElement
          .querySelector('.wrap-time > time')
          .attributes['datetime'];
      var time = eventElement.querySelector('.wrap-time > time > .time').text;

      var location = eventElement.querySelector('.location').text;

      var detailsPageUrl =
          eventElement.querySelector('.main-block > h2 > a').attributes['href'];

      var details = await _scrapeEventDetails(client, detailsPageUrl);

      var event = new Event()
        ..name = details.name
        ..imgUrl = imageUrl
        ..date = date
        ..time = time
        ..location = location
        ..detailsUrl = detailsPageUrl
        ..details = details;

      allEvents.add(event);
    }
  }

  client.close();

  var out = new File('events.json');
  const jsonEncoder = const JsonEncoder.withIndent('    ');
  out.writeAsStringSync(jsonEncoder.convert(allEvents));

  print('Scraping done!');
}

Future<EventDetails> _scrapeEventDetails(Client client, String eventUrl) async {
  print('Scraping $eventUrl');

  var response = await client.get(eventUrl);

  if (response.statusCode == 508) {
    print('Reached limit on $eventUrl');
    return null;
  }

  var body = response.body;
  var parsedBody = parse(body);

  var querySelector =
      parsedBody.querySelector('.price > ul > li > span.number');

  var price = querySelector.text.trim();

  var priceTypeElement =
      parsedBody.querySelector('.price > ul > li > span.price-label');
  var priceType =
      priceTypeElement != null ? priceTypeElement.text.trim() : null;

  var buyLink =
      parsedBody.querySelector('.purchase-button > a').attributes['href'];

  var description = parsedBody
      .querySelector('.event-details > article > .inner-description')
      .text
      .trim();

  var name = parsedBody.querySelector('section > .inner-summary > h1').text;

  return new EventDetails()
    ..price = price
    ..priceType = priceType
    ..buyLink = buyLink
    ..description = description
    ..name = name;
}
