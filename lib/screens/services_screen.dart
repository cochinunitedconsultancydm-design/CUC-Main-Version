import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../models/service_item.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart' as amplify_models;
import 'dart:convert';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  // final _client = Supabase.instance.client;
  List<ServiceItem> _services = [];
  bool _isLoading = true;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);
    try {
      final req = ModelQueries.list(amplify_models.ServiceContent.classType);
      final res = await Amplify.API.query(request: req).response;
      final result = res.data?.items.whereType<amplify_models.ServiceContent>().toList() ?? [];
      result.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
      
      final List<ServiceItem> parsed = [];
      for (final row in result) {
        try {
          Map<String, dynamic> rowMap = {
            'id': row.id,
            'title': row.title,
            'description': row.description,
            'image_path': row.image_path,
          };
          if (row.details != null && row.details!.isNotEmpty) {
            try {
              rowMap['details'] = jsonDecode(row.details!);
            } catch (_) {}
          }
          parsed.add(ServiceItem.fromMap(rowMap));
        } catch (e) {
          debugPrint('ServicesScreen: Failed to parse row: $e');
        }
      }
      setState(() {
        _services = parsed;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch services: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 900;
        final int gridCols = constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
        final filtered = _services.where((s) => 
          s.title.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          (s.description?.toLowerCase().contains(_searchTerm.toLowerCase()) ?? false)
        ).toList();

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPremiumHeader(isWide),
              const SizedBox(height: 24),
              _buildSearchInterface(isWide),
              const SizedBox(height: 32),
              Expanded(
                child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom: 40),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridCols,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          mainAxisExtent: 200,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => _buildServiceCard(filtered[index], index),
                      ),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms),
        );
      },
    );
  }

  Widget _buildPremiumHeader(bool isWide) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 40 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(
          image: const AssetImage('assets/CUnitedGold.png'),
          opacity: 0.05,
          alignment: Alignment.centerRight,
          scale: 0.5,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 30, offset: const Offset(0, 15)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: const Text('OUR EXPERTISE', style: TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ),
          const SizedBox(height: 20),
          const Text('Premium Consultancy\nServices', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
          const SizedBox(height: 12),
          Text('Explore our wide range of business solutions tailored for your success.', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSearchInterface(bool isWide) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 5))],
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchTerm = val),
              decoration: InputDecoration(
                hintText: 'What service are you looking for?',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        IconButton.filled(
          onPressed: _fetchServices,
          icon: const Icon(Icons.refresh_rounded),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 20),
          Text('No services found matching your criteria', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceItem service, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showServiceDetails(service),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(_getServiceIcon(service.title), color: AppTheme.primaryColor, size: 24),
                      ),
                      const Icon(Icons.arrow_outward_rounded, color: Colors.grey, size: 18),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    service.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      service.description ?? 'Explore our specialized consultancy offerings.',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1);
  }

  IconData _getServiceIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('gst')) return Icons.account_balance_rounded;
    if (t.contains('registration')) return Icons.app_registration_rounded;
    if (t.contains('tax')) return Icons.money_rounded;
    if (t.contains('license')) return Icons.verified_user_rounded;
    if (t.contains('digital')) return Icons.vpn_key_rounded;
    if (t.contains('billing')) return Icons.receipt_long_rounded;
    return Icons.business_center_rounded;
  }

  void _showServiceDetails(ServiceItem service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: Icon(_getServiceIcon(service.title), color: AppTheme.primaryColor, size: 40),
                          ),
                          const SizedBox(height: 24),
                          Text(service.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
                          const SizedBox(height: 16),
                          Text(service.description ?? '', style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.6)),
                          const SizedBox(height: 40),
                          if (service.details != null && service.details!['cards'] != null) ...[
                            const Text('Process & Requirements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: -0.5)),
                            const SizedBox(height: 24),
                            ...(service.details!['cards'] as List).map((card) {
                              final title = card['title'] ?? 'Details';
                              final items = card['items'] as List? ?? [];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor, size: 20),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ...items.map((item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(margin: const EdgeInsets.only(top: 8), width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle)),
                                          const SizedBox(width: 12),
                                          Expanded(child: Text(item.toString(), style: TextStyle(color: Colors.grey.shade700, fontSize: 14))),
                                        ],
                                      ),
                                    )),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
