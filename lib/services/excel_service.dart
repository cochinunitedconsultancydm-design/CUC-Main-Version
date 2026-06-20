import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/client_license.dart';
import '../models/billing.dart';
import '../models/dsc_record.dart';

class ExcelService {
  Future<String?> exportLicenses(List<ClientLicense> licenses) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Licenses'];
    excel.delete('Sheet1');

    // Header
    sheet.appendRow([
      TextCellValue('Client Name'),
      TextCellValue('License Type'),
      TextCellValue('File Number'),
      TextCellValue('Service Date'),
      TextCellValue('Expiry Date'),
      TextCellValue('Status'),
      TextCellValue('Notes'),
    ]);

    // Data
    for (final l in licenses) {
      sheet.appendRow([
        TextCellValue(l.clientName ?? l.manualClientName ?? '-'),
        TextCellValue(l.licenseTypeName ?? '-'),
        TextCellValue(l.fileNo ?? '-'),
        TextCellValue(l.serviceDate != null ? DateFormat('dd-MM-yyyy').format(l.serviceDate!) : '-'),
        TextCellValue(l.expiryDate != null ? DateFormat('dd-MM-yyyy').format(l.expiryDate!) : '-'),
        TextCellValue(l.status ?? 'Active'),
        TextCellValue(l.notes ?? ''),
      ]);
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final path = '${directory.path}/CUC_Licenses_$timestamp.xlsx';
    final file = File(path);
    await file.writeAsBytes(excel.encode()!);
    return path;
  }

  Future<String?> exportBillings(List<Billing> billings) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Billings'];
    excel.delete('Sheet1');

    // Header
    sheet.appendRow([
      TextCellValue('Invoice No'),
      TextCellValue('Client Name'),
      TextCellValue('Date'),
      TextCellValue('Amount'),
      TextCellValue('Type'),
      TextCellValue('Category'),
      TextCellValue('Authorities'),
    ]);

    // Data
    for (final b in billings) {
      sheet.appendRow([
        TextCellValue(b.invoiceNo ?? '-'),
        TextCellValue(b.clientName ?? '-'),
        TextCellValue(b.date ?? '-'),
        TextCellValue(b.amount ?? '-'),
        TextCellValue(b.type ?? '-'),
        TextCellValue(b.category ?? '-'),
        TextCellValue(b.authorities ?? '-'),
      ]);
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final path = '${directory.path}/CUC_Billings_$timestamp.xlsx';
    final file = File(path);
    await file.writeAsBytes(excel.encode()!);
    return path;
  }

  Future<String?> exportClients(List<Map<String, dynamic>> clients) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Clients'];
    excel.delete('Sheet1');

    // Header
    sheet.appendRow([
      TextCellValue('Name'),
      TextCellValue('Email'),
      TextCellValue('Phone'),
      TextCellValue('Address'),
      TextCellValue('Type of Work'),
      TextCellValue('Case Number'),
      TextCellValue('DOB'),
      TextCellValue('File No'),
    ]);

    // Data
    for (final c in clients) {
      sheet.appendRow([
        TextCellValue(c['name']?.toString() ?? '-'),
        TextCellValue(c['email']?.toString() ?? '-'),
        TextCellValue(c['phone']?.toString() ?? '-'),
        TextCellValue(c['address']?.toString() ?? '-'),
        TextCellValue(c['type_of_work']?.toString() ?? '-'),
        TextCellValue(c['case_number']?.toString() ?? '-'),
        TextCellValue(c['dob']?.toString() ?? '-'),
        TextCellValue(c['file_no']?.toString() ?? '-'),
      ]);
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final path = '${directory.path}/CUC_Clients_$timestamp.xlsx';
    final file = File(path);
    await file.writeAsBytes(excel.encode()!);
    return path;
  }

  Future<String?> exportDsc(List<DscRecord> records) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['DSC'];
    excel.delete('Sheet1');

    // Header
    sheet.appendRow([
      TextCellValue('Client Name'),
      TextCellValue('Username'),
      TextCellValue('Password'),
      TextCellValue('Taken Date'),
      TextCellValue('Expiry Date'),
    ]);

