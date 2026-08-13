import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cuc_app/models/ModelProvider.dart';
import 'package:cuc_app/services/auth_service.dart';
import 'package:cuc_app/theme.dart';

class BirthdayService {
  static const String _prefKey = 'last_birthday_popup_date';

  /// Call this when the dashboard initializes.
  static Future<void> checkAndShowBirthdays(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      final lastShown = prefs.getString(_prefKey);
      if (lastShown == todayStr) {
        // Already shown today for this user.
        return;
      }

      // Fetch all active staff
      final request = ModelQueries.list(Users.classType, limit: 1000);
      final response = await Amplify.API.query(request: request).response;
      final allUsers = response.data?.items.whereType<Users>().toList() ?? [];

      // Get current user to exclude them from seeing their own birthday
      final currentUserIdRaw = await AuthService().getUserId();
      final currentUsername = currentUserIdRaw?.toString();

      List<Users> birthdayStaff = [];
      String currentMonthDay = '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      for (var u in allUsers) {
        if (u.dob != null && u.dob!.isNotEmpty) {
          // Expected format DD-MM-YYYY or YYYY-MM-DD
          // Let's assume standard 'DD-MM-YYYY' or parse flexibly
          String dobMonthDay = '';
          final parts = u.dob!.replaceAll('/', '-').split('-');
          if (parts.length == 3) {
            if (parts[0].length == 4) {
              // YYYY-MM-DD
              dobMonthDay = '${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}';
            } else {
              // DD-MM-YYYY
              dobMonthDay = '${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
            }
          }
          
          if (dobMonthDay == currentMonthDay) {
            // It's their birthday! Check if they are the current user.
            bool isCurrentUser = false;
            if (currentUsername != null && (u.username?.toLowerCase() == currentUsername.toLowerCase() || u.id == currentUsername)) {
              isCurrentUser = true;
            }

            if (!isCurrentUser) {
              birthdayStaff.add(u);
            }
          }
        }
      }

      if (birthdayStaff.isNotEmpty) {
        // Save today's date so it doesn't show again
        await prefs.setString(_prefKey, todayStr);
        
        if (context.mounted) {
          _showBirthdayDialog(context, birthdayStaff);
        }
      }

    } catch (e) {
      debugPrint('Failed to check birthdays: $e');
    }
  }

  static void _showBirthdayDialog(BuildContext context, List<Users> birthdayStaff) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 16,
          backgroundColor: Colors.white,
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.cake, size: 64, color: Colors.orange.shade400),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Happy Birthday!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  birthdayStaff.length == 1 
                      ? 'Wish your colleague a wonderful day!'
                      : 'Wish your colleagues a wonderful day!',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Staff List
                ...birthdayStaff.map((staff) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                          child: Text(
                            staff.name?.isNotEmpty == true ? staff.name![0].toUpperCase() : '?',
                            style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(staff.name ?? 'Unknown Staff', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              if (staff.designation != null && staff.designation!.isNotEmpty)
                                Text(staff.designation!, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            ],
                          ),
                        ),
                        Icon(Icons.celebration, color: Colors.orange.shade300),
                      ],
                    ),
                  );
                }).toList(),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text('Awesome!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
