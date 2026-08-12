import 'dart:io';

void main() {
  final file = File('lib/services/invoice_pdf_service.dart');
  var content = file.readAsStringSync();
  
  // Replace arguments in generateInvoicePdf
  content = content.replaceFirst(
    '''      List<String>? quotationTerms,
      bool isReceipt = false,
    }) async {
      // Fonts''',
    '''      List<String>? quotationTerms,
      bool isReceipt = false,
      bool isToSameAsClient = true,
      String customTo = '',
    }) async {
      // Fonts'''
  );

  // Replace arguments in printInvoice
  content = content.replaceFirst(
    '''      List<String>? quotationTerms,
      bool isReceipt = false,
    }) async {
      try {''',
    '''      List<String>? quotationTerms,
      bool isReceipt = false,
      bool isToSameAsClient = true,
      String customTo = '',
    }) async {
      try {'''
  );

  file.writeAsStringSync(content);
}
