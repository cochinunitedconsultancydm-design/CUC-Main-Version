void main() {
  dynamic x = "8";
  try {
    int y = x;
    print("Success");
  } catch (e) {
    print("Error 1: $e");
  }

  try {
    var z = (x as num?)?.toInt();
  } catch (e) {
    print("Error 2: $e");
  }
}
