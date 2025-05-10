import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hadieaty/controllers/user_controller.dart';
import 'package:hadieaty/views/edit_profile_page.dart';
import 'package:hadieaty/views/pledged_gifts_page.dart';
import 'package:hadieaty/views/widgets/event_item_profile.dart';
import 'package:hadieaty/views/widgets/setting_item.dart';
import 'package:hadieaty/views/widgets/settings_section.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadieaty/cubits/profile/profile_cubit.dart';
import 'package:hadieaty/cubits/profile/profile_state.dart';

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
          return Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(child: Text(state.error!));
        }

        if (state.user == null) {
          return Center(child: Text("User not found"));
        }

        final user = state.user!;
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color(0xFFFB6938),
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                    user.profilePicture ?? "",
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user.username,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: user.username),
                                );

                                // Show snackbar to confirm copy
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Username copied to clipboard',
                                    ),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.copy,
                                color: Colors.grey[600],
                                size: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // My Pledged Gifts Link
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          PledgedGiftsPage(showAppBar: true),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFFAB5D),
                                    Color(0xFFFB6938),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(30),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.redeem, color: Colors.white),
                                      SizedBox(width: 12),
                                      Text(
                                        'My Pledged Gifts',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // My Events and Gifts
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildEventsAndGiftsSection(),
                        ),

                        const SizedBox(height: 20),

                        // Settings
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              SettingsSection(
                                title: "Account Settings",
                                items: [
                                  _buildSettingItem(
                                    context,
                                    Icons.person_outline,
                                    "Edit Profile",
                                    "Update your profile information",
                                    () {},
                                  ),
                                  _buildSettingItem(
                                    context,
                                    Icons.notifications_outlined,
                                    "Notifications",
                                    "Manage your notification preferences",
                                    () {},
                                  ),
                                  _buildSettingItem(
                                    context,
                                    Icons.lock_outline,
                                    "Privacy",
                                    "Control your privacy settings",
                                    () {},
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              SettingsSection(
                                title: "App Settings",
                                items: [
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
                                    Icons.help_outline,
                                    "Help & Support",
                                    "Get assistance and report issues",
                                    () {},
                                  ),
                                ],
                              ),
                            ],
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
    );
  }

  Widget _buildEventsAndGiftsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            "My Events & Gifts",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
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

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap:
          title == "Edit Profile"
              ? () async {
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
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not load user profile')),
                    );
                  }
                }
              }
              : onTap,
      child: SettingItem(icon: icon, title: title, subtitle: subtitle),
    );
  }
}
