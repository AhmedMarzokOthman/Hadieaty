import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadieaty/cubits/friend/friend_cubit.dart';
import 'package:hadieaty/cubits/friend/friend_state.dart';
import 'package:hadieaty/models/event_model.dart';
import 'package:intl/intl.dart';

class EventItem extends StatelessWidget {
  const EventItem({super.key, required this.event});
  final EventModel event;

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
      onExpansionChanged: (expanded) {
        if (expanded) {
          // Load wishes for this event when tile is expanded
          context.read<FriendCubit>().loadEventWishes(event.id);
        }
      },
      children: [
        BlocBuilder<FriendCubit, FriendState>(
          builder: (context, state) {
            if (state.isLoadingEventWishes) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }

            final wishes = state.eventWishes;

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

            return Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  wishes.map((wish) {
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
                  }).toList(),
            );
          },
        ),
      ],
    );
  }
}
