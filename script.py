import re
file_path = 'lib/services/invoice_pdf_service.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add _formatAmt function at the start of InvoicePdfService
format_amt_func = '''
  static String _formatAmt(dynamic amt) {
    if (amt == null) return '';
    String str = amt.toString().trim();
    if (str.isEmpty) return '';
    if (str.endsWith('/-')) str = str.substring(0, str.length - 2);
    str = str.replaceAll(RegExp(r'[^\\d.]'), '');
    if (str.isEmpty) return amt.toString();
    double? val = double.tryParse(str);
    if (val == null) return amt.toString();
    return val.toStringAsFixed(2);
  }
'''

if '_formatAmt' not in content:
    content = content.replace('class InvoicePdfService {', 'class InvoicePdfService {' + format_amt_func)

# Replace 'AMOUNT' header alignment
content = content.replace("_cell('AMOUNT', font: bodyBold, align: pw.Alignment.center)", "_cell('AMOUNT', font: bodyBold, align: pw.Alignment.centerRight)")

# Replace item amount alignment
content = content.replace("(item['amount'].toString().endsWith('/-') ? item['amount'].toString() : '${item['amount']}/-'), \n                                    align: pw.Alignment.center)", "_formatAmt(item['amount']), \n                                    align: pw.Alignment.centerRight)")

# In case it is on one line:
content = content.replace("(item['amount'].toString().endsWith('/-') ? item['amount'].toString() : '${item['amount']}/-'), align: pw.Alignment.center)", "_formatAmt(item['amount']), align: pw.Alignment.centerRight)")

# Replace totalAmount
content = re.sub(r"pw\.Text\(\s*totalAmount\.endsWith\('/-'\)\s*\?\s*totalAmount\s*:\s*'\$totalAmount/-',\s*style:\s*pw\.TextStyle\(font:\s*bodyBold,\s*fontSize:\s*9\)\s*\)", r"pw.Text(_formatAmt(totalAmount), style: pw.TextStyle(font: bodyBold, fontSize: 9))", content)

# Replace outstandingAmount
content = re.sub(r"pw\.Text\(\s*outstandingAmount\.endsWith\('/-'\)\s*\?\s*outstandingAmount\s*:\s*'\$outstandingAmount/-',\s*style:\s*pw\.TextStyle\(font:\s*bodyBold,\s*fontSize:\s*9\)\s*\)", r"pw.Text(_formatAmt(outstandingAmount), style: pw.TextStyle(font: bodyBold, fontSize: 9))", content)

# Replace grandTotal
content = re.sub(r"pw\.Text\(\s*grandTotal\.endsWith\('/-'\)\s*\?\s*grandTotal\s*:\s*'\$grandTotal/-',\s*style:\s*pw\.TextStyle\(font:\s*bodyBold,\s*fontSize:\s*9\)\s*\)", r"pw.Text(_formatAmt(grandTotal), style: pw.TextStyle(font: bodyBold, fontSize: 9))", content)

# Replace advanceReceived
content = re.sub(r"pw\.Text\(\s*advanceReceived\.endsWith\('/-'\)\s*\?\s*advanceReceived\s*:\s*'\$advanceReceived/-',\s*style:\s*pw\.TextStyle\(font:\s*bodyBold,\s*fontSize:\s*9\)\s*\)", r"pw.Text(_formatAmt(advanceReceived), style: pw.TextStyle(font: bodyBold, fontSize: 9))", content)

# Replace discount
content = re.sub(r"pw\.Text\('-\$'\s*\+\s*\(discount\.endsWith\('/-'\)\s*\?\s*discount\s*:\s*'\$discount/-'\),\s*style:\s*pw\.TextStyle\(font:\s*bodyBold,\s*fontSize:\s*9,\s*color:\s*PdfColors\.red600\)\)", r"pw.Text('-' + _formatAmt(discount), style: pw.TextStyle(font: bodyBold, fontSize: 9, color: PdfColors.red600))", content)

# Also handle the exact string interpolation format for discount if used
content = re.sub(r"pw\.Text\('-\$\{discount\.endsWith\('/-'\)\s*\?\s*discount\s*:\s*'\$discount/-'\}',\s*style:\s*pw\.TextStyle\(font:\s*bodyBold,\s*fontSize:\s*9,\s*color:\s*PdfColors\.red600\)\)", r"pw.Text('-' + _formatAmt(discount), style: pw.TextStyle(font: bodyBold, fontSize: 9, color: PdfColors.red600))", content)


# Replace balanceDue
content = re.sub(r"pw\.Text\(\s*balanceDue\.endsWith\('/-'\)\s*\?\s*balanceDue\s*:\s*'\$balanceDue/-',\s*style:\s*pw\.TextStyle\(font:\s*bodyBold,\s*fontSize:\s*9\)\s*\)", r"pw.Text(_formatAmt(balanceDue), style: pw.TextStyle(font: bodyBold, fontSize: 9))", content)

# Replace alignments
content = re.sub(r'alignment:\s*pw\.Alignment\.center,\s*padding:\s*const\s*pw\.EdgeInsets\.all\(5\),\s*(?:decoration:[^,]+,)?\s*child:\s*pw\.Text\((?:\'-\'\s*\+\s*)?_formatAmt', lambda m: m.group(0).replace('alignment: pw.Alignment.center,', 'alignment: pw.Alignment.centerRight,'), content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
