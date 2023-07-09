/// This example uses https://github.com/d-markey/squadron_builder

import 'dart:async';
import 'dart:convert' show json;

import 'package:squadron/squadron.dart';
import 'package:squadron/squadron_annotations.dart';

import 'json_decode_service.activator.g.dart';

part 'json_decode_service.worker.g.dart';

@SquadronService(
  // disable web to keep the number of generated files low for this example
  web: false,
)
class JsonDecodeService {
  @SquadronMethod()
  Future<dynamic> jsonDecode(String source) async => json.decode(source);
}
