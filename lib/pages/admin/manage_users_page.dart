import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

/// مدیریت کاربران: مشاهده لیست کاربران ثبت‌نام‌شده و اعطا/لغو دسترسی مدیریت
/// (با افزودن یا حذف سند کاربر در collection «admins»، طبق Security Rules).
class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final FirestoreService _service = FirestoreService();
  List<UserModel> _users = [];
  Set<String> _adminIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final usersSnap = await _service.collection(AppConstants.usersCollection).get();
      final adminsSnap = await _service.collection(AppConstants.adminsCollection).get();
      _users = usersSnap.docs
          .map((d) => UserModel.fromMap(d.id, d.data() as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _adminIds = adminsSnap.docs.map((d) => d.id).toSet();
    } catch (_) {
      _users = [];
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _toggleAdmin(UserModel user) async {
    final isAdmin = _adminIds.contains(user.uid);
    if (isAdmin) {
      await _service.delete(AppConstants.adminsCollection, user.uid);
    } else {
      await _service.createWithId(AppConstants.adminsCollection, user.uid, {
        'grantedAt': DateTime.now().toIso8601String(),
      });
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت کاربران'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _users.isEmpty
              ? const EmptyStateWidget(message: 'کاربری ثبت‌نام نکرده است', icon: Icons.people_outline)
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final u = _users[index];
                    final isAdmin = _adminIds.contains(u.uid);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isAdmin
                              ? AppColors.secondary.withOpacity(0.15)
                              : AppColors.primary.withOpacity(0.1),
                          child: Icon(
                            isAdmin ? Icons.admin_panel_settings : Icons.person_outline,
                            color: isAdmin ? AppColors.secondaryDark : AppColors.primary,
                          ),
                        ),
                        title: Text(u.name.isEmpty ? '(بدون نام)' : u.name),
                        subtitle: Text(u.phone),
                        trailing: Switch(
                          value: isAdmin,
                          activeColor: AppColors.primary,
                          onChanged: (_) => _toggleAdmin(u),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
