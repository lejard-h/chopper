// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_decode_service.dart';

// **************************************************************************
// Generator: WorkerGenerator 7.1.6 (Squadron 7.1.2+1)
// **************************************************************************

/// Command ids used in operations map
const int _$jsonDecodeId = 1;

/// WorkerService operations for JsonDecodeService
extension on JsonDecodeService {
  OperationsMap _$getOperations() => OperationsMap({
    _$jsonDecodeId: ($req) async {
      final dynamic $res;
      try {
        final $dsr = _$Deser(contextAware: false);
        $res = await jsonDecode($dsr.$0($req.args[0]));
      } finally {}
      return $res;
    },
  });
}

/// Invoker for JsonDecodeService, implements the public interface to invoke the
/// remote service.
mixin _$JsonDecodeService$Invoker on Invoker implements JsonDecodeService {
  @override
  Future<dynamic> jsonDecode(String source) =>
      send(_$jsonDecodeId, args: [source]);
}

/// Facade for JsonDecodeService, implements other details of the service unrelated to
/// invoking the remote service.
mixin _$JsonDecodeService$Facade implements JsonDecodeService {}

/// WorkerService class for JsonDecodeService
class _$JsonDecodeService$WorkerService extends JsonDecodeService
    implements WorkerService {
  _$JsonDecodeService$WorkerService() : super();

  @override
  OperationsMap get operations => _$getOperations();
}

/// Service initializer for JsonDecodeService
WorkerService $JsonDecodeServiceInitializer(WorkerRequest $req) =>
    _$JsonDecodeService$WorkerService();

/// Worker for JsonDecodeService
base class _$JsonDecodeServiceWorker extends Worker
    with _$JsonDecodeService$Invoker, _$JsonDecodeService$Facade
    implements JsonDecodeService {
  _$JsonDecodeServiceWorker({
    PlatformThreadHook? threadHook,
    ExceptionManager? exceptionManager,
  }) : super(
         $JsonDecodeServiceActivator(Squadron.platformType),
         threadHook: threadHook,
         exceptionManager: exceptionManager,
       );

  _$JsonDecodeServiceWorker.vm({
    PlatformThreadHook? threadHook,
    ExceptionManager? exceptionManager,
  }) : super(
         $JsonDecodeServiceActivator(SquadronPlatformType.vm),
         threadHook: threadHook,
         exceptionManager: exceptionManager,
       );

  @override
  List? getStartArgs() => null;

  final _$detachToken = Object();
}

/// Finalizable worker wrapper for JsonDecodeService
base class JsonDecodeServiceWorker
    with Releasable
    implements _$JsonDecodeServiceWorker {
  JsonDecodeServiceWorker._(this._$worker) {
    _finalizer.attach(this, _$worker, detach: _$worker._$detachToken);
  }

  JsonDecodeServiceWorker({
    PlatformThreadHook? threadHook,
    ExceptionManager? exceptionManager,
  }) : this._(
         _$JsonDecodeServiceWorker(
           threadHook: threadHook,
           exceptionManager: exceptionManager,
         ),
       );

  JsonDecodeServiceWorker.vm({
    PlatformThreadHook? threadHook,
    ExceptionManager? exceptionManager,
  }) : this._(
         _$JsonDecodeServiceWorker.vm(
           threadHook: threadHook,
           exceptionManager: exceptionManager,
         ),
       );

  final _$JsonDecodeServiceWorker _$worker;

  static final Finalizer<_$JsonDecodeServiceWorker> _finalizer =
      Finalizer<_$JsonDecodeServiceWorker>((w) {
        try {
          _finalizer.detach(w._$detachToken);
          w.release();
        } catch (_) {
          // finalizers must not throw
        }
      });

  @override
  void release() {
    try {
      _$worker.release();
      super.release();
    } catch (_) {
      // release should not throw
    }
  }

  @override
  List? getStartArgs() => null;

  @override
  Future<dynamic> jsonDecode(String source) => _$worker.jsonDecode(source);

  @override
  ExceptionManager get exceptionManager => _$worker.exceptionManager;

  @override
  Logger? get channelLogger => _$worker.channelLogger;

  @override
  set channelLogger(Logger? value) => _$worker.channelLogger = value;

  @override
  bool get isConnected => _$worker.isConnected;

  @override
  bool get isStopped => _$worker.isStopped;

  @override
  // ignore: deprecated_member_use
  WorkerStat get stats => _$worker.stats;

  @override
  WorkerStat getStats() => _$worker.getStats();

  @override
  Future<Channel> start() => _$worker.start();

  @override
  void stop() => _$worker.stop();

  @override
  void terminate([TaskTerminatedException? ex]) => _$worker.terminate(ex);

  @override
  Channel? getSharedChannel() => _$worker.getSharedChannel();

  @override
  Future<dynamic> send(
    int command, {
    List args = const [],
    CancelationToken? token,
    bool inspectRequest = false,
    bool inspectResponse = false,
  }) => _$worker.send(
    command,
    args: args,
    token: token,
    inspectRequest: inspectRequest,
    inspectResponse: inspectResponse,
  );

  @override
  Stream<dynamic> stream(
    int command, {
    List args = const [],
    CancelationToken? token,
    bool inspectRequest = false,
    bool inspectResponse = false,
  }) => _$worker.stream(
    command,
    args: args,
    token: token,
    inspectRequest: inspectRequest,
    inspectResponse: inspectResponse,
  );

  @override
  Object get _$detachToken => _$worker._$detachToken;

  @override
  final OperationsMap operations = WorkerService.noOperations;
}

