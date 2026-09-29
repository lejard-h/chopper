// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// Generator: WorkerGenerator 9.3.2 (Squadron 7.4.4)
// **************************************************************************

import 'package:squadron/squadron.dart';

import 'json_decode_service.dart';

void _start$JsonDecodeService(WorkerRequest command) {
  /// VM entry point for JsonDecodeService
  run($JsonDecodeServiceInitializer, command);
}

EntryPoint $getJsonDecodeServiceActivator(SquadronPlatformType platform) {
  if (platform.isVm) {
    return _start$JsonDecodeService;
  } else {
    throw UnsupportedError('${platform.label} not supported.');
  }
}
