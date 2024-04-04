import 'package:qs_dart/qs_dart.dart' as qs show ListFormat;

/// An enum of all available list format options.
///
/// This is a wrapper around the [qs.ListFormat] enum.
enum ListFormat {
  /// Use brackets to represent list items, for example
  /// `foo[]=123&foo[]=456&foo[]=789`
  brackets(qs.ListFormat.brackets),

  /// Use commas to represent list items, for example
  /// `foo=123,456,789`
  comma(qs.ListFormat.comma),

  /// Repeat the same key to represent list items, for example
  /// `foo=123&foo=456&foo=789`
  repeat(qs.ListFormat.repeat),

  /// Use indices in brackets to represent list items, for example
  /// `foo[0]=123&foo[1]=456&foo[2]=789`
  indices(qs.ListFormat.indices);

  const ListFormat(this.qsListFormat);

  final qs.ListFormat qsListFormat;

  @override
  String toString() => name;
}
