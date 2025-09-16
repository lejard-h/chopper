// This example uses https://github.com/d-markey/squadron_builder

import 'dart:async';
import 'dart:convert' show json;

import 'package:squadron/squadron.dart';

import 'json_decode_service.activator.g.dart';

part 'json_decode_service.worker.g.dart';

@SquadronService.vm()
class JsonDecodeService {
  @SquadronMethod()
  Future<dynamic> jsonDecode(String source) async => json.decode(source);
}
