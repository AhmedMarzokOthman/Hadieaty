import 'package:flutter/material.dart';
import 'package:hadieaty/controllers/event_controller.dart';
import 'package:hadieaty/models/event_model.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class EventDialog extends StatefulWidget {
  final int? activeIndex;
  const EventDialog({super.key, this.activeIndex});

  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController typeController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: Text('Add New Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Event Name',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFB6938)),
                    ),
                  ),
                  cursorColor: Color(0xFFFB6938),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(
                    labelText: 'Event Type',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFB6938)),
                    ),
                    hintText: 'e.g. Birthday, Graduation, Anniversary',
                  ),
                  cursorColor: Color(0xFFFB6938),
                ),
                SizedBox(height: 16),
                // Date picker row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Date: ${DateFormat('MM/dd/yyyy').format(selectedDate)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Color(0xFFFB6938),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (picked != null && picked != selectedDate) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Text(
                        'Select Date',
                        style: TextStyle(color: Color(0xFFFB6938)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFB6938),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                // Validate inputs
                if (nameController.text.isEmpty ||
                    typeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please `fill all fields')),
                  );
                  return;
                }

                final event = EventModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  type: typeController.text,
                  date: selectedDate,
                );

                try {
                  final eventBox = await Hive.openBox<EventModel>('eventBox');
                  await eventBox.put(event.id, event);
                  await EventController().addEvent(event);
                  Navigator.pop(context);

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Event added successfully!')),
                  );

                  // If currently on the events page, refresh it
                  if (widget.activeIndex == 1) {
                    Navigator.pop(
                      context,
                      true,
                    ); // Return true to indicate refresh needed
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving event: ${e.toString()}'),
                    ),
                  );
                }
              },
              child: Text('Add Event'),
            ),
          ],
        );
      },
    );
  }
}
