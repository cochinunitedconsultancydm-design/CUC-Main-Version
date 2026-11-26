import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import '../models/billing.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../utils/number_to_words.dart';
import 'invoice_pdf_service.dart';
import 'supabase_backup_service.dart';
import 'backup_aware_api.dart';
import 'meta_service.dart';
import 'billing_service.dart';
import 'logging_service.dart';

class ReceiptSendResult {
  final bool success;
  final bool whatsAppSent;
  final bool emailSent;
  final String? receiptPdfUrl;
  final String? message;
  final String? error;
  final String? phone;
  final String? email;

  ReceiptSendResult({
    required this.success,
    this.whatsAppSent = false,
    this.emailSent = false,
    this.receiptPdfUrl,
    this.message,
    this.error,
    this.phone,
    this.email,
  });
}

class GeneratedReceiptData {
  final String? publicUrl;
  final Uint8List? pdfBytes;

  GeneratedReceiptData({this.publicUrl, this.pdfBytes});
}

class ReceiptService {
  static final ReceiptService _instance = ReceiptService._internal();
  factory ReceiptService() => _instance;
  ReceiptService._internal();

  /// Generates the official Receipt PDF and uploads it to cloud storage.
  Future<GeneratedReceiptData> generateAndUploadReceiptPdf({
    required String invoiceNo,
    required String clientName,
    String clientAddress = '',
    String date = '',
    String authorities = '',
    List<Map<String, dynamic>> items = const [],
    required String totalAmount,
    required String amountInWords,
    String paymentMode = 'Online',
    String? transactionId,
  }) async {
    try {
      final effectiveDate = date.isNotEmpty ? date : DateTime.now().toString().split(' ')[0];

      final pdfBytes = await InvoicePdfService.generateInvoicePdf(
        type: 'INVOICE',
        category: 'Consultancy',
        clientName: clientName,
        clientAddress: clientAddress,
        date: effectiveDate,
        invoiceNo: invoiceNo,
        authorities: authorities,
        items: items,
        totalAmount: totalAmount,
        amountInWords: amountInWords,
        outstandingAmount: '0/-',
        advanceReceived: totalAmount,
        grandTotal: totalAmount,
        balanceDue: '0/-',
        isReceipt: true,
      );

      final cleanInvoice = invoiceNo.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final s3Key = 'public/receipts/Receipt_${cleanInvoice}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // 1. Upload to Supabase Storage (publicly accessible for WhatsApp attachments & client download)
      try {
        await SupabaseBackupService().backupFile(s3Key, pdfBytes);
      } catch (e) {
        debugPrint('Supabase receipt backup notice: $e');
      }

      // 2. Upload to Amplify S3
      try {
        await Amplify.Storage.uploadFile(
          localFile: AWSFile.fromData(pdfBytes),
          path: StoragePath.fromString(s3Key),
        ).result;
      } catch (e) {
        debugPrint('Amplify S3 receipt upload notice: $e');
      }

      final publicUrl = 'https://bzxtgiqjgfojblezdubd.supabase.co/storage/v1/object/public/cuc-backups/$s3Key';
      return GeneratedReceiptData(publicUrl: publicUrl, pdfBytes: pdfBytes);
    } catch (e) {
      debugPrint('Error generating/uploading receipt PDF: $e');
      return GeneratedReceiptData();
    }
  }

