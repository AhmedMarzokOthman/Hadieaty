import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadieaty/constants/colors.dart';
import 'package:hadieaty/cubits/friend/friend_cubit.dart';
import 'package:hadieaty/cubits/friend/friend_state.dart';
import 'package:hadieaty/models/user_model.dart';
import 'package:intl/intl.dart';

class FriendDetailsPage extends StatelessWidget {
  final UserModel? friend;
  const FriendDetailsPage({super.key, this.friend});

  @override
  Widget build(BuildContext context) {
    // Make sure we initialize the friend in the cubit
    if (friend != null) {
      context.read<FriendCubit>().setFriend(friend!);
    }

    return BlocBuilder<FriendCubit, FriendState>(
      builder: (context, state) {
        return DefaultTabController(
          initialIndex: state.activeTabIndex,
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor2],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              title: Text(
                state.friend?.name ?? "",
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              bottom: TabBar(
                onTap: (index) {
                  context.read<FriendCubit>().changeTab(index);
                },
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(icon: Icon(Icons.card_giftcard), text: "Wishes"),
                  Tab(icon: Icon(Icons.event), text: "Events"),
                ],
              ),
            ),
            body: TabBarView(
              physics:
                  NeverScrollableScrollPhysics(), // Disable swiping to keep tab state in sync with cubit
              children: [
                _buildWishesTab(context, state),
                _buildEventsTab(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWishesTab(BuildContext context, FriendState state) {
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final wishes = state.wishes;

    if (wishes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("No wishes found", style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: wishes.length,
      itemBuilder: (context, index) {
        final wish = wishes[index];
        final currentUid = FirebaseAuth.instance.currentUser?.uid;
        final isPledgedByMe =
            wish.pledgedBy != null &&
            wish.pledgedBy!["pldgerUid"] == currentUid;
        final isPledgedByOther =
            wish.pledgedBy != null &&
            wish.pledgedBy!["pldgerUid"] != currentUid;

        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                wish.image ?? "",
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            ),
            title: Text(
              wish.name,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '\$${wish.price}',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ],
                ),
                if (wish.associatedEvent != null &&
                    wish.associatedEvent!.isNotEmpty)
                  FutureBuilder<String>(
                    future: context.read<FriendCubit>().getEventName(
                      wish.associatedEvent,
                    ),
                    builder: (context, snapshot) {
                      return Row(
                        children: [
                          Icon(Icons.event, size: 16, color: Colors.blue[700]),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'For: ${snapshot.data ?? 'Loading...'}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
            trailing:
                isPledgedByMe
                    ? _buildActionButton(
                      color: Colors.red[400]!,
                      onPressed:
                          () =>
                              context.read<FriendCubit>().unpledgeGift(wish.id),
                      label: "Unpledge",
                    )
                    : isPledgedByOther
                    ? Text("Pledged", style: TextStyle(color: Colors.red[400]))
                    : _buildActionButton(
                      color: Colors.green[400]!,
                      onPressed:
                          () => context.read<FriendCubit>().pledgeGift(wish),
                      label: "Pledge",
                    ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required Color color,
    required VoidCallback onPressed,
    required String label,
  }) {
    return BlocBuilder<FriendCubit, FriendState>(
      builder: (context, state) {
        // Only show loading state if we're in the middle of an operation
        final isLoading = state.isLoading;

        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
            backgroundColor: color,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(100),
            ),
            child:
                isLoading
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : Text(label, style: TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }

  Widget _buildEventsTab(BuildContext context, FriendState state) {
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final events = state.events;

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("No events found", style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final now = DateTime.now();
        final isPast =
            event.date.isBefore(now) &&
            !(event.date.year == now.year &&
                event.date.month == now.month &&
                event.date.day == now.day);
        final isUpcoming = event.date.isAfter(DateTime.now());

        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor:
                  isUpcoming
                      ? Color(0xFFFFAB5D)
                      : isPast
                      ? Colors.grey
                      : Colors.green,
              radius: 26,
              child: Icon(Icons.event, color: Colors.white, size: 28),
            ),
            title: Text(
              event.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${event.type}'),
                Text(
                  'Date: ${DateFormat('EEEE, MMMM d, yyyy').format(event.date)}',
                  style: TextStyle(
                    color: isUpcoming ? Colors.green[700] : Colors.grey,
                  ),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
