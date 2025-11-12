import 'package:flutter/material.dart';
import 'package:smartlocker/models/user_profile.dart';
import 'package:smartlocker/services/user_service.dart';
import 'package:smartlocker/utils/app_colors.dart';

class AccountCenterScreen extends StatefulWidget {
  const AccountCenterScreen({super.key, this.drawer});

  final Widget? drawer;

  @override
  State<AccountCenterScreen> createState() => _AccountCenterScreenState();
}

class _AccountCenterScreenState extends State<AccountCenterScreen> {
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = UserService.instance.fetchProfile();
  }

  Future<void> _refreshProfile() async {
    final profile = await UserService.instance.fetchProfile();
    setState(() {
      _profileFuture = Future.value(profile);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Center'),
      ),
      drawer: widget.drawer,
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: FutureBuilder<UserProfile>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }
            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }
            final profile = snapshot.data;
            if (profile == null) {
              return _buildErrorState('Unable to load account details.');
            }
            return _buildProfileView(profile);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(
          height: 260,
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
        const SizedBox(height: 16),
        Text(
          'Something went wrong',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(message),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _refreshProfile,
          icon: const Icon(Icons.refresh),
          label: const Text('Try Again'),
        ),
      ],
    );
  }

  Widget _buildProfileView(UserProfile profile) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary.withAlpha(51),
                      child: Text(
                        profile.username.isNotEmpty
                            ? profile.username[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.username,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile.email,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInfoTile(
                  icon: Icons.person_outline,
                  label: 'Username',
                  value: profile.username,
                ),
                const Divider(),
                _buildInfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: profile.email,
                ),
                const Divider(),
                _buildInfoTile(
                  icon: Icons.badge_outlined,
                  label: 'Registered As',
                  value: profile.displayRole,
                  trailing: Chip(
                    label: Text(
                      profile.displayRole,
                      style: const TextStyle(color: AppColors.black),
                    ),
                    backgroundColor: AppColors.primary.withAlpha(64),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Registration info is based on where this account was first created.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(label),
      subtitle: Text(value.isEmpty ? '-' : value),
      trailing: trailing,
    );
  }
}