/// Worker pool for JsonDecodeService
base class _$JsonDecodeServiceWorkerPool
    extends WorkerPool<JsonDecodeServiceWorker>
    with _$JsonDecodeService$Facade
    implements JsonDecodeService {
  _$JsonDecodeServiceWorkerPool({
    PlatformThreadHook? threadHook,
    ExceptionManager? exceptionManager,
    ConcurrencySettings? concurrencySettings,
  }) : super(
         (ExceptionManager exceptionManager) => JsonDecodeServiceWorker(
           threadHook: threadHook,
           exceptionManager: exceptionManager,
         ),
         concurrencySettings: concurrencySettings,
         exceptionManager: exceptionManager,
       );

  _$JsonDecodeServiceWorkerPool.vm({
    PlatformThreadHook? threadHook,
    ExceptionManager? exceptionManager,
    ConcurrencySettings? concurrencySettings,
  }) : super(
         (ExceptionManager exceptionManager) => JsonDecodeServiceWorker.vm(
           threadHook: threadHook,
           exceptionManager: exceptionManager,
         ),
         concurrencySettings: concurrencySettings,
         exceptionManager: exceptionManager,
       );

  @override
  Future<dynamic> jsonDecode(String source) =>
      execute((w) => w.jsonDecode(source));

  final _$detachToken = Object();
}

/// Finalizable worker pool wrapper for JsonDecodeService
base class JsonDecodeServiceWorkerPool
    with Releasable
    implements _$JsonDecodeServiceWorkerPool {
  JsonDecodeServiceWorkerPool._(this._$pool) {
    _finalizer.attach(this, _$pool, detach: _$pool._$detachToken);
  }

  JsonDecodeServiceWorkerPool({
    PlatformThreadHook? threadHook,
    ExceptionManager? exceptionManager,
    ConcurrencySettings? concurrencySettings,
  }) : this._(
         _$JsonDecodeServiceWorkerPool(
           threadHook: threadHook,
           exceptionManager: exceptionManager,
           concurrencySettings: concurrencySettings,
         ),
       );

  JsonDecodeServiceWorkerPool.vm({
    PlatformThreadHook? threadHook,
    ExceptionManager? exceptionManager,
    ConcurrencySettings? concurrencySettings,
  }) : this._(
         _$JsonDecodeServiceWorkerPool.vm(
           threadHook: threadHook,
           exceptionManager: exceptionManager,
           concurrencySettings: concurrencySettings,
         ),
       );

  final _$JsonDecodeServiceWorkerPool _$pool;

  static final Finalizer<_$JsonDecodeServiceWorkerPool> _finalizer =
      Finalizer<_$JsonDecodeServiceWorkerPool>((p) {
        try {
          _finalizer.detach(p._$detachToken);
          p.release();
        } catch (_) {
          // finalizers must not throw
        }
      });

  @override
  void release() {
    try {
      _$pool.release();
      super.release();
    } catch (_) {
      // release should not throw
    }
  }

  @override
  Future<dynamic> jsonDecode(String source) => _$pool.jsonDecode(source);

  @override
  ExceptionManager get exceptionManager => _$pool.exceptionManager;

  @override
  Logger? get channelLogger => _$pool.channelLogger;

  @override
  set channelLogger(Logger? value) => _$pool.channelLogger = value;

  @override
  ConcurrencySettings get concurrencySettings => _$pool.concurrencySettings;

  @override
  Iterable<WorkerStat> get fullStats => _$pool.fullStats;

  @override
  int get pendingWorkload => _$pool.pendingWorkload;

  @override
  int get maxSize => _$pool.maxSize;

  @override
  int get size => _$pool.size;

  @override
  Iterable<WorkerStat> get stats => _$pool.stats;

  @override
  bool get stopped => _$pool.stopped;

  @override
  void cancelAll([String? message]) => _$pool.cancelAll(message);

  @override
  void cancel(Task task, [String? message]) => _$pool.cancel(task, message);

  @override
  FutureOr<void> start() => _$pool.start();

  @override
  int stop([bool Function(JsonDecodeServiceWorker worker)? predicate]) =>
      _$pool.stop(predicate);

  @override
  void terminate([TaskTerminatedException? ex]) => _$pool.terminate(ex);

  @override
  Object registerWorkerPoolListener(void Function(WorkerStat, bool) listener) =>
      _$pool.registerWorkerPoolListener(listener);

  @override
  void unregisterWorkerPoolListener({
    void Function(WorkerStat, bool)? listener,
    Object? token,
  }) => _$pool.unregisterWorkerPoolListener(listener: listener, token: token);

  @override
  Future<T> execute<T>(
    Future<T> Function(JsonDecodeServiceWorker worker) task, {
    PerfCounter? counter,
  }) => _$pool.execute<T>(task, counter: counter);

  @override
  Stream<T> stream<T>(
    Stream<T> Function(JsonDecodeServiceWorker worker) task, {
    PerfCounter? counter,
  }) => _$pool.stream<T>(task, counter: counter);

  @override
  StreamTask<T> scheduleStreamTask<T>(
    Stream<T> Function(JsonDecodeServiceWorker worker) task, {
    PerfCounter? counter,
  }) => _$pool.scheduleStreamTask<T>(task, counter: counter);

  @override
  ValueTask<T> scheduleValueTask<T>(
    Future<T> Function(JsonDecodeServiceWorker worker) task, {
    PerfCounter? counter,
  }) => _$pool.scheduleValueTask<T>(task, counter: counter);

  @override
  Object get _$detachToken => _$pool._$detachToken;

  @override
  final OperationsMap operations = WorkerService.noOperations;
}

final class _$Deser extends MarshalingContext {
  _$Deser({super.contextAware});
  late final $0 = value<String>();
}
