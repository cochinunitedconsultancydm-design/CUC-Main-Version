import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import '../../models/ModelProvider.dart';
import '../../theme.dart';
import '../../services/auth_service.dart';
import '../../services/invoice_pdf_service.dart';
import 'dart:convert';

class ClientBillingView extends StatefulWidget {
  const ClientBillingView({super.key});

  @override
  State<ClientBillingView> createState() => _ClientBillingViewState();
}

class _ClientBillingViewState extends State<ClientBillingView> {
  bool _isLoading = true;
  List<Billings> _bills = [];

  @override
  void initState() {
    super.initState();
    _fetchBills();
  }

  Future<void> _fetchBills() async {
    setState(() => _isLoading = true);
    try {
      final clientName = await AuthService().getUserName();
      if (clientName != null) {
        final request = ModelQueries.list(
          Billings.classType,
          where: Billings.CLIENT_NAME.eq(clientName),
         limit: 10000);
        final response = await Amplify.API.query(request: request).response;
        setState(() {
          _bills = (response.data?.items ?? []).whereType<Billings>().toList() ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching client bills: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _viewBill(Billings bill) async {
    try {
      final map = jsonDecode(bill.data ?? '{}') as Map<String, dynamic>;
      
      final rawItems = map['items'] as List<dynamic>? ?? [];
      final List<Map<String, dynamic>> items = rawItems.map((e) => {
        'description': e['description']?.toString() ?? '',
        'amount': e['amount']?.toString() ?? '',
      }).toList();

      final quotationTermsRaw = map['quotation_terms'] as List<dynamic>? ?? [];
      final List<String> terms = quotationTermsRaw.map((e) => e.toString()).toList();

      await InvoicePdfService.printInvoice(
        type: bill.type ?? 'INVOICE',
        category: bill.category ?? '',
        clientName: bill.client_name ?? '',
        clientAddress: map['client_address']?.toString() ?? '',
        date: bill.date ?? '',
        invoiceNo: bill.invoice_no ?? '',
        authorities: bill.authorities ?? '',
        items: items,
        totalAmount: bill.amount ?? '0',
        amountInWords: map['amount_in_words']?.toString() ?? '',
        outstandingAmount: map['outstanding_amount']?.toString() ?? '',
        advanceReceived: map['advance_received']?.toString() ?? '',
        grandTotal: map['grand_total']?.toString() ?? '',
        balanceDue: map['balance_due']?.toString() ?? '',
        quotationTerms: terms.isEmpty ? null : terms,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open bill: $e'), backgroundColor: Colors.redAccent));
      }
    }
  }

  String _parseData(String? dataStr, String key) {
    if (dataStr == null || dataStr.isEmpty) return '';
    try {
      final map = jsonDecode(dataStr) as Map<String, dynamic>;
      return map[key]?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(24),
          child: Text('Pending Bills', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
        ),
        Expanded(
          child: _bills.isEmpty
            ? const Center(child: Text('No pending bills found.', style: TextStyle(color: AppTheme.mutedTextColor)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _bills.length,
                itemBuilder: (context, index) {
                  final bill = _bills[index];
                  
                  final paidAmtStr = _parseData(bill.data, 'advance_received');
                  final balanceDueStr = _parseData(bill.data, 'balance_due');
                  
                  final paidAmt = paidAmtStr.isNotEmpty ? paidAmtStr : '0';
                  final balanceDue = balanceDueStr.isNotEmpty ? balanceDueStr : bill.amount ?? '0';

                  return Card(
                    color: AppTheme.surfaceColor,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(bill.invoice_no ?? 'Invoice', style: const TextStyle(fontSize: 16, color: AppTheme.textColor, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('Date: ${bill.date ?? 'N/A'}', style: const TextStyle(fontSize: 13, color: AppTheme.mutedTextColor)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: bill.status == 'Pending' ? Colors.amber.shade50 : (bill.status == 'Received' ? Colors.green.shade50 : Colors.blue.shade50),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: bill.status == 'Pending' ? Colors.amber.shade200 : (bill.status == 'Received' ? Colors.green.shade200 : Colors.blue.shade200)),
                                ),
                                child: Text(
                                  bill.status ?? 'Pending',
                                  style: TextStyle(
                                    fontSize: 12, 
                                    fontWeight: FontWeight.w700, 
                                    color: bill.status == 'Pending' ? Colors.amber.shade700 : (bill.status == 'Received' ? Colors.green.shade700 : Colors.blue.shade700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildAmountColumn('Total', '₹${bill.amount ?? '0'}', Colors.blueGrey.shade700),
                              _buildAmountColumn('Paid', '₹$paidAmt', Colors.green.shade700),
                              _buildAmountColumn('Balance', '₹$balanceDue', AppTheme.primaryColor),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _viewBill(bill),
                              icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                              label: const Text('View Bill'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildAmountColumn(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.mutedTextColor, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(amount, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
