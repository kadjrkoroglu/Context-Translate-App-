import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:translate_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:translate_app/presentation/widgets/app_background.dart';
import 'package:translate_app/presentation/pages/auth/login_page.dart';
import 'package:translate_app/theme/theme_provider.dart';
import 'package:translate_app/theme/theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = authViewModel.user;
    final bool isAuthenticated = authViewModel.isAuthenticated;

    final glassTheme = Theme.of(context).extension<GlassThemeExtension>()!;
    const Color textColor = Colors.white;
    final Color subTextColor = textColor.withValues(alpha: 0.6);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          foregroundColor: textColor,
          actions: [
            if (isAuthenticated)
              IconButton(
                onPressed: () => _showLogoutDialog(context, authViewModel),
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                tooltip: 'Sign Out',
              ),
          ],
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: glassTheme.baseGlassColor,
                  border: Border(
                    bottom: BorderSide(
                      color: glassTheme.borderGlassColor,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileAvatar(user, isAuthenticated, glassTheme, textColor),
              const SizedBox(height: 20),
              Text(
                isAuthenticated
                    ? (user?.displayName ?? 'User')
                    : 'Guest Explorer',
                style: const TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              if (isAuthenticated)
                Text(
                  user?.email ?? '',
                  style: TextStyle(color: subTextColor, fontSize: 13),
                )
              else
                Text(
                  'Sign in to sync your progress',
                  style: TextStyle(
                    color: subTextColor.withValues(alpha: 0.5),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 40),
              if (isAuthenticated)
                _buildSyncStatusCard(glassTheme, textColor, subTextColor)
              else
                _buildSignInCTA(context, glassTheme, textColor, subTextColor),
              const SizedBox(height: 24),
              _buildSimpleTile(
                Icons.dark_mode_outlined,
                'Dark Mode',
                textColor,
                glassTheme,
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(value),
                  activeColor: Colors.white,
                  activeTrackColor: Colors.white24,
                ),
              ),
              _buildSimpleTile(
                Icons.help_outline_rounded,
                'Help & Support',
                textColor,
                glassTheme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await vm.signOut();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(
    dynamic user,
    bool isAuthenticated,
    GlassThemeExtension glass,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: glass.borderGlassColor, width: 2),
      ),
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.white10,
        backgroundImage: (isAuthenticated && user?.photoURL != null)
            ? NetworkImage(user!.photoURL!)
            : null,
        child: (!isAuthenticated || user?.photoURL == null)
            ? Icon(
                Icons.person_outline_rounded,
                size: 40,
                color: textColor.withValues(alpha: 0.7),
              )
            : null,
      ),
    );
  }

  Widget _buildSyncStatusCard(
    GlassThemeExtension glass,
    Color textColor,
    Color subTextColor,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: glass.baseGlassColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: glass.borderGlassColor),
          ),
          child: Row(
            children: [
              _buildIconCircle(
                Icons.cloud_done_rounded,
                Colors.greenAccent,
                glass,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cloud Sync Active',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Progress is automatically saved',
                      style: TextStyle(fontSize: 11, color: subTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInCTA(
    BuildContext context,
    GlassThemeExtension glass,
    Color textColor,
    Color subTextColor,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: glass.baseGlassColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: glass.borderGlassColor),
          ),
          child: Column(
            children: [
              Text(
                'Unlock All Features',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to backup your data and study on multiple devices.',
                textAlign: TextAlign.center,
                style: TextStyle(color: subTextColor, fontSize: 13),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleTile(
    IconData icon,
    String title,
    Color textColor,
    GlassThemeExtension glass, {
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: glass.baseGlassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: glass.borderGlassColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor.withValues(alpha: 0.7), size: 22),
          const SizedBox(width: 16),
          Text(title, style: TextStyle(color: textColor, fontSize: 15)),
          const Spacer(),
          trailing ??
              Icon(
                Icons.chevron_right_rounded,
                color: textColor.withValues(alpha: 0.2),
              ),
        ],
      ),
    );
  }

  Widget _buildIconCircle(
    IconData icon,
    Color color,
    GlassThemeExtension glass,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: glass.baseGlassColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }
}
