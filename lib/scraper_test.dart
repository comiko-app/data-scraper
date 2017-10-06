// Copyright (c) 2017, joel. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:html/dom.dart';
import 'package:http/http.dart';
import 'package:html/parser.dart';

class Event {
  String imgUrl;
  String date;
  String time;
  String location;
  String name;

  Map toJson() => {
        'imgUrl': imgUrl,
        'date': date,
        'time': time,
        'location': location,
        'name': name,
      };
}

Future<Null> scrapeShows() async {
  var client = new Client();

  var allEvents = [];

  int pageId = 1;
  bool hasContent = true;
  while (hasContent) {
    var response = await client.get(
        'http://diffusion.saguenay.ca/programmation/humour_varietes/page/$pageId');

    if (response.statusCode == 404) {
      hasContent = false;
      continue;
    } else {
      pageId++;
    }

    var body = response.body;
    var parsedBody = parse(body);

    var events = parsedBody
        .querySelectorAll("ul.event-grid > li.event")
        .map((Element eventElement) {
      var imageUrl = eventElement.querySelector('img').attributes['src'];

      var date = eventElement
          .querySelector('.wrap-time > time')
          .attributes['datetime'];
      var time = eventElement.querySelector('.wrap-time > time > .time').text;

      var location = eventElement.querySelector('.location').text;

      var name = eventElement
          .querySelector('.main-block > h2 > a')
          .text
          .replaceAll('\n', '')
          .replaceAll('\t', '');

      var event = new Event()
        ..name = name
        ..imgUrl = imageUrl
        ..date = date
        ..time = time
        ..location = location;

      return event;
    });

    allEvents.addAll(events);
  }

  var out = new File('out.json');
  const jsonEncoder = const JsonEncoder.withIndent('    ');
  out.writeAsStringSync(jsonEncoder.convert(allEvents));

  print('Scraping done!');
}
