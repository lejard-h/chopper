// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_decode_service.dart';

// **************************************************************************
// Generator: WorkerGenerator 2.4.1
// **************************************************************************

/// WorkerService class for JsonDecodeService
class _$JsonDecodeServiceWorkerService extends JsonDecodeService
    implements WorkerService {
  _$JsonDecodeServiceWorkerService() : super();

  @override
  Map<int, CommandHandler> get operations => _operations;

  late final Map<int, CommandHandler> _operations = {
    _$jsonDecodeId: ($) => jsonDecode($.args[0])
  };

  static const int _$jsonDecodeId = 1;
}

/// Service initializer for JsonDecodeService
WorkerService $JsonDecodeServiceInitializer(WorkerRequest startRequest) =>
    _$JsonDecodeServiceWorkerService();

/// Operations map for JsonDecodeService
@Deprecated(
    'squadron_builder now supports "plain old Dart objects" as services. '
    'Services do not need to derive from WorkerService nor do they need to mix in '
    'with \$JsonDecodeServiceOperations anymore.')
mixin $JsonDecodeServiceOperations on WorkerService {
  @override
  // not needed anymore, generated for compatibility with previous versions of squadron_builder
  Map<int, CommandHandler> get operations => WorkerService.noOperations;
}

/// Worker for JsonDecodeService
class _$JsonDecodeServiceWorker extends Worker implements JsonDecodeService {
  _$JsonDecodeServiceWorker({PlatformWorkerHook? platformWorkerHook})
      : super($JsonDecodeServiceActivator,
            platformWorkerHook: platformWorkerHook);

  @override
  Future<dynamic> jsonDecode(String source) =>
      send(_$JsonDecodeServiceWorkerService._$jsonDecodeId, args: [source]);

  final Object _detachToken = Object();
}

/// Finalizable worker wrapper for JsonDecodeService
class JsonDecodeServiceWorker implements _$JsonDecodeServiceWorker {
  JsonDecodeServiceWorker({PlatformWorkerHook? platformWorkerHook})
      : _$w =
            _$JsonDecodeServiceWorker(platformWorkerHook: platformWorkerHook) {
    _finalizer.attach(this, _$w, detach: _$w._detachToken);
  }

  final _$JsonDecodeServiceWorker _$w;

  static final Finalizer<_$JsonDecodeServiceWorker> _finalizer =
      Finalizer<_$JsonDecodeServiceWorker>((w) {
    try {
      _finalizer.detach(w._detachToken);
      w.stop();
    } catch (ex) {
      // finalizers must not throw
    }
  });

  @override
  Future<dynamic> jsonDecode(String source) => _$w.jsonDecode(source);

  @override
  List get args => _$w.args;

  @override
  Channel? get channel => _$w.channel;

  @override
  Duration get idleTime => _$w.idleTime;

  @override
  bool get isStopped => _$w.isStopped;

  @override
  int get maxWorkload => _$w.maxWorkload;

  @override
  WorkerStat get stats => _$w.stats;

  @override
  String get status => _$w.status;

  @override
  int get totalErrors => _$w.totalErrors;

  @override
  int get totalWorkload => _$w.totalWorkload;

  @override
  Duration get upTime => _$w.upTime;

  @override
  String get workerId => _$w.workerId;

  @override
  int get workload => _$w.workload;

  @override
  PlatformWorkerHook? get platformWorkerHook => _$w.platformWorkerHook;

  @override
  Future<Channel> start() => _$w.start();

  @override
  void stop() => _$w.stop();

