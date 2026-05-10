part of 'request_converter_interceptor.dart';

/// Stack frame used for iterative query parameter traversal.
sealed class _ParameterConversionFrame {
  const _ParameterConversionFrame();

  factory _ParameterConversionFrame.enter({
    required Object? value,
    required String name,
    required void Function(Object? value) assign,
  }) = _EnterParameterConversionFrame;

  factory _ParameterConversionFrame.exit(Object value) =
      _ExitParameterConversionFrame;
}

final class _EnterParameterConversionFrame extends _ParameterConversionFrame {
  const _EnterParameterConversionFrame({
    required this.value,
    required this.name,
    required this.assign,
  });

  final Object? value;
  final String name;
  final void Function(Object? value) assign;
}

final class _ExitParameterConversionFrame extends _ParameterConversionFrame {
  const _ExitParameterConversionFrame(this.value);

  final Object value;
}
