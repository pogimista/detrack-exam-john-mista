extension StringExtensions on String {
  String get capitalized =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);
}

extension DateTimeFormatting on DateTime {
  String _pad(int value) => value.toString().padLeft(2, '0');

  /// Formats as mm/dd/yyyy (HH:mm:ss).
  String get formattedDateTime =>
      '${_pad(month)}/${_pad(day)}/$year (${_pad(hour)}:${_pad(minute)}:${_pad(second)})';
}
