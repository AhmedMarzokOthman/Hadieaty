import 'package:flutter/material.dart';
import 'package:hadieaty/controllers/wish_controller.dart';
import 'package:hadieaty/models/event_model.dart';
import 'package:hadieaty/models/wish_model.dart';
import 'package:intl/intl.dart';

class EventItem extends StatelessWidget {
  const EventItem({super.key, required this.event});
  final EventModel event;

  Future<List<WishModel>> _getWishesByEvent(String eventId) async {
    // Get all user wishes
    final wishes = await WishController().getWishes();

    // Filter wishes that are associated with this event
    return wishes.where((wish) => wish.associatedEvent == eventId).toList();
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

  @override
  Widget build(BuildContext context) {
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
}
