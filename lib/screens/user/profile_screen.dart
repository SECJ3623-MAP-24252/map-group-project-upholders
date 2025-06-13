import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../model/user_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../../widgets/app_drawer.dart';
import '../notification/notification_setting_screen.dart';
// import 'edit_profile_screen.dart'; // Placeholder for a potential edit profile screen

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final sessionViewModel = Provider.of<SessionViewModel>(context, listen: false);
    final UserModel? user = authViewModel.currentUser;

    if (user == null) {
      // This should ideally not happen if the user is on this screen,
      // but handle it gracefully.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF), // Light background
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.brown[700]),
        titleTextStyle: TextStyle(
            color: Colors.brown[700],
            fontSize: 20,
            fontWeight: FontWeight.bold),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.brown[700]),
            tooltip: 'Edit Profile',
            onPressed: () {
              // TODO: Navigate to an EditProfileScreen
              // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(user: user)));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Profile functionality coming soon!')),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/profile'), // Assuming '/profile' is the route for this screen
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.brown[100],
              backgroundImage: user.profilePicUrl != null && user.profilePicUrl!.isNotEmpty
                  ? NetworkImage(user.profilePicUrl!)
                  : null,
              child: user.profilePicUrl == null || user.profilePicUrl!.isEmpty
                  ? Icon(Icons.person, size: 60, color: Colors.brown[700])
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.brown[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(
                user.userType.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFFA7B77A), // Theme color
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            const SizedBox(height: 24),
            const Divider(),
            _buildProfileInfoCard(user),
            const SizedBox(height: 16),
            _buildSettingsCard(context),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Logout', style: TextStyle(fontSize: 16, color: Colors.white)),
              onPressed: () async {
                await sessionViewModel.endSession();
                await authViewModel.signOut();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard(UserModel user) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFA7B77A)),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person_outline, 'Full Name', user.name),
            _buildInfoRow(Icons.email_outlined, 'Email Address', user.email),
            _buildInfoRow(Icons.badge_outlined, 'User Role', user.userType),
            _buildInfoRow(Icons.calendar_today_outlined, 'Joined Date',
                DateFormat.yMMMMd().format(user.createdAt)),
            _buildInfoRow(Icons.login_outlined, 'Last Login',
                DateFormat.yMMMMd().add_jm().format(user.lastLogin)),
            // Add more fields as needed, e.g., phone number if available
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.notifications_outlined, color: Colors.brown[600]),
            title: const Text('Notification Settings', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationSettingScreen()),
              );
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: Icon(Icons.security_outlined, color: Colors.brown[600]),
            title: const Text('Account Security', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to Account Security Screen (e.g., change password)
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account Security coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.brown[400], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.brown[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
