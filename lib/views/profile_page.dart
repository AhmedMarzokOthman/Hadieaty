import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hadieaty/controllers/user_controller.dart';
import 'package:hadieaty/views/edit_profile_page.dart';
import 'package:hadieaty/views/my_wishes_page.dart';
import 'package:hadieaty/views/pledged_gifts_page.dart';
import 'package:hadieaty/views/widgets/event_item_profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadieaty/cubits/profile/profile_cubit.dart';
import 'package:hadieaty/cubits/profile/profile_state.dart';
import 'package:hadieaty/cubits/auth/auth_cubit.dart';
import 'package:hadieaty/utils/app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // To trigger refresh after profile update
  bool _refreshToggle = false;

  @override
  Widget build(BuildContext context) {
    // Trigger profile data loading when page is shown
    context.read<ProfileCubit>().loadProfile();

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        if (state.error != null) {
          return Center(child: Text(state.error!));
        }

        if (state.user == null) {
          return Center(child: Text("User not found"));
        }

        final user = state.user!;
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(context, user),
                SizedBox(height: 24),
                _buildQuickLinks(context),
                SizedBox(height: 24),
                _buildEventsAndGiftsSection(),
                SizedBox(height: 24),
                _buildSettingsSections(context, user),
                SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(
                user.profilePicture ?? "",
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            user.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.username,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: user.username));

                  // Show snackbar to confirm copy
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Username copied to clipboard'),
                      duration: Duration(seconds: 1),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
                child: Icon(
                  Icons.copy_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickLink(
              context,
              Icons.card_giftcard_rounded,
              "My Wishes",
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.primary,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyWishesPage()),
                );
              },
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildQuickLink(
              context,
              Icons.redeem_rounded,
              "Pledged Gifts",
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PledgedGiftsPage(showAppBar: true),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLink(
    BuildContext context,
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsAndGiftsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 12),
          child: Text(
            "My Events & Gifts",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state.isLoading) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state.error != null) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(child: Text("Error loading events")),
                );
              }

              final events = state.events;

              if (events.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.event_busy, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          "No events created yet",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    events.map((event) {
                      return EventItemProfile(
                        key: ValueKey(event.id), // Unique key for each item
                        event: event,
                      );
                    }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSections(BuildContext context, dynamic user) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Settings",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Divider(),
          ),
          _buildSettingItem(
            context,
            Icons.person_outline_rounded,
            "Edit Profile",
            "Update your profile information",
            () async {
              final user = await UserController().getUserFromLocal(
                FirebaseAuth.instance.currentUser!.uid,
              );
              if (user != null && context.mounted) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(user: user),
                  ),
                );

                // If profile was updated, refresh the page
                if (result == true) {
                  setState(() {
                    _refreshToggle = !_refreshToggle;
                  });

                  // Add a delay to ensure Hive has time to update
                  await Future.delayed(Duration(milliseconds: 300));

                  // Force another rebuild
                  if (mounted) setState(() {});
                }
              }
            },
          ),
          _buildSettingItem(
            context,
            Icons.notifications_outlined,
            "Notifications",
            "Manage notification preferences",
            () {},
          ),
          _buildSettingItem(
            context,
            Icons.lock_outline_rounded,
            "Privacy",
            "Control your privacy settings",
            () {},
          ),
          _buildSettingItem(
            context,
            Icons.color_lens_outlined,
            "Appearance",
            "Change theme and display options",
            () {},
          ),
          _buildSettingItem(
            context,
            Icons.language_outlined,
            "Language",
            "Select your preferred language",
            () {},
          ),
          _buildSettingItem(
            context,
            Icons.help_outline_rounded,
            "Help & Support",
            "Get assistance and report issues",
            () {},
          ),
          _buildSettingItem(
            context,
            Icons.exit_to_app_rounded,
            "Sign Out",
            "Logout from your account",
            () {
              _showSignOutDialog(context);
            },
            iconColor: Colors.redAccent,
            textColor: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Sign Out"),
            content: Text("Are you sure you want to sign out?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AuthCubit>().signOut().then((_) {
                    Navigator.pushReplacementNamed(context, AppRoutes.signIn);
                  });
                },
                child: Text("Sign Out"),
              ),
            ],
          ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Color? iconColor,
    Color? textColor,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? Theme.of(context).colorScheme.primary)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: textColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          onTap: onTap,
          trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
        ),
      ],
    );
  }
}
