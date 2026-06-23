import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';

class InvoicePdfService {
  static Future<Uint8List> generateInvoicePdf({
    required String type,
    required String category,
    required String clientName,
    required String clientAddress,
    required String date,
    required String invoiceNo,
    required String authorities,
    required List<Map<String, dynamic>> items,
    required String totalAmount,
    required String amountInWords,
    String outstandingAmount = '',
    String advanceReceived = '',
    String grandTotal = '',
    String balanceDue = '',
    List<String>? quotationTerms,
    bool isReceipt = false,
  }) async {
    final pdf = pw.Document();

    final isLegal = category == 'Legal';
    final isDM = category == 'Digital Marketing';

    // Load assets safely
    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      debugPrint('Error loading logo: $e');
    }
    
    pw.MemoryImage? signImage;
    try {
      final signData = await rootBundle.load('assets/sign.png');
      signImage = pw.MemoryImage(signData.buffer.asUint8List());
    } catch (e) {
      debugPrint('Error loading signature: $e');
    }
    
    pw.MemoryImage? qrImage;
    try {
      final qrPath = isLegal ? 'assets/legal_qr.jpeg' : 'assets/consultancy_qr.jpeg';
      final qrData = await rootBundle.load(qrPath);
      qrImage = pw.MemoryImage(qrData.buffer.asUint8List());
    } catch (e) {
      debugPrint('Error loading QR: $e');
    }

    // Fonts
    final headerFont = await PdfGoogleFonts.interBold();
    final bodyFont = await PdfGoogleFonts.interRegular();
    final bodyBold = await PdfGoogleFonts.interBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              if (logoImage != null)
                pw.Center(
                  child: pw.Opacity(
                    opacity: 0.1,
                    child: pw.Image(logoImage, width: 480, height: 480),
                  ),
                ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header Row
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (logoImage != null) pw.Image(logoImage, width: 90, height: 90) else pw.SizedBox(width: 90, height: 90),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            isLegal ? 'COCHIN UNITED ADVOCATES' : 
                            isDM ? 'AURORA - COCHIN UNITED CONSULTANCY' : 'COCHIN UNITED CONSULTANCY',
                            style: pw.TextStyle(font: headerFont, fontSize: 16, color: PdfColors.black),
                          ),
                          if (isLegal)
                            pw.Text(
                              'AND LEGAL CONSULTANT',
                              style: pw.TextStyle(font: headerFont, fontSize: 16, color: PdfColors.black),
                            ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            isLegal ? '2ND FLOOR, AMRITA TOWER' : '4th Floor, Mather Square, C- Block,',
                            style: pw.TextStyle(font: bodyFont, fontSize: 8),
                          ),
                          pw.Text(
                            isLegal ? 'COMBARA JUNCTION, ERNAKULAM - 682018' : 'Near North Railway Station, North Railway Station, Ernakulam, Kerala 682018',
                            style: pw.TextStyle(font: bodyFont, fontSize: 8),
                          ),
                          if (!isLegal) pw.Text('Ernakulam, Kerala 682018', style: pw.TextStyle(font: bodyFont, fontSize: 8)),
                          pw.SizedBox(height: 2),
                          pw.Text('email id: cochinunitedconsultancydm@gmail.com', style: pw.TextStyle(font: bodyFont, fontSize: 8, color: PdfColors.blue700)),
                          pw.Text('mob no: +91 8590290105', style: pw.TextStyle(font: bodyFont, fontSize: 8)),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                  pw.SizedBox(height: 12),

