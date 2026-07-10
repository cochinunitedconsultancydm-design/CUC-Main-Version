import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';

import 'client_deals_view.dart';
import 'client_documents_view.dart';
import 'client_billing_view.dart';
import 'client_help_queries_view.dart';

class ClientPortalDashboardScreen extends StatefulWidget {
  const ClientPortalDashboardScreen({super.key});

  @override
  State<ClientPortalDashboardScreen> createState() => _ClientPortalDashboardScreenState();
}

class _ClientPortalDashboardScreenState extends State<ClientPortalDashboardScreen> {
  int _selectedIndex = 0;
  String _clientName = 'Client';

  @override
  void initState() {
    super.initState();
    _loadClientName();
  }

  Future<void> _loadClientName() async {
    final name = await AuthService().getUserName();
    if (mounted && name != null) {
      setState(() {
        _clientName = name;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 900;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Row(
          children: [
            if (isWide) _buildSidebar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildMainBody(),
              ),
            ),
          ],
        ),
      ),
      drawer: !isWide ? Drawer(
        backgroundColor: const Color(0xFF13131A),
        child: _buildSidebar(),
      ) : null,
      appBar: !isWide ? AppBar(
        title: const Text('Client Portal', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
      ) : null,
    );
  }

  Widget _buildMainBody() {
    switch (_selectedIndex) {
      case 0: return _buildDashboardOverview(context);
      case 1: return const ClientDealsView();
      case 2: return const ClientDocumentsView();
      case 3: return const ClientBillingView();
      case 4: return const ClientHelpQueriesView();
      default: return const Center(child: Text('Page not found', style: TextStyle(color: Colors.white)));
    }
  }

  Widget _buildDashboardOverview(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ultra-Premium Greeting Card
          Container(
            padding: EdgeInsets.all(isMobile ? 24 : 40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF312E81)], // Deep rich indigo/purple
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: const Color(0xFF312E81).withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 12)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          _getGreeting(),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _clientName,
                        style: TextStyle(fontSize: isMobile ? 32 : 42, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1.5, height: 1.1),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Welcome to your Cochin United portal. Track your cases, documents, and invoices here.',
                        style: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.white.withValues(alpha: 0.7), height: 1.5),
                      ),
                    ],
                  ),
                ),
                if (!isMobile)
                  Container(
                    padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.accentColor, Colors.orangeAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppTheme.accentColor.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
                      BoxShadow(color: Colors.white.withValues(alpha: 0.1), blurRadius: 0, spreadRadius: 8),
                    ],
                  ),
                  child: const Icon(Icons.stars_rounded, color: Colors.white, size: 56),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.05, duration: 2.seconds, curve: Curves.easeInOut),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOut).slideY(begin: 0.1, end: 0),
          
          SizedBox(height: isMobile ? 32 : 48),
          
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.accentColor, Colors.orangeAccent]),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Quick Access', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textColor, letterSpacing: -0.5)),
            ],
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
          const SizedBox(height: 24),
          
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
            crossAxisSpacing: isMobile ? 12 : 24,
            mainAxisSpacing: isMobile ? 12 : 24,
            shrinkWrap: true,
            childAspectRatio: MediaQuery.of(context).size.width > 1200 ? 1.1 : (MediaQuery.of(context).size.width > 800 ? 1.4 : (isMobile ? 0.75 : 1.4)),
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildPremiumQuickCard('My Workfiles', 'Track your active cases', Icons.work_outline_rounded, 1, const [Color(0xFF3B82F6), Color(0xFF2563EB)], isMobile),
              _buildPremiumQuickCard('My Documents', 'View and upload files', Icons.file_copy_rounded, 2, const [Color(0xFF10B981), Color(0xFF059669)], isMobile),
              _buildPremiumQuickCard('Pending Bills', 'Manage your invoices', Icons.receipt_long_rounded, 3, const [Color(0xFFF59E0B), Color(0xFFD97706)], isMobile),
              _buildPremiumQuickCard('Help & Queries', 'Chat with your agent', Icons.support_agent_rounded, 4, const [Color(0xFF8B5CF6), Color(0xFF6D28D9)], isMobile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumQuickCard(String title, String subtitle, IconData icon, int targetIndex, List<Color> gradientColors, bool isMobile) {
    return InkWell(
      onTap: () => setState(() => _selectedIndex = targetIndex),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24, offset: const Offset(0, 10)),
            BoxShadow(color: gradientColors[0].withValues(alpha: 0.05), blurRadius: 10, spreadRadius: 2),
          ],
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Stack(
          children: [
            // Background subtle gradient blob
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [gradientColors[0].withValues(alpha: 0.15), Colors.transparent],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 10 : 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(color: gradientColors[0].withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Icon(icon, size: isMobile ? 24 : 32, color: Colors.white),
                      ),
                      Container(
                        padding: EdgeInsets.all(isMobile ? 6 : 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_forward_rounded, size: isMobile ? 14 : 18, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: isMobile ? 15 : 20, fontWeight: FontWeight.bold, color: AppTheme.textColor, letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(fontSize: isMobile ? 11 : 14, color: AppTheme.mutedTextColor, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (200 + (targetIndex * 100)).ms, duration: 600.ms).scaleXY(begin: 0.9, end: 1.0, curve: Curves.easeOutBack);
  }

  Widget _buildSidebar() {
    return Material(
      color: const Color(0xFF13131A),
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Image.asset('assets/CUnitedGold.png', height: 40, fit: BoxFit.contain),
                  const SizedBox(width: 12),
                  const Text('Client Portal', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _sidebarItem(0, Icons.grid_view_rounded, 'Dashboard'),
                    _sidebarItem(1, Icons.folder_shared_rounded, 'My Workfiles'),
                    _sidebarItem(2, Icons.file_copy_rounded, 'My Documents'),
                    _sidebarItem(3, Icons.receipt_long_rounded, 'Pending Bills'),
                    _sidebarItem(4, Icons.help_outline_rounded, 'Help & Queries'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                onTap: () async {
                  await AuthService().logout();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() => _selectedIndex = index);
          if (MediaQuery.of(context).size.width <= 900) {
            Navigator.pop(context);
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.3) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? AppTheme.primaryColor : Colors.white60),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
