// Copyright (c) 2017, joel. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:html/dom.dart';
import 'package:http/http.dart';
import 'package:html/parser.dart';

class Event {
  String imgUrl;
}

Future<Null> scrapeShows() async {

  var client = new Client();

  var response = await client.get('http://diffusion.saguenay.ca/programmation/humour_varietes/');

  var body = response.body;
  var parsedBody = parse(body);
  
  var eventElement = parsedBody.querySelectorAll("ul.event-grid > li.event")[0]; // .map((Element e) => new Event());

  var imgElement = eventElement.querySelector('img');
  var imageUrl = imgElement?.attributes['src'];

  var event = new Event()..imgUrl = imageUrl;


  print('Hello');
}