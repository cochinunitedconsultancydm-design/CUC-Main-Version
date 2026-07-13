import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import '../../theme.dart';
import '../../models/ModelProvider.dart';
import '../../services/auth_service.dart';
import 'client_deal_chat_screen.dart';

class ClientHelpQueriesView extends StatefulWidget {
  const ClientHelpQueriesView({super.key});

  @override
  State<ClientHelpQueriesView> createState() => _ClientHelpQueriesViewState();
}

class _ClientHelpQueriesViewState extends State<ClientHelpQueriesView> {
  bool _isLoading = true;
  List<Deals> _deals = [];

  @override
  void initState() {
    super.initState();
    _fetchDeals();
  }

  Future<void> _fetchDeals() async {
    try {
      final clientName = await AuthService().getUserName();
      if (clientName != null) {
        final request = ModelQueries.list(
          Deals.classType,
          where: Deals.CLIENT_NAME.eq(clientName),
        );
        final response = await Amplify.API.query(request: request).response;
        
        if (mounted) {
          setState(() {
            _deals = response.data?.items.whereType<Deals>().toList() ?? [];
            // Sort by newest first
            _deals.sort((a, b) => (b.createdAt?.getDateTimeInUtc() ?? DateTime.now())
                .compareTo(a.createdAt?.getDateTimeInUtc() ?? DateTime.now()));
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching deals for queries: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    if (_deals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Active Workfiles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            const Text(
              'You do not have any active workfiles to query about.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Help & Queries', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
          const SizedBox(height: 8),
          const Text('Select a workfile below to chat directly with the staff responsible for it.', style: TextStyle(color: AppTheme.mutedTextColor)),
          const SizedBox(height: 32),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _deals.length,
            itemBuilder: (context, index) {
              final deal = _deals[index];
              return _buildDealQueryCard(deal, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDealQueryCard(Deals deal, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ClientDealChatScreen(deal: deal)));
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deal.name ?? 'Unnamed Deal',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textColor),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                'Responsible: ${deal.responsible_name?.isNotEmpty == true ? deal.responsible_name : "Not Assigned"}',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info_outline_rounded, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                'Stage: ${deal.stage ?? "Unknown"}',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.05, end: 0);
  }
}
