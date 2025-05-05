import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hadieaty/controllers/event_controller.dart';
import 'package:hadieaty/controllers/user_controller.dart';
import 'package:hadieaty/controllers/wish_controller.dart';
import 'package:hadieaty/models/event_model.dart';
import 'package:hadieaty/models/wish_model.dart';
import 'package:hadieaty/views/edit_profile_page.dart';
import 'package:hadieaty/views/pledged_gifts_page.dart';
import 'package:intl/intl.dart';

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
    // print('\x1B[32m ${FirebaseAuth.instance.currentUser!.uid} \x1B[0m');
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder(
      // Add _refreshToggle to force refresh when needed
      future: UserController().getUserFromLocal(uid),
      key: ValueKey(
        _refreshToggle,
      ), // This forces rebuild when _refreshToggle changes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        if (snapshot.data == null) {
          return Center(child: Text("User not found"));
        }
        // print('\x1B[32m ${snapshot.data!.profilePicture.toString()} \x1B[0m');
        final user = snapshot.data!;
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
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFB6938),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
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
                                  builder: (context) => PledgedGiftsPage(),
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
                                    color: Colors.black.withOpacity(0.1),
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
                              _buildSettingSection("Account Settings", [
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
                              ]),
                              SizedBox(height: 16),
                              _buildSettingSection("App Settings", [
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
                              ]),
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
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: FutureBuilder<List<EventModel>>(
            future: EventController().getEvents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(child: Text("Error loading events")),
                );
              }

              final events = snapshot.data ?? [];

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

              // Sort events by date (newest first)
              events.sort((a, b) => b.date.compareTo(a.date));

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildEventItem(context, event);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventItem(BuildContext context, EventModel event) {
    return ExpansionTile(
      title: Text(event.name, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type: ${event.type}'),
          Text(
            'Date: ${DateFormat('MMM d, yyyy').format(event.date)}',
            style: TextStyle(
              color:
                  event.date.isAfter(DateTime.now())
                      ? Colors.green[700]
                      : Colors.grey,
            ),
          ),
        ],
      ),
      leading: CircleAvatar(
        backgroundColor: _getEventColor(event),
        child: Icon(Icons.event, color: Colors.white),
      ),
      children: [
        FutureBuilder<List<WishModel>>(
          future: _getWishesByEvent(event.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }

            final wishes = snapshot.data ?? [];

            if (wishes.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "No gifts associated with this event",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: wishes.length,
              itemBuilder: (context, index) {
                final wish = wishes[index];
                return ListTile(
                  leading:
                      wish.image != null && wish.image!.isNotEmpty
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              wish.image!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          )
                          : Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.card_giftcard,
                              color: Colors.grey[700],
                            ),
                          ),
                  title: Text(wish.name),
                  subtitle: Text('\$${wish.price}'),
                  trailing:
                      wish.pledgedBy != null
                          ? Text(
                            'Pledged',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : null,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Color _getEventColor(EventModel event) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
    );

    if (eventDate.isBefore(today)) {
      return Colors.grey; // Past event
    } else if (eventDate.isAtSameMomentAs(today)) {
      return Colors.green; // Current event
    } else {
      return Color(0xFFFFAB5D); // Upcoming event
    }
  }

  Future<List<WishModel>> _getWishesByEvent(String eventId) async {
    // Get all user wishes
    final wishes = await WishController().getWishes();

    // Filter wishes that are associated with this event
    return wishes.where((wish) => wish.associatedEvent == eventId).toList();
  }

  Widget _buildSettingSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
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
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: items),
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
                if (user != null) {
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not load user profile')),
                  );
                }
              }
              : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFFB6938).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Color(0xFFFB6938), size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
