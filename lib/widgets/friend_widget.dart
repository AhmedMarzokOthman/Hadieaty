import 'package:flutter/material.dart';
import 'package:hadieaty/models/user_model.dart';
import 'package:hadieaty/screens/friend_details_page.dart';
import 'package:hadieaty/services/firestore_service.dart';

class FriendWidget extends StatelessWidget {
  final UserModel friend;
  const FriendWidget({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FriendDetailsPage(friend: friend),
          ),
        );
        // showDialog(
        //   context: context,
        //   builder:
        //       (context) => AlertDialog(
        //         title: Text("Friend"),
        //         content: SizedBox(
        //           width: MediaQuery.of(context).size.width * 0.8,
        //           child: Text("Friend"),
        //         ),
        //       ),
        // );
      },
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    friend.profilePicture ?? "",
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  friend.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.red[500],
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: FutureBuilder<int>(
                  future: _getUpcomingEventsCount(friend.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        "!",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      );
                    } else {
                      final count = snapshot.data ?? 0;
                      return Text(
                        "$count",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<int> _getUpcomingEventsCount(String friendUid) async {
    final allEvents = await FirestoreService().getFriendEvents(friendUid);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filter events to only include upcoming ones
    final upcomingEvents =
        allEvents.where((event) {
          final eventDate = DateTime(
            event.date.year,
            event.date.month,
            event.date.day,
          );
          return eventDate.isAfter(today) || eventDate.isAtSameMomentAs(today);
        }).toList();

    return upcomingEvents.length;
  }
}
