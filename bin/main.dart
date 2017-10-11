// Copyright (c) 2017, joel. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:scraper_poc/event_scraper.dart' as event_scraper;
import 'package:scraper_poc/artist_scraper.dart' as artist_scraper;

main(List<String> arguments) async {
  await event_scraper.scrapeShows();
  await artist_scraper.scrapeArtists();
}
