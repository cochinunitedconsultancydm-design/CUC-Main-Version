/// Safely parse an int from a dynamic JSON value that might be String, num, or null.
/// This prevents `TypeError: "X": type 'String' is not a subtype of type 'int'`
/// crashes in Flutter Web when AppSync/DynamoDB returns stringified numbers.
int? safeParseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// Safely parse a double from a dynamic JSON value that might be String, num, or null.
double? safeParseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Safely parse a bool from a dynamic JSON value that might be String, bool, or null.
/// This prevents `TypeError: "true": type 'String' is not a subtype of type 'bool?'`
/// crashes in Flutter Web when AppSync/DynamoDB returns stringified booleans.
bool? safeParseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  if (value is num) return value != 0;
  return null;
}