    // Data
    for (final r in records) {
      sheet.appendRow([
        TextCellValue(r.clientName ?? '-'),
        TextCellValue(r.username ?? '-'),
        TextCellValue(r.password ?? '-'),
        TextCellValue(r.dscTakenDate != null ? DateFormat('dd-MM-yyyy').format(r.dscTakenDate!) : '-'),
        TextCellValue(r.dscExpiryDate != null ? DateFormat('dd-MM-yyyy').format(r.dscExpiryDate!) : '-'),
      ]);
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final path = '${directory.path}/CUC_DSC_$timestamp.xlsx';
    final file = File(path);
    await file.writeAsBytes(excel.encode()!);
    return path;
  }

  Future<String?> generateFullBackup(Map<String, List<Map<String, dynamic>>> data) async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    
    data.forEach((tableName, rows) {
      final Sheet sheet = excel[tableName];
      if (rows.isNotEmpty) {
        // Header
        final headers = rows.first.keys.toList();
        sheet.appendRow(headers.map((h) => TextCellValue(h.toUpperCase().replaceAll('_', ' '))).toList());
        
        // Data
        for (final row in rows) {
          sheet.appendRow(headers.map((h) => TextCellValue(row[h]?.toString() ?? '-')).toList());
        }
      } else {
        sheet.appendRow([TextCellValue('No data available in $tableName')]);
      }
    });

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final path = '${directory.path}/CUC_FullBackup_$timestamp.xlsx';
    final file = File(path);
    await file.writeAsBytes(excel.encode()!);
    return path;
  }

  Future<String?> exportFinancialReport({
    required Map<String, dynamic> stats,
    required List<Map<String, dynamic>> expenseBreakdown,
    required List<Map<String, dynamic>> overdueInvoices,
  }) async {
    final excel = Excel.createExcel();
    
    // 1. Overview Sheet
    final Sheet overviewSheet = excel['Financial Overview'];
    excel.delete('Sheet1');
    overviewSheet.appendRow([TextCellValue('Cochin United Financial Report')]);
    overviewSheet.appendRow([TextCellValue('Generated on: ${DateFormat('dd-MMM-yyyy HH:mm').format(DateTime.now())}')]);
    overviewSheet.appendRow([TextCellValue('')]);
    
    overviewSheet.appendRow([TextCellValue('Key Metrics'), TextCellValue('Value (INR)')]);
    overviewSheet.appendRow([TextCellValue('Total Revenue'), TextCellValue(stats['totalRevenue'].toString())]);
    overviewSheet.appendRow([TextCellValue('Total Expenses'), TextCellValue(stats['totalExpenses'].toString())]);
    overviewSheet.appendRow([TextCellValue('Net Balance'), TextCellValue((stats['totalRevenue'] - stats['totalExpenses']).toString())]);
    overviewSheet.appendRow([TextCellValue('Outstanding Amount'), TextCellValue(stats['outstandingBalance'].toString())]);

    // 2. Expense Breakdown Sheet
    final Sheet expenseSheet = excel['Expense Breakdown'];
    expenseSheet.appendRow([TextCellValue('Category'), TextCellValue('Total Expense (INR)')]);
    for (final item in expenseBreakdown) {
      expenseSheet.appendRow([
        TextCellValue(item['category']?.toString() ?? '-'),
        TextCellValue(item['total']?.toString() ?? '0'),
      ]);
    }

    // 3. Overdue Invoices Sheet
    final Sheet overdueSheet = excel['Urgent Overdue Invoices'];
    overdueSheet.appendRow([TextCellValue('Invoice No'), TextCellValue('Client Name'), TextCellValue('Amount (INR)'), TextCellValue('Date')]);
    for (final inv in overdueInvoices) {
      overdueSheet.appendRow([
        TextCellValue(inv['no']?.toString() ?? '-'),
        TextCellValue(inv['client']?.toString() ?? '-'),
        TextCellValue(inv['amount']?.toString() ?? '0'),
        TextCellValue(inv['date'] != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse(inv['date'].toString())) : '-'),
      ]);
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final path = '${directory.path}/CUC_Financial_Report_$timestamp.xlsx';
    final file = File(path);
    await file.writeAsBytes(excel.encode()!);
    return path;
  }
}