                  // Client Info
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('TO', style: pw.TextStyle(font: bodyBold, fontSize: 7, color: PdfColors.grey700)),
                          pw.SizedBox(height: 2),
                          pw.Text(clientName.toUpperCase(), style: pw.TextStyle(font: bodyBold, fontSize: 11)),
                          if (clientAddress.isNotEmpty)
                            pw.Container(width: 200, child: pw.Text(clientAddress, style: pw.TextStyle(font: bodyFont, fontSize: 8))),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('DATE: $date', style: pw.TextStyle(font: bodyBold, fontSize: 9)),
                          pw.Text('${isReceipt ? 'PAYMENT RECEIPT' : (type == 'QUOTATION' ? 'QUOTATION' : 'INVOICE')} NO: $invoiceNo', style: pw.TextStyle(font: bodyBold, fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),

                  // Items Table
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(40),
                      1: const pw.FlexColumnWidth(),
                      2: const pw.FixedColumnWidth(80),
                    },
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                        children: [
                          _cell('Sl. No.', font: bodyBold, align: pw.Alignment.center),
                          _cell('PARTICULARS', font: bodyBold, align: pw.Alignment.center),
                          _cell('AMOUNT', font: bodyBold, align: pw.Alignment.center),
                        ],
                      ),
                      ...() {
                        int slNo = 1;
                        return items.map((item) {
                          final isHeading = item['amount'].toString().trim().isEmpty;
                          final slNoStr = isHeading ? '' : '${slNo++}.';
                          return pw.TableRow(
                            children: [
                              _cell(slNoStr, align: pw.Alignment.center),
                              _cell(item['description'].toString().toUpperCase()),
                              _cell(isHeading ? '' : 
                                  (item['amount'].toString().endsWith('/-') ? item['amount'].toString() : '${item['amount']}/-'), 
                                  align: pw.Alignment.center),
                            ],
                          );
                        }).toList();
                      }(),
                      pw.TableRow(
                        children: [
                          _cell('', border: false),
                          pw.Container(
                            alignment: pw.Alignment.centerRight,
                            padding: const pw.EdgeInsets.all(5),
                            decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                            child: pw.Text('SUBTOTAL', style: pw.TextStyle(font: bodyBold, fontSize: 9)),
                          ),
                          pw.Container(
                            alignment: pw.Alignment.center,
                            padding: const pw.EdgeInsets.all(5),
                            decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                            child: pw.Text(totalAmount.endsWith('/-') ? totalAmount : '$totalAmount/-', style: pw.TextStyle(font: bodyBold, fontSize: 9)),
                          ),
                        ],
                      ),
                      if (outstandingAmount.isNotEmpty && outstandingAmount != '0' && outstandingAmount != '0/-')
                        pw.TableRow(
                          children: [
                            _cell('', border: false),
                            pw.Container(
                              alignment: pw.Alignment.centerRight,
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text('OUTSTANDING', style: pw.TextStyle(font: bodyBold, fontSize: 9)),
                            ),
                            pw.Container(
                              alignment: pw.Alignment.center,
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(outstandingAmount.endsWith('/-') ? outstandingAmount : '$outstandingAmount/-', style: pw.TextStyle(font: bodyBold, fontSize: 9)),
                            ),
                          ],
                        ),
                      if (grandTotal.isNotEmpty && grandTotal != totalAmount)
                        pw.TableRow(
                          children: [
                            _cell('', border: false),
                            pw.Container(
                              alignment: pw.Alignment.centerRight,
                              padding: const pw.EdgeInsets.all(5),
                              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                              child: pw.Text('GRAND TOTAL', style: pw.TextStyle(font: bodyBold, fontSize: 9)),
                            ),
                            pw.Container(
                              alignment: pw.Alignment.center,
                              padding: const pw.EdgeInsets.all(5),
                              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                              child: pw.Text(grandTotal.endsWith('/-') ? grandTotal : '$grandTotal/-', style: pw.TextStyle(font: bodyBold, fontSize: 9)),
                            ),
                          ],
                        ),
                      if (advanceReceived.isNotEmpty && advanceReceived != '0' && advanceReceived != '0/-')
                        pw.TableRow(
                          children: [
                            _cell('', border: false),
                            pw.Container(
                              alignment: pw.Alignment.centerRight,
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text('ADVANCE RECEIVED', style: pw.TextStyle(font: bodyBold, fontSize: 9)),
                            ),
                            pw.Container(
                              alignment: pw.Alignment.center,
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(advanceReceived.endsWith('/-') ? advanceReceived : '$advanceReceived/-', style: pw.TextStyle(font: bodyBold, fontSize: 9)),
                            ),
                          ],
                        ),
                      if (balanceDue.isNotEmpty && balanceDue != '0' && balanceDue != '0/-')
                        pw.TableRow(
                          children: [
                            _cell('', border: false),
                            pw.Container(
                              alignment: pw.Alignment.centerRight,
                              padding: const pw.EdgeInsets.all(5),
                              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                              child: pw.Text('BALANCE DUE', style: pw.TextStyle(font: bodyBold, fontSize: 9)),
                            ),
                            pw.Container(
                              alignment: pw.Alignment.center,
                              padding: const pw.EdgeInsets.all(5),
                              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                              child: pw.Text(balanceDue.endsWith('/-') ? balanceDue : '$balanceDue/-', style: pw.TextStyle(font: bodyBold, fontSize: 9)),
                            ),
                          ],
                        ),
                    ],
                  ),

                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(vertical: 6),
                    child: pw.Text('(${amountInWords.toUpperCase()})', style: pw.TextStyle(font: bodyBold, fontSize: 7), textAlign: pw.TextAlign.center),
                  ),

                  if (quotationTerms != null && quotationTerms.isNotEmpty)
                    _quotationNotes(bodyFont, bodyBold, category, quotationTerms, type)
                  else if (type == 'QUOTATION')
                    _quotationNotes(bodyFont, bodyBold, category, null, type)
                  else
                    pw.Center(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 10),
                        child: pw.Text(
                          'For any clarifications or queries regarding the bill, or to report an error or omission, please contact us at cochinunitedconsultancydm@gmail.com',
                          style: pw.TextStyle(font: bodyFont, fontSize: 7, fontStyle: pw.FontStyle.italic),
                        ),
                      ),
                    ),

                  pw.SizedBox(height: 10),
                  pw.Center(child: pw.Text('We Value Your Relationship With Us!', style: pw.TextStyle(font: bodyBold, fontSize: 9))),
                  pw.SizedBox(height: 20),

                  // Bottom Section
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Bank Details
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Bank Details:', style: pw.TextStyle(font: bodyBold, fontSize: 8)),
                          pw.SizedBox(height: 4),
                          if (isLegal) ...[
                            _bankRow('A/c no', ': 0522202100000749', bodyFont),
                            _bankRow('IFSC Code', ': PUNB0052220', bodyFont),
                            pw.Text('PUNJAB NATIONAL BANK', style: pw.TextStyle(font: bodyFont, fontSize: 7)),
                            pw.Text('Branch- Ernakulam (Market Road)', style: pw.TextStyle(font: bodyFont, fontSize: 7)),
                          ] else ...[
                            _bankRow('A/c No', ': 41731333716', bodyFont),
                            _bankRow('IFSC Code', ': SBIN0010564', bodyFont),
                            pw.Text('State Bank of India', style: pw.TextStyle(font: bodyFont, fontSize: 7)),
                            pw.Text('Branch – High court Branch', style: pw.TextStyle(font: bodyFont, fontSize: 7)),
                          ],
                        ],
                      ),
                      // QR Code
                      pw.Column(
                        children: [
                          if (qrImage != null) pw.Image(qrImage, width: 110, height: 110) else pw.SizedBox(width: 110, height: 110),
                        ],
                      ),
                      // Signature
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          if (signImage != null)
                            pw.Container(
                              width: 150,
                              child: pw.Image(signImage, fit: pw.BoxFit.contain),
                            )
                          else
                            pw.SizedBox(height: 40),
                          pw.SizedBox(height: 2),
                          if (isLegal) 
                            pw.Text('Authorised Signatory', style: pw.TextStyle(font: bodyFont, fontSize: 7))
                          else
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                if (authorities == 'CUC' || authorities == 'AA')
                                  pw.Text(
                                    (authorities == 'CUC' ? 'Cochin United Consultancy' : 'Aakrithi').toUpperCase(),
                                    style: pw.TextStyle(font: bodyBold, fontSize: 8),
                                  ),
                                pw.Text('Authorised Signatory', style: pw.TextStyle(font: bodyFont, fontSize: 7)),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _cell(String text, {pw.Font? font, pw.Alignment align = pw.Alignment.centerLeft, bool border = true}) {
    return pw.Container(
      alignment: align,
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 9)),
    );
  }

  static pw.Widget _bankRow(String label, String value, pw.Font f) => pw.Row(
    children: [
      pw.SizedBox(width: 50, child: pw.Text(label, style: pw.TextStyle(font: f, fontSize: 7))),
      pw.Text(value, style: pw.TextStyle(font: f, fontSize: 7)),
    ],
  );

  static pw.Widget _quotationNotes(pw.Font f, pw.Font fb, String category, List<String>? customTerms, String type) {
    final bool isDM = category == 'Digital Marketing';
    
    final defaultNotes = isDM ? [
      'This quotation is not comprehensive. Inspection charges, additional consultation, statutory fees, and any additional work required as per instructions from authorities are excluded from this quotation and will be charged separately, if required.',
      'Any increase in platform charges, subscription fees, or additional expenses related to digital tools during the project period must be borne by you.',
      'We are not liable for delays caused by social media platform outages, algorithmic changes, technical glitches, policy updates, or any external factors beyond our control.',
      'If additional resources, materials, or approvals are required for content creation or ad campaigns, your timely cooperation is essential. Any extra costs incurred—including paid assets, ad budgets, or third-party service fees—must be reimbursed by you.',
      'Please provide prompt approvals for content, artwork, ad copies, and share required credentials (logins, OTPs, verification codes) on time to avoid delays.',
      'In case of any misunderstanding, miscommunication, or unethical behavior from our team, please contact our Client Relationship Manager immediately.',
    ] : [
      'This quotation is not comprehensive. Inspection charges, additional consultation, statutory fees, and any additional work required as per instructions from authorities are excluded from this quotation and will be charged separately, if required.',
      'Any increase in government fees or additional expenses during the application process must be borne by you.',
      'We are not liable for delays caused by changes in government regulations, system failures, network issues, or unforeseen circumstances beyond our control.',
      'If additional documents or steps are required, your cooperation and support will be necessary, and any extra expenses incurred must be reimbursed by you.',
      'Please regularly follow up on the application process and promptly share any required OTPs.',
      'In case of any unethical practices or misbehavior by our staff, please contact our Client Relationship Manager immediately.',
    ];

    final notes = customTerms ?? defaultNotes;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('NB:', style: pw.TextStyle(font: fb, fontSize: 8)),
        pw.SizedBox(height: 4),
        ...notes.map((note) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2, left: 10),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('• ', style: pw.TextStyle(font: f, fontSize: 7)),
              pw.Expanded(child: pw.Text(note, style: pw.TextStyle(font: f, fontSize: 7))),
            ],
          ),
        )),
        if (type == 'QUOTATION') ...[
          pw.SizedBox(height: 12),
          pw.Text(
            'To accept this quotation, Please sign here and return: ..................................................................................',
            style: pw.TextStyle(font: f, fontSize: 7),
          ),
        ],
      ],
    );
  }

  static Future<void> printInvoice({
    required String type,
    required String category,
    required String clientName,
    required String clientAddress,
    required String date,
    required String invoiceNo,
    required String authorities,
    required List<Map<String, dynamic>> items,
    required String totalAmount,
    required String amountInWords,
    String outstandingAmount = '',
    String advanceReceived = '',
    String grandTotal = '',
    String balanceDue = '',
    List<String>? quotationTerms,
    bool isReceipt = false,
  }) async {
    try {
      final pdfBytes = await generateInvoicePdf(
        type: type,
        category: category,
        clientName: clientName,
        clientAddress: clientAddress,
        date: date,
        invoiceNo: invoiceNo,
        authorities: authorities,
        items: items,
        totalAmount: totalAmount,
        amountInWords: amountInWords,
        outstandingAmount: outstandingAmount,
        advanceReceived: advanceReceived,
        grandTotal: grandTotal,
        balanceDue: balanceDue,
        quotationTerms: quotationTerms,
        isReceipt: isReceipt,
      );
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
    } catch (e) {
      debugPrint('Error printing invoice: $e');
    }
  }
}
