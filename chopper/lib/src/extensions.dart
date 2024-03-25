extension StripStringExtension on String {
  /// The string without any leading whitespace and optional [character]
  String leftStrip([String? character]) {
    final String trimmed = trimLeft();

    if (character != null && trimmed.startsWith(character)) {
      return trimmed.substring(1);
    }

    return trimmed;
  }

  /// The string without any trailing whitespace and optional [character]
  String rightStrip([String? character]) {
    final String trimmed = trimRight();

    if (character != null && trimmed.endsWith(character)) {
      return trimmed.substring(0, trimmed.length - 1);
    }

    return trimmed;
  }

  /// The string without any leading and trailing whitespace and optional [character]
  String strip([String? character]) =>
      character != null ? leftStrip(character).rightStrip(character) : trim();
}

extension StatusCodeIntExtension on int {
  bool get isSuccessfulStatusCode => this >= 200 && this < 300;
}
