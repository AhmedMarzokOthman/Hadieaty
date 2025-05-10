import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hadieaty/constants/colors.dart';
import 'package:hadieaty/models/event_model.dart';
import 'package:hadieaty/models/wish_model.dart';
import 'package:hive_flutter/adapters.dart';

class WishCard extends StatefulWidget {
  final WishModel wish;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const WishCard({
    super.key,
    required this.wish,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<WishCard> createState() => _WishCardState();
}

class _WishCardState extends State<WishCard> {
  EventModel? associatedEvent;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssociatedEvent();
  }

  Future<void> _loadAssociatedEvent() async {
    try {
      // Only try to load the event if there's an associated event ID
      if (widget.wish.associatedEvent != null) {
        final eventBox = await Hive.openBox<EventModel>('eventBox');
        final event = eventBox.get(widget.wish.associatedEvent);

        if (event != null) {
          setState(() {
            associatedEvent = event;
          });
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading associated event: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showWishDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Wish ${widget.wish.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price: \$${widget.wish.price}'),
                SizedBox(height: 8),
                if (widget.wish.pledgedBy != null)
                  Text(
                    'Pledged by: ${widget.wish.pledgedBy?["pldgerName"]}',
                    style: TextStyle(color: Colors.green),
                  ),
                if (associatedEvent != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'For event: ${associatedEvent!.name} (${associatedEvent!.type})',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
              ],
            ),
            actions: [
              if (widget.wish.pledgedBy == null)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onEdit();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text('Edit', style: TextStyle(color: Colors.white)),
                  ),
                ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onDelete();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text('Delete', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showWishDetailsDialog(context),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child:
                  widget.wish.image != null &&
                          widget.wish.image!.startsWith("http")
                      ? Image.network(
                        widget.wish.image!,
                        height: MediaQuery.of(context).size.height * 0.42,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                      : Image.file(
                        File(widget.wish.image!),
                        height: MediaQuery.of(context).size.height * 0.42,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.wish.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.wish.price}',
                          maxLines: 1,
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isLoading)
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      widget.wish.pledgedBy?["pldgerName"]?.toString() ??
                          "Not pledged",
                      maxLines: 1,
                      style: TextStyle(
                        color:
                            widget.wish.pledgedBy?["pldgerName"] == null
                                ? Colors.grey
                                : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (associatedEvent != null)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event, size: 12, color: primaryColor),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                associatedEvent!.name,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
