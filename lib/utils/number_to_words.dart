class NumberToWords {
  static const List<String> _ones = [
    '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
    'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
  ];

  static const List<String> _tens = [
    '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
  ];

  static String convert(int number) {
    if (number == 0) return 'Zero';
    
    return '${_convertRecursive(number)} Rupees Only';
  }

  static String _convertRecursive(int n) {
    if (n < 20) return _ones[n];
    if (n < 100) return '${_tens[n ~/ 10]}${n % 10 != 0 ? ' ${_ones[n % 10]}' : ''}';
    if (n < 1000) return '${_ones[n ~/ 100]} Hundred${n % 100 != 0 ? ' and ${_convertRecursive(n % 100)}' : ''}';
    if (n < 100000) return '${_convertRecursive(n ~/ 1000)} Thousand${n % 1000 != 0 ? ' ${_convertRecursive(n % 1000)}' : ''}';
    if (n < 10000000) return '${_convertRecursive(n ~/ 100000)} Lakh${n % 100000 != 0 ? ' ${_convertRecursive(n % 100000)}' : ''}';
    return '${_convertRecursive(n ~/ 10000000)} Crore${n % 10000000 != 0 ? ' ${_convertRecursive(n % 10000000)}' : ''}';
  }

  static String formatIndianCurrency(double amount) {
    String str = amount.round().toString();
    if (str.length <= 3) return '$str/-';
    
    String lastThree = str.substring(str.length - 3);
    String other = str.substring(0, str.length - 3);
    
    String result = '';
    int count = 0;
    for (int i = other.length - 1; i >= 0; i--) {
      result = other[i] + result;
      count++;
      if (count == 2 && i > 0) {
        result = ',$result';
        count = 0;
      }
    }
    return '$result,$lastThree/-';
  }

  static double parseCurrency(String value) {
    return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  }
}
