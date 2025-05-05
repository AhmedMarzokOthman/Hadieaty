import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hadieaty/controllers/event_controller.dart';
import 'package:hadieaty/controllers/pledge_controller.dart';
import 'package:hadieaty/controllers/wish_controller.dart';
import 'package:hadieaty/models/event_model.dart';
import 'package:hadieaty/models/user_model.dart';
import 'package:hadieaty/models/wish_model.dart';
import 'package:intl/intl.dart';

class FriendDetailsPage extends StatefulWidget {
  final UserModel? friend;
  const FriendDetailsPage({super.key, this.friend});

  @override
  State<FriendDetailsPage> createState() => _FriendDetailsPageState();
}

class _FriendDetailsPageState extends State<FriendDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, String> eventNamesCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<String> _getEventName(String? eventId) async {
    if (eventId == null || eventId.isEmpty) {
      return '';
    }

    if (eventNamesCache.containsKey(eventId)) {
      return eventNamesCache[eventId]!;
    }

    try {
      final event = await EventController().getEventFromLocal(eventId);
      if (event != null) {
        eventNamesCache[eventId] = event.name;
        return event.name;
      }

      final events = await EventController().getFriendEvents(
        widget.friend!.uid,
      );
      final matchingEvent = events.firstWhere(
        (e) => e.id == eventId,
        orElse:
            () => EventModel(
              id: '',
              name: 'Unknown Event',
              type: '',
              date: DateTime.now(),
            ),
      );

      eventNamesCache[eventId] = matchingEvent.name;
      return matchingEvent.name;
    } catch (e) {
      return 'Unknown Event';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFAB5D), Color(0xFFFB6938)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Text(
          widget.friend?.name ?? "",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
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
        controller: _tabController,
        children: [_buildWishesTab(), _buildEventsTab()],
      ),
    );
  }

  Widget _buildWishesTab() {
    return FutureBuilder<List<WishModel>>(
      future: WishController().getFriendWishes(widget.friend!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error loading wishes: ${snapshot.error}"));
        }

        final wishes = snapshot.data ?? [];

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
                        future: _getEventName(wish.associatedEvent),
                        builder: (context, snapshot) {
                          return Row(
                            children: [
                              Icon(
                                Icons.event,
                                size: 16,
                                color: Colors.blue[700],
                              ),
                              SizedBox(width: 4),
                              Text(
                                'For: ${snapshot.data ?? 'Loading...'}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
                trailing:
                    wish.pledgedBy != null &&
                            wish.pledgedBy!["pldgerUid"] ==
                                FirebaseAuth.instance.currentUser?.uid
                        ? TextButton(
                          onPressed: () async {
                            await PledgeController().unpledgeGift(
                              widget.friend!.uid,
                              wish.id,
                            );
                            setState(() {});
                          },
                          style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                            backgroundColor: Colors.red[400],
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[400],
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              "Unpledge",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        : wish.pledgedBy == null
                        ? TextButton(
                          onPressed: () async {
                            await PledgeController().pledgeGift(
                              widget.friend!.uid,
                              wish,
                            );
                            setState(() {});
                          },
                          style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                            backgroundColor: Colors.green[400],
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[400],
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              "Pledge",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        : Text(
                          "Pledged",
                          style: TextStyle(color: Colors.red[400]),
                        ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventsTab() {
    return FutureBuilder<List<EventModel>>(
      future: EventController().getFriendEvents(widget.friend?.uid ?? ""),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error loading events: ${snapshot.error}"));
        }

        final events = snapshot.data ?? [];

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
      },
    );
  }
}
