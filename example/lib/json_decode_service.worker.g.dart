// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_decode_service.dart';

// **************************************************************************
// WorkerGenerator
// **************************************************************************

// Operations map for JsonDecodeService
mixin $JsonDecodeServiceOperations on WorkerService {
  @override
  late final Map<int, CommandHandler> operations =
      _getOperations(this as JsonDecodeService);

  static const int _$jsonDecodeId = 1;

  static Map<int, CommandHandler> _getOperations(JsonDecodeService svc) =>
      {_$jsonDecodeId: (req) => svc.jsonDecode(req.args[0])};
}

// Service initializer
JsonDecodeService $JsonDecodeServiceInitializer(WorkerRequest startRequest) =>
    JsonDecodeService();

// Worker for JsonDecodeService
class _JsonDecodeServiceWorker extends Worker
    with $JsonDecodeServiceOperations
    implements JsonDecodeService {
  _JsonDecodeServiceWorker() : super($JsonDecodeServiceActivator);

  @override
  Future<dynamic> jsonDecode(String source) => send(
        $JsonDecodeServiceOperations._$jsonDecodeId,
        args: [source],
      );

  @override
  Map<int, CommandHandler> get operations => WorkerService.noOperations;

  final Object _detachToken = Object();
}

// Finalizable worker wrapper for JsonDecodeService
class JsonDecodeServiceWorker implements _JsonDecodeServiceWorker {
  JsonDecodeServiceWorker() : _worker = _JsonDecodeServiceWorker() {
    _finalizer.attach(this, _worker, detach: _worker._detachToken);
  }

  final _JsonDecodeServiceWorker _worker;

  static final Finalizer<_JsonDecodeServiceWorker> _finalizer =
      Finalizer<_JsonDecodeServiceWorker>((w) {
    try {
      _finalizer.detach(w._detachToken);
      w.stop();
    } catch (ex) {
      // finalizers must not throw
    }
  });

  @override
  Future<dynamic> jsonDecode(String source) => _worker.jsonDecode(source);

  @override
  Map<int, CommandHandler> get operations => _worker.operations;

  @override
  List get args => _worker.args;

  @override
  Channel? get channel => _worker.channel;

  @override
  Duration get idleTime => _worker.idleTime;

  @override
  bool get isStopped => _worker.isStopped;

  @override
  int get maxWorkload => _worker.maxWorkload;

  @override
  WorkerStat get stats => _worker.stats;

  @override
  String get status => _worker.status;

  @override
  int get totalErrors => _worker.totalErrors;

  @override
  int get totalWorkload => _worker.totalWorkload;

  @override
  Duration get upTime => _worker.upTime;

  @override
  String get workerId => _worker.workerId;

  @override
  int get workload => _worker.workload;

  @override
  Future<Channel> start() => _worker.start();

  @override
  void stop() => _worker.stop();

  @override
  Future<T> send<T>(int command,
          {List args = const [],
          CancellationToken? token,
          bool inspectRequest = false,
          bool inspectResponse = false}) =>
      _worker.send<T>(command,
          args: args,
          token: token,
          inspectRequest: inspectRequest,
          inspectResponse: inspectResponse);

  @override
  Stream<T> stream<T>(int command,
          {List args = const [],
          CancellationToken? token,
          bool inspectRequest = false,
          bool inspectResponse = false}) =>
      _worker.stream<T>(command,
          args: args,
          token: token,
          inspectRequest: inspectRequest,
          inspectResponse: inspectResponse);

  @override
  Object get _detachToken => _worker._detachToken;
}

// Worker pool for JsonDecodeService
class _JsonDecodeServiceWorkerPool extends WorkerPool<JsonDecodeServiceWorker>
    with $JsonDecodeServiceOperations
    implements JsonDecodeService {
  _JsonDecodeServiceWorkerPool({ConcurrencySettings? concurrencySettings})
      : super(() => JsonDecodeServiceWorker(),
            concurrencySettings: concurrencySettings);

  @override
  Future<dynamic> jsonDecode(String source) =>
      execute(($w) => $w.jsonDecode(source));

  @override
  Map<int, CommandHandler> get operations => WorkerService.noOperations;

  final Object _detachToken = Object();
}