  @override
  Future<T> send<T>(int command,
          {List args = const [],
          CancellationToken? token,
          bool inspectRequest = false,
          bool inspectResponse = false}) =>
      _$w.send<T>(command,
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
      _$w.stream<T>(command,
          args: args,
          token: token,
          inspectRequest: inspectRequest,
          inspectResponse: inspectResponse);

  @override
  Object get _detachToken => _$w._detachToken;

  @override
  Map<int, CommandHandler> get operations => WorkerService.noOperations;
}

/// Worker pool for JsonDecodeService
class _$JsonDecodeServiceWorkerPool extends WorkerPool<JsonDecodeServiceWorker>
    implements JsonDecodeService {
  _$JsonDecodeServiceWorkerPool(
      {ConcurrencySettings? concurrencySettings,
      PlatformWorkerHook? platformWorkerHook})
      : super(
            () =>
                JsonDecodeServiceWorker(platformWorkerHook: platformWorkerHook),
            concurrencySettings: concurrencySettings);

  @override
  Future<dynamic> jsonDecode(String source) =>
      execute((w) => w.jsonDecode(source));

  final Object _detachToken = Object();
}

/// Finalizable worker pool wrapper for JsonDecodeService
class JsonDecodeServiceWorkerPool implements _$JsonDecodeServiceWorkerPool {
  JsonDecodeServiceWorkerPool(
      {ConcurrencySettings? concurrencySettings,
      PlatformWorkerHook? platformWorkerHook})
      : _$p = _$JsonDecodeServiceWorkerPool(
            concurrencySettings: concurrencySettings,
            platformWorkerHook: platformWorkerHook) {
    _finalizer.attach(this, _$p, detach: _$p._detachToken);
  }

  final _$JsonDecodeServiceWorkerPool _$p;

  static final Finalizer<_$JsonDecodeServiceWorkerPool> _finalizer =
      Finalizer<_$JsonDecodeServiceWorkerPool>((p) {
    try {
      _finalizer.detach(p._detachToken);
      p.stop();
    } catch (ex) {
      // finalizers must not throw
    }
  });

  @override
  Future<dynamic> jsonDecode(String source) => _$p.jsonDecode(source);

  @override
  ConcurrencySettings get concurrencySettings => _$p.concurrencySettings;

  @override
  Iterable<WorkerStat> get fullStats => _$p.fullStats;

  @override
  int get maxConcurrency => _$p.maxConcurrency;

  @override
  int get maxParallel => _$p.maxParallel;

  @override
  int get maxSize => _$p.maxSize;

  @override
  int get maxWorkers => _$p.maxWorkers;

  @override
  int get maxWorkload => _$p.maxWorkload;

  @override
  int get minWorkers => _$p.minWorkers;

  @override
  int get pendingWorkload => _$p.pendingWorkload;

  @override
  int get size => _$p.size;

  @override
  Iterable<WorkerStat> get stats => _$p.stats;

  @override
  bool get stopped => _$p.stopped;

  @override
  int get totalErrors => _$p.totalErrors;

  @override
  int get totalWorkload => _$p.totalWorkload;

  @override
  int get workload => _$p.workload;

  @override
  void cancel([Task? task, String? message]) => _$p.cancel(task, message);

  @override
  FutureOr start() => _$p.start();

  @override
  int stop([bool Function(JsonDecodeServiceWorker worker)? predicate]) =>
      _$p.stop(predicate);

  @override
  Object registerWorkerPoolListener(
          void Function(JsonDecodeServiceWorker worker, bool removed)
              listener) =>
      _$p.registerWorkerPoolListener(listener);

  @override
  void unregisterWorkerPoolListener(
          {void Function(JsonDecodeServiceWorker worker, bool removed)?
              listener,
          Object? token}) =>
      _$p.unregisterWorkerPoolListener(listener: listener, token: token);

  @override
  Future<T> execute<T>(Future<T> Function(JsonDecodeServiceWorker worker) task,
          {PerfCounter? counter}) =>
      _$p.execute<T>(task, counter: counter);

  @override
  StreamTask<T> scheduleStream<T>(
          Stream<T> Function(JsonDecodeServiceWorker worker) task,
          {PerfCounter? counter}) =>
      _$p.scheduleStream<T>(task, counter: counter);

  @override
  ValueTask<T> scheduleTask<T>(
          Future<T> Function(JsonDecodeServiceWorker worker) task,
          {PerfCounter? counter}) =>
      _$p.scheduleTask<T>(task, counter: counter);

  @override
  Stream<T> stream<T>(Stream<T> Function(JsonDecodeServiceWorker worker) task,
          {PerfCounter? counter}) =>
      _$p.stream<T>(task, counter: counter);

  @override
  Object get _detachToken => _$p._detachToken;

  @override
  Map<int, CommandHandler> get operations => WorkerService.noOperations;
}
