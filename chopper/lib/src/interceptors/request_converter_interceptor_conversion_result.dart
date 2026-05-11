part of 'request_converter_interceptor.dart';

/// Internal carrier returned by [_convertQueryParameterMap].
///
/// [changed] is `true` if at least one leaf value was replaced by
/// [ParameterConverter.convertParameter] with a value that is not
/// `identical` to the input.
@immutable
class _ConversionResult {
  const _ConversionResult(this.parameters, this.changed);

  final Map<String, dynamic> parameters;
  final bool changed;
}
