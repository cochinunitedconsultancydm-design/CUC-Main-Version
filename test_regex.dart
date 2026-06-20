void main() {
  final desc = '''
Description text

[VERIFICATION]
VerifierID: 3
VerifierName: Some Name
Status: Draft

[ADJOURNED]
IsAdjourned: false
Reason: ''';

  final regExp = RegExp(
    r'\[VERIFICATION\]\s*\n\s*VerifierID:\s*(.*?)\s*\n\s*VerifierName:\s*(.*?)\s*\n\s*Status:\s*([^\n\r]+)(?:\s*\n\s*DraftLink:\s*([^\n\r]+))?',
    multiLine: true,
    caseSensitive: false,
  );

  final match = regExp.firstMatch(desc);
  if (match != null) {
    print('Id: ' + match.group(1).toString());
    print('Name: ' + match.group(2).toString());
    print('Status: ' + match.group(3).toString());
    print('DraftLink: ' + match.group(4).toString());
  } else {
    print('No match!');
  }
}
