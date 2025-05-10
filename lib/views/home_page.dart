import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadieaty/constants/colors.dart';
import 'package:hadieaty/cubits/home/home_cubit.dart';
import 'package:hadieaty/cubits/home/home_state.dart';
import 'package:hadieaty/views/events_page.dart';
import 'package:hadieaty/views/my_wishes_page.dart';
import 'package:hadieaty/views/pledged_gifts_page.dart';
import 'package:hadieaty/views/profile_page.dart';
import 'package:hadieaty/cubits/auth/auth_cubit.dart';
import 'package:hadieaty/views/widgets/add_friend_dialog.dart';
import 'package:hadieaty/views/widgets/add_wish_dialog.dart';
import 'package:hadieaty/views/widgets/event_dialog.dart';
import 'package:hadieaty/views/widgets/friend_widget.dart';
import 'package:animations/animations.dart';
import 'package:hadieaty/utils/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (!state.isInitialized) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        final user = state.user;
        if (user == null) {
          return Center(child: Text("User not found"));
        }

        final List<Widget> pages = [
          _buildFriendsPage(context, state),
          _buildPageWithAppBar(context, "Events", EventsPage()),
          _buildPageWithAppBar(context, "My Wishes", MyWishesPage()),
          _buildPageWithAppBar(context, "Pledged Gifts", PledgedGiftsPage()),
          _buildPageWithAppBar(context, "Profile", ProfilePage()),
        ];

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: PageTransitionSwitcher(
            transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
              return FadeThroughTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
            child: pages[state.activeIndex],
          ),
          appBar:
              state.activeIndex == 0
                  ? AppBar(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    leading: Builder(
                      builder:
                          (context) => IconButton(
                            icon: Icon(
                              Icons.menu_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 28,
                            ),
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                          ),
                    ),
                    title: Text(
                      "Hadieaty",
                      style: TextStyle(
                        fontFamily: "Manrope",
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add, color: primaryColor, size: 24),
                        ),
                        onPressed: () {
                          _showAddOptions(context, state.activeIndex);
                        },
                      ),
                      SizedBox(width: 8),
                    ],
                  )
                  : null,
          drawer: _buildDrawer(context, user, state),
          floatingActionButton:
              state.activeIndex != 0 &&
                      state.activeIndex != 4 &&
                      state.activeIndex != 3
                  ? FloatingActionButton(
                    onPressed: () {
                      if (state.activeIndex == 1) {
                        _showAddEventDialog(context, state.activeIndex);
                      } else if (state.activeIndex == 2) {
                        _showAddWishDialog(context, state.activeIndex);
                      }
                    },
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Icon(Icons.add, color: Colors.white),
                  )
                  : null,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      context,
                      0,
                      Icons.people_alt_rounded,
                      "Friends",
                      state.activeIndex,
                    ),
                    _buildNavItem(
                      context,
                      1,
                      Icons.event_rounded,
                      "Events",
                      state.activeIndex,
                    ),
                    _buildNavItem(
                      context,
                      2,
                      Icons.card_giftcard_rounded,
                      "Wishes",
                      state.activeIndex,
                    ),
                    _buildNavItem(
                      context,
                      3,
                      Icons.redeem_rounded,
                      "Pledged",
                      state.activeIndex,
                    ),
                    _buildNavItem(
                      context,
                      4,
                      Icons.person_rounded,
                      "Profile",
                      state.activeIndex,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
    int activeIndex,
  ) {
    final isActive = index == activeIndex;
    return InkWell(
      onTap: () {
        context.read<HomeCubit>().setActiveIndex(index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration:
            isActive
                ? BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                )
                : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isActive
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: "Manrope",
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color:
                    isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, dynamic user, HomeState state) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hadieaty",
                  style: TextStyle(
                    fontFamily: "Manrope",
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          user.profilePicture ?? "",
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.person,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              fontFamily: "Manrope",
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontFamily: "Manrope",
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildDrawerItem(context, Icons.home_rounded, "Home", () {
            Navigator.pop(context);
            context.read<HomeCubit>().setActiveIndex(0);
          }),
          _buildDrawerItem(context, Icons.event_rounded, "Events", () {
            Navigator.pop(context);
            context.read<HomeCubit>().setActiveIndex(1);
          }),
          _buildDrawerItem(
            context,
            Icons.card_giftcard_rounded,
            "My Wishes",
            () {
              Navigator.pop(context);
              context.read<HomeCubit>().setActiveIndex(2);
            },
          ),
          _buildDrawerItem(context, Icons.redeem_rounded, "Pledged Gifts", () {
            Navigator.pop(context);
            context.read<HomeCubit>().setActiveIndex(3);
          }),
          _buildDrawerItem(context, Icons.person_rounded, "Profile", () {
            Navigator.pop(context);
            context.read<HomeCubit>().setActiveIndex(4);
          }),
          Divider(),

          _buildDrawerItem(
            context,
            Icons.exit_to_app_rounded,
            "Sign Out",
            () {
              context.read<AuthCubit>().signOut().then((_) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
              });
            },
            iconColor: Colors.redAccent,
            textColor: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: "Manrope",
          color: textColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showAddOptions(BuildContext context, int activeIndex) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Add New",
                      style: TextStyle(
                        fontFamily: "Manrope",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              _buildAddOptionItem(
                context,
                Icons.person_add_rounded,
                "Add Friend",
                "Connect with new friends",
                Color(0xFF6C63FF).withOpacity(0.1),
                () {
                  Navigator.pop(context);
                  _showAddFriendDialog(context);
                },
              ),
              _buildAddOptionItem(
                context,
                Icons.event_rounded,
                "Create Event",
                "Add a new occasion",
                Color(0xFF03DAC6).withOpacity(0.1),
                () {
                  Navigator.pop(context);
                  _showAddEventDialog(context, activeIndex);
                },
              ),
              _buildAddOptionItem(
                context,
                Icons.card_giftcard_rounded,
                "Add Wish",
                "Create a gift wish list",
                Color(0xFFFF9E80).withOpacity(0.1),
                () {
                  Navigator.pop(context);
                  _showAddWishDialog(context, activeIndex);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddOptionItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color iconBgColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: "Manrope",
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: "Manrope",
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildFriendsPage(BuildContext context, HomeState state) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(context, state.user),
                SizedBox(height: 24),
                _buildSearchBar(context),
                SizedBox(height: 24),
              ],
            ),
          ),
          Expanded(
            child:
                state.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : state.friends.isEmpty
                    ? _buildEmptyFriendsList(context)
                    : _buildFriendsList(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4),
        Text(
          user.name.split(' ')[0] + " 👋",
          style: TextStyle(
            fontFamily: "Manrope",
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Track your gifts and events with friends",
          style: TextStyle(
            fontFamily: "Manrope",
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
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
      child: TextField(
        onChanged: (query) {
          // Implement search functionality
          if (query.isNotEmpty) {
            context.read<HomeCubit>().searchFriends(query);
          } else {
            context.read<HomeCubit>().loadFriends();
          }
        },
        decoration: InputDecoration(
          hintText: "Search friends...",
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildEmptyFriendsList(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            "No friends yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Add friends to start sharing wishes and events",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddFriendDialog(context),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add_rounded),
                SizedBox(width: 8),
                Text("Add Friend"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList(BuildContext context, HomeState state) {
    final friends = state.friends;
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
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
            child: FriendWidget(friend: friend),
          ),
        );
      },
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddFriendDialog();
      },
    );
  }

  void _showAddEventDialog(BuildContext context, int activeIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EventDialog(
          onSuccess: () {
            if (activeIndex != 1) {
              context.read<HomeCubit>().setActiveIndex(1);
            }
          },
        );
      },
    );
  }

  void _showAddWishDialog(BuildContext context, int activeIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddWishDialog(
          onSuccess: () {
            if (activeIndex != 2) {
              context.read<HomeCubit>().setActiveIndex(2);
            }
          },
        );
      },
    );
  }

  // Helper to wrap pages with app bar
  Widget _buildPageWithAppBar(BuildContext context, String title, Widget page) {
    return Column(
      children: [
        AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            title,
            style: TextStyle(
              fontFamily: "Manrope",
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          leading: Builder(
            builder:
                (context) => IconButton(
                  icon: Icon(
                    Icons.menu_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
          ),
          actions: [
            if (title == "Events" || title == "My Wishes")
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  if (title == "Events") {
                    _showAddEventDialog(context, 1);
                  } else if (title == "My Wishes") {
                    _showAddWishDialog(context, 2);
                  }
                },
              ),
            SizedBox(width: 8),
          ],
        ),
        Expanded(child: page),
      ],
    );
  }
}