  /// Automatically generate and send official receipt to client via WhatsApp AND Email
  Future<ReceiptSendResult> sendReceiptAutomatically({
    required dynamic billing, // Billing or amplify_models.Billings
    double? paidAmount,
    String? paymentId,
    String? paymentMode,
    String? targetPhone,
    String? targetEmail,
    bool forceSend = false,
  }) async {
    try {
      final cfg = await MetaConfig.load();
      if (!cfg.autoSendReceiptOnPayment && !forceSend) {
        debugPrint('Auto-send receipt is disabled in settings.');
        return ReceiptSendResult(
          success: false,
          message: 'Auto-send receipt is disabled in settings.',
        );
      }

      // 1. Extract invoice metadata
      String invoiceNo = '';
      String clientName = '';
      String totalAmount = '';
      String clientAddress = '';
      String authorities = '';
      List<Map<String, dynamic>> items = [];
      Map<String, dynamic> dataMap = {};

      if (billing is Billing) {
        invoiceNo = billing.invoiceNo ?? '';
        clientName = billing.clientName ?? '';
        totalAmount = billing.amount ?? '0/-';
        authorities = billing.authorities ?? '';
        dataMap = billing.data != null ? Map<String, dynamic>.from(billing.data!) : {};
        items = billing.items;
      } else if (billing is amplify_models.Billings) {
        invoiceNo = billing.invoice_no ?? '';
        clientName = billing.client_name ?? '';
        totalAmount = billing.amount ?? '0/-';
        authorities = billing.authorities ?? '';
        if (billing.data != null && billing.data!.isNotEmpty) {
          try {
            dataMap = Map<String, dynamic>.from(jsonDecode(billing.data!));
            if (dataMap['items'] is List) {
              items = (dataMap['items'] as List).whereType<Map<String, dynamic>>().toList();
            }
          } catch (_) {}
        }
      }

      clientAddress = dataMap['client_address']?.toString() ?? '';

      // 2. Resolve client phone number
      String recipientPhone = targetPhone?.trim() ?? '';
      if (recipientPhone.isEmpty) {
        for (final key in ['client_phone', 'phone', 'customer_phone', 'phone_number']) {
          final val = dataMap[key]?.toString().trim() ?? '';
          if (val.isNotEmpty) {
            recipientPhone = val;
            break;
          }
        }
      }
      if (recipientPhone.isEmpty && clientName.isNotEmpty) {
        recipientPhone = (await BillingService().getClientPhone(clientName)) ?? '';
      }

      // 3. Resolve client email address
      String recipientEmail = targetEmail?.trim() ?? '';
      if (recipientEmail.isEmpty) {
        for (final key in ['client_email', 'email', 'customer_email', 'mail']) {
          final val = dataMap[key]?.toString().trim() ?? '';
          if (val.isNotEmpty && val.contains('@')) {
            recipientEmail = val;
            break;
          }
        }
      }
      if (recipientEmail.isEmpty && clientName.isNotEmpty) {
        recipientEmail = (await BillingService().getClientEmail(clientName)) ?? '';
      }

      // 4. Compute amount and words
      double effectiveAmount = paidAmount ?? 0;
      if (effectiveAmount <= 0) {
        effectiveAmount = NumberToWords.parseCurrency(totalAmount);
      }
      final amountFormatted = NumberToWords.formatIndianCurrency(effectiveAmount);
      final amountWords = NumberToWords.convert(effectiveAmount.round());

      // 5. Generate and Upload Receipt PDF
      final receiptData = await generateAndUploadReceiptPdf(
        invoiceNo: invoiceNo,
        clientName: clientName,
        clientAddress: clientAddress,
        authorities: authorities,
        items: items,
        totalAmount: amountFormatted,
        amountInWords: amountWords,
        paymentMode: paymentMode ?? 'Razorpay Online',
        transactionId: paymentId,
      );

      final receiptPdfUrl = receiptData.publicUrl;

      // 6. Update receipt URL in bill data
      if (receiptPdfUrl != null) {
        dataMap['receipt_url'] = receiptPdfUrl;
        dataMap['receipt_sent_at'] = DateTime.now().toIso8601String();
        dataMap['receipt_no'] = 'RCPT-$invoiceNo';

        try {
          if (billing is amplify_models.Billings) {
            final updated = billing.copyWith(data: jsonEncode(dataMap));
            await BackupAwareApi().update(updated);
          } else if (billing is Billing && billing.id != null) {
            await BillingService().updateBilling(billing.id.toString(), {'data': dataMap});
          }
        } catch (e) {
          debugPrint('Error updating bill data with receipt_url: $e');
        }
      }

      // 7. Compose formatted receipt text
      final dateNow = DateTime.now().toString().split(' ')[0];
      final receiptMessage = "🧾 *OFFICIAL PAYMENT RECEIPT*\n"
          "*COCHIN UNITED CONSULTANCY*\n"
          "━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
          "📄 *Receipt No:* RCPT-$invoiceNo\n"
          "📑 *Invoice Ref:* $invoiceNo\n"
          "📅 *Date:* $dateNow\n"
          "👤 *Client Name:* $clientName\n"
          "━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
          "💰 *Amount Received:* ₹$amountFormatted\n"
          "💳 *Payment Mode:* ${paymentMode ?? 'Online / Electronic'}\n"
          "${paymentId != null && paymentId.isNotEmpty ? '🔢 *Txn ID:* $paymentId\n' : ''}"
          "⚖️ *Balance Due:* ₹0.00 (PAID IN FULL)\n"
          "━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
          "${receiptPdfUrl != null ? '📥 *Download Official Receipt (PDF):*\n$receiptPdfUrl\n\n' : ''}"
          "Thank you for choosing Cochin United Consultancy!\n"
          "For any support, please contact +91 70124 66754.";

      // 8. SEND VIA WHATSAPP
      bool whatsAppSent = false;
      if (recipientPhone.isNotEmpty) {
        if (receiptPdfUrl != null) {
          final docRes = await WhatsAppCloudService().sendDocumentMessage(
            toPhone: recipientPhone,
            documentUrl: receiptPdfUrl,
            fileName: 'Payment_Receipt_RCPT_$invoiceNo.pdf',
            caption: 'Payment Receipt for Invoice $invoiceNo - ₹$amountFormatted',
          );
          whatsAppSent = docRes.success;
        }

        final txtRes = await WhatsAppCloudService().sendMessage(
          toPhone: recipientPhone,
          message: receiptMessage,
        );
        whatsAppSent = whatsAppSent || txtRes.success;

        // Notify Admin on WhatsApp
        if (cfg.notifyAdminPhone.isNotEmpty) {
          final phones = cfg.notifyAdminPhone.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty);
          for (final adminPhone in phones) {
            await WhatsAppCloudService().sendMessage(
              toPhone: adminPhone,
              message: "🧾 *Receipt Dispatched*\n\n"
                  "Receipt: *RCPT-$invoiceNo*\n"
                  "Client: *$clientName* ($recipientPhone)\n"
                  "Amount: *₹$amountFormatted*\n"
                  "Status: *Sent to WhatsApp & Email*",
            );
          }
        }
      }

      // 9. SEND VIA EMAIL (Gmail SMTP via backend)
      bool emailSent = false;
      try {
        final emailPayload = {
          'to': recipientEmail.isNotEmpty ? recipientEmail : 'cochinunitedconsultancydm@gmail.com',
          'clientName': clientName,
          'invoiceNo': invoiceNo,
          'amount': amountFormatted,
          'paymentMode': paymentMode ?? 'Razorpay Online',
          'paymentId': paymentId,
          'receiptPdfUrl': receiptPdfUrl,
          if (receiptData.pdfBytes != null) 'pdfBytesBase64': base64Encode(receiptData.pdfBytes!),
        };

        final emailRes = await http.post(
          Uri.parse('http://localhost:5000/api/send-receipt-email'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(emailPayload),
        ).timeout(const Duration(seconds: 15));

        if (emailRes.statusCode == 200) {
          emailSent = true;
          debugPrint('✅ Receipt email sent successfully to ${emailPayload['to']}');
        } else {
          debugPrint('Email API responded with status: ${emailRes.statusCode} - ${emailRes.body}');
        }
      } catch (e) {
        debugPrint('Notice: Email sending error: $e');
      }

      final overallSuccess = whatsAppSent || emailSent || receiptPdfUrl != null;

      // 10. Audit Logging
      await LoggingService().logAction(
        action: 'RECEIPT_DISPATCHED',
        targetType: 'Invoice',
        targetId: invoiceNo,
        details: 'Dispatched payment receipt for $invoiceNo (WhatsApp: $whatsAppSent, Email: $emailSent, PDF: ${receiptPdfUrl != null})',
      );

      return ReceiptSendResult(
        success: overallSuccess,
        whatsAppSent: whatsAppSent,
        emailSent: emailSent,
        receiptPdfUrl: receiptPdfUrl,
        phone: recipientPhone,
        email: recipientEmail,
        message: 'Receipt generated. WhatsApp: ${whatsAppSent ? "Sent" : "Pending"}, Email: ${emailSent ? "Sent" : "Pending"}',
      );
    } catch (e) {
      debugPrint('Error in sendReceiptAutomatically: $e');
      return ReceiptSendResult(success: false, error: e.toString());
    }
  }
}
