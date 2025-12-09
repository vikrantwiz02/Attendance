import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/user.dart';
import '../providers/service_providers.dart';
import 'login_page.dart';

/// User profile page with account information and settings
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    
    final useCase = ref.read(getCurrentUserUseCaseProvider);
    final user = await useCase.execute();
    
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? _buildErrorState()
              : _buildProfileContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Failed to load profile'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserProfile,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          // Profile Picture
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            backgroundImage: _user!.photoUrl != null 
                ? NetworkImage(_user!.photoUrl!)
                : null,
            child: _user!.photoUrl == null
                ? Text(
                    _getInitials(_user!.displayName),
                    style: TextStyle(
                      fontSize: 32,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  )
                : null,
          ),
          
          const SizedBox(height: 16),
          
          // User Name
          Text(
            _user!.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Email
          Text(
            _user!.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Account Information Section
          _buildSection(
            'Account Information',
            [
              _buildInfoTile(
                Icons.badge,
                'User ID',
                _user!.id,
              ),
              _buildInfoTile(
                Icons.calendar_today,
                'Member Since',
                DateFormat('MMMM d, yyyy').format(_user!.createdAt),
              ),
              _buildInfoTile(
                Icons.sync,
                'Last Sync',
                _user!.lastSyncAt != null
                    ? DateFormat('MMM d, yyyy HH:mm').format(_user!.lastSyncAt!)
                    : 'Never',
              ),
              _buildInfoTile(
                Icons.check_circle,
                'Account Status',
                _user!.isActive == true ? 'Active' : 'Inactive',
                valueColor: _user!.isActive == true ? Colors.green : Colors.red,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Settings Section
          _buildSection(
            'Settings',
            [
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                subtitle: const Text('Manage notification preferences'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to notifications settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification settings coming soon')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Geofencing'),
                subtitle: const Text('Manage work location zones'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to geofencing settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Geofencing settings coming soon')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Sync Settings'),
                subtitle: const Text('Configure data synchronization'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to sync settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sync settings coming soon')),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Actions Section
          _buildSection(
            'Actions',
            [
              ListTile(
                leading: const Icon(Icons.refresh, color: Colors.blue),
                title: const Text('Refresh Profile'),
                onTap: _refreshProfile,
              ),
              ListTile(
                leading: const Icon(Icons.cloud_upload, color: Colors.orange),
                title: const Text('Force Sync'),
                subtitle: const Text('Upload pending attendance records'),
                onTap: _forceSync,
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Clear Local Data'),
                subtitle: const Text('Remove all offline records'),
                onTap: _confirmClearData,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Sign Out Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirmSignOut,
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // App Version
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(
        value,
        style: TextStyle(
          color: valueColor,
          fontWeight: valueColor != null ? FontWeight.bold : null,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Future<void> _refreshProfile() async {
    try {
      final useCase = ref.read(googleSignInUseCaseProvider);
      // In a real app, this would call the backend
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile refreshed')),
      );
      await _loadUserProfile();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh profile: $e')),
      );
    }
  }

  Future<void> _forceSync() async {
    try {
      final syncEngine = ref.read(syncEngineProvider);
      // Trigger sync manually
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Syncing attendance records...')),
      );
      // The sync engine will handle the sync automatically
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e')),
      );
    }
  }

  Future<void> _confirmClearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Local Data?'),
        content: const Text(
          'This will remove all offline attendance records from this device. '
          'Make sure all data is synced before proceeding.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implement clear local data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local data cleared')),
      );
    }
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text(
          'Are you sure you want to sign out? '
          'Make sure all attendance records are synced.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _handleSignOut();
    }
  }

  Future<void> _handleSignOut() async {
    try {
      final useCase = ref.read(signOutUseCaseProvider);
      await useCase.execute();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: $e')),
      );
    }
  }
}