// Finalizable worker pool wrapper for JsonDecodeService
class JsonDecodeServiceWorkerPool implements _JsonDecodeServiceWorkerPool {
  JsonDecodeServiceWorkerPool({ConcurrencySettings? concurrencySettings})
      : _pool = _JsonDecodeServiceWorkerPool(
            concurrencySettings: concurrencySettings) {
    _finalizer.attach(this, _pool, detach: _pool._detachToken);
  }

  final _JsonDecodeServiceWorkerPool _pool;

  static final Finalizer<_JsonDecodeServiceWorkerPool> _finalizer =
      Finalizer<_JsonDecodeServiceWorkerPool>((p) {
    try {
      _finalizer.detach(p._detachToken);
      p.stop();
    } catch (ex) {
      // finalizers must not throw
    }
  });

  @override
  Future<dynamic> jsonDecode(String source) => _pool.jsonDecode(source);

  @override
  Map<int, CommandHandler> get operations => _pool.operations;

  @override
  ConcurrencySettings get concurrencySettings => _pool.concurrencySettings;

  @override
  Iterable<WorkerStat> get fullStats => _pool.fullStats;

  @override
  int get maxConcurrency => _pool.maxConcurrency;

  @override
  int get maxParallel => _pool.maxParallel;

  @override
  int get maxSize => _pool.maxSize;

  @override
  int get maxWorkers => _pool.maxWorkers;

  @override
  int get maxWorkload => _pool.maxWorkload;

  @override
  int get minWorkers => _pool.minWorkers;

  @override
  int get pendingWorkload => _pool.pendingWorkload;

  @override
  int get size => _pool.size;

  @override
  Iterable<WorkerStat> get stats => _pool.stats;

  @override
  bool get stopped => _pool.stopped;

  @override
  int get totalErrors => _pool.totalErrors;

  @override
  int get totalWorkload => _pool.totalWorkload;

  @override
  int get workload => _pool.workload;

  @override
  void cancel([Task? task, String? message]) => _pool.cancel(task, message);

  @override
  FutureOr start() => _pool.start();

  @override
  int stop([bool Function(JsonDecodeServiceWorker worker)? predicate]) =>
      _pool.stop(predicate);

  @override
  Object registerWorkerPoolListener(
          void Function(JsonDecodeServiceWorker worker, bool removed)
              listener) =>
      _pool.registerWorkerPoolListener(listener);

  @override
  void unregisterWorkerPoolListener(
          {void Function(JsonDecodeServiceWorker worker, bool removed)?
              listener,
          Object? token}) =>
      _pool.unregisterWorkerPoolListener(listener: listener, token: token);

  @override
  Future<T> execute<T>(Future<T> Function(JsonDecodeServiceWorker worker) task,
          {PerfCounter? counter}) =>
      _pool.execute<T>(task, counter: counter);

  @override
  StreamTask<T> scheduleStream<T>(
          Stream<T> Function(JsonDecodeServiceWorker worker) task,
          {PerfCounter? counter}) =>
      _pool.scheduleStream<T>(task, counter: counter);

  @override
  ValueTask<T> scheduleTask<T>(
          Future<T> Function(JsonDecodeServiceWorker worker) task,
          {PerfCounter? counter}) =>
      _pool.scheduleTask<T>(task, counter: counter);

  @override
  Stream<T> stream<T>(Stream<T> Function(JsonDecodeServiceWorker worker) task,
          {PerfCounter? counter}) =>
      _pool.stream<T>(task, counter: counter);

  @override
  Object get _detachToken => _pool._detachToken;
}
