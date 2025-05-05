import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hadieaty/controllers/user_controller.dart';
import 'package:hadieaty/models/user_model.dart';
import 'package:hadieaty/views/events_page.dart';
import 'package:hadieaty/views/my_wishes_page.dart';
import 'package:hadieaty/views/pledged_gifts_page.dart';
import 'package:hadieaty/views/profile_page.dart';
import 'package:hadieaty/views/sign-in.page.dart';
import 'package:hadieaty/controllers/auth_controller.dart';
import 'package:hadieaty/views/widgets/add_friend_dialog.dart';
import 'package:hadieaty/views/widgets/add_wish_dialog.dart';
import 'package:hadieaty/views/widgets/event_dialog.dart';
import 'package:hadieaty/views/widgets/friend_widget.dart';
import 'package:hive/hive.dart';
import 'package:animations/animations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int activeIndex = 0;
  late Future<dynamic> _userFuture;

  Box<UserModel>? friendBox;
  List<Widget> _pages = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _userFuture = UserController().getUserFromLocal(uid);
    _pages = _getDefaultPages(); // Set default pages first
    _openFriendBox();
  }

  Future<void> _openFriendBox() async {
    friendBox = await Hive.openBox<UserModel>('friendBox');
    await _loadFriends();
  }

  List<UserModel> _getFriends() {
    return friendBox?.values.toList() ?? [];
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await UserController().getFriends();
      for (var friend in friends) {
        await UserController().saveFriendToLocal(friend);
      }
      _initializePages();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // print('Error loading friends: $e');
      _initializePages();
      setState(() {
        _initialized = true;
      });
    }
  }

  void _initializePages() {
    final friends = _getFriends();
    _pages = [
      ListView.builder(
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
      ),
      EventsPage(),
      MyWishesPage(),
      PledgedGiftsPage(),
      ProfilePage(),
    ];
  }

  List<Widget> _getDefaultPages() {
    return [
      Center(child: CircularProgressIndicator()),
      EventsPage(),
      MyWishesPage(),
      PledgedGiftsPage(),
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder(
      future: _userFuture,
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
        final user = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: activeIndex != 0 ? 120 : 200,
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
                                          _showAddEventDialog(context);
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
                                          _showAddWishDialog(context);
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
                    activeIndex != 0
                        ? Text(
                          activeIndex == 1
                              ? "Events List"
                              : activeIndex == 2
                              ? "Wishes List"
                              : activeIndex == 3
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
                                    snapshot.data!.profilePicture ?? "",
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
                                          "${_getFriends().length} Friends",
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
                    setState(() {
                      activeIndex = 0;
                    });
                    Navigator.pop(context);
                  },
                  child: ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Home'),
                  ),
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
                    setState(() {
                      activeIndex = 1;
                    });
                    Navigator.pop(context);
                  },
                  child: ListTile(
                    leading: Icon(Icons.event),
                    title: Text('Events'),
                  ),
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
                    setState(() {
                      activeIndex = 2;
                    });
                    Navigator.pop(context);
                  },
                  child: ListTile(
                    leading: Icon(Icons.card_giftcard),
                    title: Text('Wishes'),
                  ),
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
                    setState(() {
                      activeIndex = 3;
                    });
                    Navigator.pop(context);
                  },
                  child: ListTile(
                    leading: Icon(Icons.redeem),
                    title: Text('Pledged Gifts'),
                  ),
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
                    setState(() {
                      activeIndex = 4;
                    });
                    Navigator.pop(context);
                  },
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile'),
                  ),
                ),
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
                  onPressed: () async {
                    final value = await AuthController().signOut();
                    if (value["statusCode"] == 200) {
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => SignInPage()),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(value["data"])));
                      }
                    }
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
          bottomNavigationBar: CircleNavBar(
            activeIndex: activeIndex,
            activeIcons: const [
              Icon(Icons.home, color: Colors.white),
              Icon(Icons.event, color: Colors.white),
              Icon(Icons.card_giftcard, color: Colors.white),
              Icon(Icons.local_florist_rounded, color: Colors.white),
              Icon(Icons.person, color: Colors.white),
            ],
            inactiveIcons: const [
              Icon(Icons.home, color: Colors.white),
              Icon(Icons.event, color: Colors.white),
              Icon(Icons.card_giftcard, color: Colors.white),
              Icon(Icons.local_florist_rounded, color: Colors.white),
              Icon(Icons.person, color: Colors.white),
            ],
            color: Colors.white,
            circleColor: Colors.white,
            circleWidth: 75,
            onTap: (index) {
              setState(() {
                activeIndex = index;
              });
            },
            // padding: const EdgeInsets.only(left: 14, right: 14, bottom: 20),
            // cornerRadius: const BorderRadius.only(
            //   topLeft: Radius.circular(8),
            //   topRight: Radius.circular(8),
            //   bottomRight: Radius.circular(24),
            //   bottomLeft: Radius.circular(24),
            // ),
            iconDurationMillSec: 0,
            tabCurve: Curves.linear,
            shadowColor: Colors.grey,
            circleShadowColor: Colors.grey,
            elevation: 10,
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFFFFAB5D), Color(0xFFFB6938)],
            ),
            circleGradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFFFFAB5D), Color(0xFFFB6938)],
            ),
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
              key: ValueKey<int>(activeIndex),
              child: _pages[activeIndex],
            ),
          ),
          floatingActionButton:
              activeIndex == 2
                  ? FloatingActionButton(
                    onPressed: () => _showAddWishDialog(context),
                    shape: CircleBorder(),
                    backgroundColor: Color(0xFFFB6938),
                    child: Icon(Icons.add, color: Colors.white),
                  )
                  : null,
        );
      },
    );
  }

  // Add this method to the _HomePageState class
  void _showAddWishDialog(BuildContext context) {
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
            setState(() {
              activeIndex = index;
            });
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

  void _showAddEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EventDialog(activeIndex: activeIndex);
      },
    );
  }
}
