import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadieaty/cubits/home/home_cubit.dart';
import 'package:hadieaty/cubits/home/home_state.dart';
import 'package:hadieaty/views/events_page.dart';
import 'package:hadieaty/views/my_wishes_page.dart';
import 'package:hadieaty/views/pledged_gifts_page.dart';
import 'package:hadieaty/views/profile_page.dart';
import 'package:hadieaty/views/sign-in.page.dart';
import 'package:hadieaty/cubits/auth/auth_cubit.dart';
import 'package:hadieaty/views/widgets/add_friend_dialog.dart';
import 'package:hadieaty/views/widgets/add_wish_dialog.dart';
import 'package:hadieaty/views/widgets/event_dialog.dart';
import 'package:hadieaty/views/widgets/friend_widget.dart';
import 'package:animations/animations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (!state.isInitialized) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = state.user;
        if (user == null) {
          return Center(child: Text("User not found"));
        }

        final List<Widget> pages = [
          _buildFriendsPage(context, state),
          EventsPage(),
          MyWishesPage(),
          PledgedGiftsPage(),
          ProfilePage(),
        ];

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: state.activeIndex != 0 ? 120 : 200,
            centerTitle: true,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFAB5D), Color(0xFFFB6938)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder:
                              (context) => Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    Scaffold.of(context).openDrawer();
                                  },
                                  icon: const Icon(
                                    Icons.menu,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                        ),
                        Text(
                          "Hadieaty",
                          style: TextStyle(
                            fontFamily: "FREESCPT",
                            fontSize: 44,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Add New'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: Icon(
                                          Icons.person_add,
                                          color: Color.fromARGB(
                                            255,
                                            57,
                                            190,
                                            45,
                                          ),
                                        ),
                                        title: Text('Add Friend'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _showAddFriendDialog(context);
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(
                                          Icons.event,
                                          color: Color(0xFFFFAB5D),
                                        ),
                                        title: Text('Create Event'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _showAddEventDialog(
                                            context,
                                            state.activeIndex,
                                          );
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(
                                          Icons.card_giftcard,
                                          color: Color(0xFFFB6938),
                                        ),
                                        title: Text('Add Wish'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _showAddWishDialog(
                                            context,
                                            state.activeIndex,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    state.activeIndex != 0
                        ? Text(
                          state.activeIndex == 1
                              ? "Events List"
                              : state.activeIndex == 2
                              ? "Wishes List"
                              : state.activeIndex == 3
                              ? "Pledged Gifts"
                              : "Profile",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                    user.profilePicture ?? "",
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 15), // Add spacing
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "${state.friends.length} Friends",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            elevation: 0,
          ),
          drawer: Drawer(
            backgroundColor: Colors.white,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: Color(0xFFFFAB5D)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hadieaty",
                        style: TextStyle(
                          fontFamily: "FREESCPT",
                          fontSize: 44,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDrawerItem(context, Icons.home, 'Home', 0),
                _buildDrawerItem(context, Icons.event, 'Events', 1),
                _buildDrawerItem(context, Icons.card_giftcard, 'Wishes', 2),
                _buildDrawerItem(context, Icons.redeem, 'Pledged Gifts', 3),
                _buildDrawerItem(context, Icons.person, 'Profile', 4),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    foregroundColor: Colors.grey,
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    context.read<AuthCubit>().signOut().then((_) {
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => SignInPage()),
                        );
                      }
                    });
                  },
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      'Logout',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: state.activeIndex,
            onTap: (index) {
              context.read<HomeCubit>().changeTab(index);
            },
            backgroundColor: Colors.white,
            selectedItemColor: Color(0xFFFFAB5D),
            unselectedItemColor: Color(0xFFFB6938),
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
              BottomNavigationBarItem(
                icon: Icon(Icons.card_giftcard),
                label: 'Wishes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_florist_rounded),
                label: 'Pledged Gifts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
          body: PageTransitionSwitcher(
            duration: Duration(milliseconds: 400),
            transitionBuilder: (
              Widget child,
              Animation<double> primaryAnimation,
              Animation<double> secondaryAnimation,
            ) {
              return FadeThroughTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(state.activeIndex),
              child: pages[state.activeIndex],
            ),
          ),
          floatingActionButton:
              state.activeIndex == 2
                  ? FloatingActionButton(
                    onPressed:
                        () => _showAddWishDialog(context, state.activeIndex),
                    shape: CircleBorder(),
                    backgroundColor: Color(0xFFFB6938),
                    child: Icon(Icons.add, color: Colors.white),
                  )
                  : null,
        );
      },
    );
  }

  Widget _buildFriendsPage(BuildContext context, HomeState state) {
    final friends = state.friends;

    return ListView.builder(
      itemCount: friends.isEmpty ? 1 : friends.length,
      itemBuilder: (context, index) {
        if (friends.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 100),
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No friends yet', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFB6938),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _showAddFriendDialog(context),
                  child: Text('Add Friend'),
                ),
              ],
            ),
          );
        }

        final friend = friends[index];
        return FriendWidget(friend: friend);
      },
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    int index,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        foregroundColor: Colors.grey,
        backgroundColor: Colors.white,
      ),
      onPressed: () {
        context.read<HomeCubit>().changeTab(index);
        Navigator.pop(context);
      },
      child: ListTile(leading: Icon(icon), title: Text(title)),
    );
  }

  void _showAddWishDialog(BuildContext context, int activeIndex) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddWishDialog(
          nameController: nameController,
          priceController: priceController,
          activeIndex: activeIndex,
          onIndexChanged: (index) {
            context.read<HomeCubit>().changeTab(index);
          },
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
        return EventDialog(activeIndex: activeIndex);
      },
    );
  }
}


// CircleNavBar(
//             activeIndex: state.activeIndex,
//             activeIcons: const [
//               Icon(Icons.home, color: Colors.white),
//               Icon(Icons.event, color: Colors.white),
//               Icon(Icons.card_giftcard, color: Colors.white),
//               Icon(Icons.local_florist_rounded, color: Colors.white),
//               Icon(Icons.person, color: Colors.white),
//             ],
//             inactiveIcons: const [
//               Icon(Icons.home, color: Colors.white),
//               Icon(Icons.event, color: Colors.white),
//               Icon(Icons.card_giftcard, color: Colors.white),
//               Icon(Icons.local_florist_rounded, color: Colors.white),
//               Icon(Icons.person, color: Colors.white),
//             ],
//             color: Colors.white,
//             circleColor: Colors.white,
//             circleWidth: 75,
//             onTap: (index) {
//               context.read<HomeCubit>().changeTab(index);
//             },
//             iconDurationMillSec: 0,
//             tabCurve: Curves.linear,
//             shadowColor: Colors.grey,
//             circleShadowColor: Colors.grey,
//             elevation: 10,
//             gradient: LinearGradient(
//               begin: Alignment.topRight,
//               end: Alignment.bottomLeft,
//               colors: [Color(0xFFFFAB5D), Color(0xFFFB6938)],
//             ),
//             circleGradient: LinearGradient(
//               begin: Alignment.topRight,
//               end: Alignment.bottomLeft,
//               colors: [Color(0xFFFFAB5D), Color(0xFFFB6938)],
//             ),
//           ),