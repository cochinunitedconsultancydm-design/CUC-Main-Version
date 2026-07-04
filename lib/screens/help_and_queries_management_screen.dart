import 'package:flutter/material.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/ModelProvider.dart';
import '../theme.dart';
import 'client_portal/client_deal_chat_screen.dart';

class HelpAndQueriesManagementScreen extends StatefulWidget {
  const HelpAndQueriesManagementScreen({super.key});

  @override
  State<HelpAndQueriesManagementScreen> createState() => _HelpAndQueriesManagementScreenState();
}

class _HelpAndQueriesManagementScreenState extends State<HelpAndQueriesManagementScreen> {
  bool _isLoading = true;
  List<Deals> _dealsWithQueries = [];
  Map<String, DealActivities> _latestQueries = {};
  Map<String, int> _unreadCounts = {};
  Deals? _selectedDeal;

  @override
  void initState() {
    super.initState();
    _fetchQueries();
  }

  Future<void> _fetchQueries() async {
    setState(() => _isLoading = true);
    try {
      // Fetch all activities
      final actReq = ModelQueries.list(DealActivities.classType, limit: 2000);
      final actRes = await Amplify.API.query(request: actReq).response;
      final allActs = actRes.data?.items.whereType<DealActivities>().toList() ?? [];

      // Group by deal_id
      final Map<int, List<DealActivities>> groupedActs = {};
      for (var act in allActs) {
        if (act.type == 'client_query' || act.type == 'staff_reply') {
          final dId = act.deal_id;
          if (dId != null) {
            groupedActs.putIfAbsent(dId, () => []).add(act);
          }
        }
      }

      // Fetch deals that have queries
      final dealIds = groupedActs.keys.map((id) => id.toString()).toList();
      
      final dealsReq = ModelQueries.list(Deals.classType, limit: 2000);
      final dealsRes = await Amplify.API.query(request: dealsReq).response;
      final allDeals = dealsRes.data?.items.whereType<Deals>().toList() ?? [];
      
      final activeDeals = allDeals.where((d) => dealIds.contains(d.id)).toList();

      Map<String, DealActivities> latest = {};
      Map<String, int> unread = {};

      for (var deal in activeDeals) {
        final acts = groupedActs[int.tryParse(deal.id) ?? 0] ?? [];
        if (acts.isNotEmpty) {
          acts.sort((a, b) {
            final aDate = a.createdAt?.getDateTimeInUtc() ?? DateTime.tryParse(a.created_at ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.createdAt?.getDateTimeInUtc() ?? DateTime.tryParse(b.created_at ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate); // Descending
          });
          latest[deal.id] = acts.first;
          // Count unread client queries
          if (acts.first.type == 'client_query') {
            unread[deal.id] = 1; // Mark as unread if the latest is from client
          }
        }
      }
      
      // Sort deals by latest message time
      activeDeals.sort((a, b) {
        final aAct = latest[a.id];
        final bAct = latest[b.id];
        if (aAct == null) return 1;
        if (bAct == null) return -1;
        final aDate = aAct.createdAt?.getDateTimeInUtc() ?? DateTime.tryParse(aAct.created_at ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = bAct.createdAt?.getDateTimeInUtc() ?? DateTime.tryParse(bAct.created_at ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      if (mounted) {
        setState(() {
          _dealsWithQueries = activeDeals;
          _latestQueries = latest;
          _unreadCounts = unread;
          // Automatically select first deal if not on mobile
          if (_selectedDeal == null && _dealsWithQueries.isNotEmpty && MediaQuery.of(context).size.width > 800) {
            _selectedDeal = _dealsWithQueries.first;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching queries: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 800;

    return Container(
      color: const Color(0xFFF1F5F9), // Light background
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Helpdesk & Ticketing',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn().slideX(begin: -0.2, end: 0),
              
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.accentColor),
                onPressed: _fetchQueries,
                tooltip: 'Refresh Tickets',
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Manage and reply to client tickets directly from this interface.',
            style: TextStyle(fontSize: 16, color: AppTheme.mutedTextColor.withValues(alpha: 0.8)),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 32),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _dealsWithQueries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mark_chat_read_rounded, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No active tickets', style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('You are all caught up!', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: _buildTicketList(),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 2,
                            child: _buildTicketDetails(),
                          ),
                        ],
                      )
                    : _selectedDeal == null
                        ? _buildTicketList()
                        : _buildTicketDetails(), // On mobile, show list, if selected show details (with back button)
          ),
        ],
      ),
    );
  }

  Widget _buildTicketList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListView.separated(
        itemCount: _dealsWithQueries.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
        itemBuilder: (context, index) {
          final deal = _dealsWithQueries[index];
          final latestAct = _latestQueries[deal.id];
          final isUnread = _unreadCounts.containsKey(deal.id);
          final isSelected = _selectedDeal?.id == deal.id;
          
          DateTime date = latestAct?.createdAt?.getDateTimeInUtc() ?? DateTime.now();
          if (latestAct?.created_at != null) {
            date = DateTime.tryParse(latestAct!.created_at!) ?? date;
          }

          return Material(
            color: isSelected ? AppTheme.accentColor.withValues(alpha: 0.05) : Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedDeal = deal;
                  // If unread, mark as read locally
                  _unreadCounts.remove(deal.id);
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.accentColor : (isUnread ? Colors.orange : Colors.transparent),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  deal.name ?? 'Unknown Deal',
                                  style: TextStyle(
                                    fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                    fontSize: 15,
                                    color: isSelected ? AppTheme.accentColor : AppTheme.textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                _formatDate(date),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isUnread ? AppTheme.accentColor : AppTheme.mutedTextColor,
                                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            deal.client_name ?? 'Unknown Client',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            latestAct?.description ?? 'No message',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: isUnread ? AppTheme.textColor : Colors.grey.shade500,
                              fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTicketDetails() {
    if (_selectedDeal == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.confirmation_num_outlined, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('Select a ticket to view details', style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
            ],
          ),
        ),
      );
    }

    final bool isNarrow = MediaQuery.of(context).size.width <= 800;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          if (isNarrow)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to Tickets'),
                  onPressed: () => setState(() => _selectedDeal = null),
                ),
              ),
            ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ClientDealChatScreen(deal: _selectedDeal!, isStaff: true, key: ValueKey(_selectedDeal!.id)),
            ),
          ),
        ],
      ),
    );
  }
}
