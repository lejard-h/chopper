// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// Generator: WorkerGenerator 7.1.6 (Squadron 7.1.2+1)
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
