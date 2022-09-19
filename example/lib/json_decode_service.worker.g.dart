// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_decode_service.dart';

// **************************************************************************
// SquadronWorkerGenerator
// **************************************************************************

// Operations map for JsonDecodeService
mixin $JsonDecodeServiceOperations on WorkerService {
  @override
  late final Map<int, CommandHandler> operations =
      _getOperations(this as JsonDecodeService);

  static const int _$jsonDecodeId = 1;

  static Map<int, CommandHandler> _getOperations(JsonDecodeService svc) => {
        _$jsonDecodeId: (r) => svc.jsonDecode(r.args[0]),
      };
}

// Service initializer
JsonDecodeService $JsonDecodeServiceInitializer(WorkerRequest startRequest) =>
    JsonDecodeService();

// Worker for JsonDecodeService
class JsonDecodeServiceWorker extends Worker
    with $JsonDecodeServiceOperations
    implements JsonDecodeService {
  JsonDecodeServiceWorker() : super($JsonDecodeServiceActivator);

  @override
  Future<dynamic> jsonDecode(String source) => send(
        $JsonDecodeServiceOperations._$jsonDecodeId,
        args: [source],
        token: null,
        inspectRequest: false,
        inspectResponse: false,
      );

  @override
  Map<int, CommandHandler> get operations => WorkerService.noOperations;
}

// Worker pool for JsonDecodeService
class JsonDecodeServiceWorkerPool extends WorkerPool<JsonDecodeServiceWorker>
    with $JsonDecodeServiceOperations
    implements JsonDecodeService {
  JsonDecodeServiceWorkerPool({ConcurrencySettings? concurrencySettings})
      : super(() => JsonDecodeServiceWorker(),
            concurrencySettings: concurrencySettings);

  @override
  Future<dynamic> jsonDecode(String source) =>
      execute((w) => w.jsonDecode(source));

  @override
  Map<int, CommandHandler> get operations => WorkerService.noOperations;
}
