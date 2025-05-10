import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadieaty/constants/colors.dart';
import 'package:hadieaty/cubits/event/event_cubit.dart';
import 'package:hadieaty/cubits/event/event_state.dart';
import 'package:hadieaty/models/event_model.dart';
import 'package:hadieaty/views/widgets/event_card.dart';
import 'package:intl/intl.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Force EventCubit to load events when the page is built
    // This will help ensure we always have the latest events
    Future.microtask(() => context.read<EventCubit>().loadEvents());

    return BlocListener<EventCubit, EventState>(
      listener: (context, state) {
        // This listener will be called whenever the state changes
        log('EventState changed: ${state.events.length} events');
      },
      child: BlocBuilder<EventCubit, EventState>(
        key: UniqueKey(), // Add a key to ensure rebuild
        builder: (context, state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final events = state.getSortedAndFilteredEvents();

          return Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddEditEventDialog(context),
              backgroundColor: primaryColor,
              child: Icon(Icons.add, color: Colors.white),
            ),
            body: Column(
              children: [
                // Sorting and filtering controls
                Container(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Sort by options
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Row(
                          children: [
                            Text(
                              'Sort by: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 8),
                            Wrap(
                              spacing: 8,
                              children:
                                  ['date', 'name', 'type'].map((option) {
                                    bool isSelected = state.sortBy == option;
                                    return InkWell(
                                      onTap: () {
                                        context.read<EventCubit>().setSortBy(
                                          option,
                                        );
                                      },
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? primaryColor
                                                  : Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              option
                                                      .substring(0, 1)
                                                      .toUpperCase() +
                                                  option.substring(1),
                                              style: TextStyle(
                                                color:
                                                    isSelected
                                                        ? Colors.white
                                                        : Colors.black87,
                                                fontWeight:
                                                    isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                              ),
                                            ),
                                            if (isSelected) ...[
                                              SizedBox(width: 4),
                                              Icon(
                                                state.sortAscending
                                                    ? Icons.arrow_upward
                                                    : Icons.arrow_downward,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 12),

                      // Filter options
                      Row(
                        children: [
                          Text(
                            'Filter: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    ['All', 'Upcoming', 'Current', 'Past'].map((
                                      status,
                                    ) {
                                      bool isSelected =
                                          state.filterStatus == status;
                                      Color statusColor =
                                          status == 'All'
                                              ? Colors.blue
                                              : status == 'Upcoming'
                                              ? primaryColor
                                              : status == 'Current'
                                              ? Colors.green
                                              : Colors.grey;

                                      return Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: InkWell(
                                          onTap: () {
                                            context
                                                .read<EventCubit>()
                                                .setFilterStatus(status);
                                          },
                                          child: AnimatedContainer(
                                            duration: Duration(
                                              milliseconds: 200,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isSelected
                                                      ? statusColor
                                                      : statusColor.withAlpha(
                                                        30,
                                                      ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color:
                                                    isSelected
                                                        ? Colors.transparent
                                                        : statusColor.withAlpha(
                                                          30,
                                                        ),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              status,
                                              style: TextStyle(
                                                color:
                                                    isSelected
                                                        ? Colors.white
                                                        : statusColor,
                                                fontWeight:
                                                    isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 25),
                // Event list
                Expanded(
                  child:
                      events.isEmpty
                          ? Scaffold(
                            backgroundColor: Colors.white,
                            body: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 80,
                                    color: Colors.grey[300],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    state.filterStatus == 'All'
                                        ? 'No events found'
                                        : 'No ${state.filterStatus.toLowerCase()} events',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add events by pressing the + button',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                          : RefreshIndicator(
                            onRefresh: () async {
                              // Reload events when users pull to refresh
                              await context.read<EventCubit>().loadEvents();
                            },
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              itemCount: events.length,
                              itemBuilder: (context, index) {
                                final event = events[index];
                                return EventCard(
                                  event: event,
                                  onEdit:
                                      () => _showAddEditEventDialog(
                                        context,
                                        event,
                                      ),
                                  onDelete:
                                      () => _deleteEvent(context, event.id),
                                );
                              },
                            ),
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _deleteEvent(BuildContext context, String id) async {
    context.read<EventCubit>().deleteEvent(id).then((_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Event deleted successfully')));
    });
  }

  void _showAddEditEventDialog(
    BuildContext context, [
    EventModel? existingEvent,
  ]) {
    final TextEditingController nameController = TextEditingController(
      text: existingEvent?.name ?? '',
    );
    final TextEditingController typeController = TextEditingController(
      text: existingEvent?.type ?? '',
    );

    DateTime selectedDate = existingEvent?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                existingEvent == null ? 'Add New Event' : 'Edit Event',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Event Name',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Color(0xff595757)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                        ),
                      ),
                      cursorColor: primaryColor,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: typeController,
                      decoration: InputDecoration(
                        labelText: 'Event Type',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Color(0xff595757)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        hintText: 'e.g. Birthday, Graduation, Anniversary',
                      ),
                      cursorColor: primaryColor,
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
                            style: TextStyle(color: primaryColor),
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
                  child: Text('Cancel', style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    // Validate inputs
                    if (nameController.text.isEmpty ||
                        typeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }

                    final event = EventModel(
                      id:
                          existingEvent?.id ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      type: typeController.text,
                      date: selectedDate,
                    );

                    try {
                      if (existingEvent == null) {
                        await context.read<EventCubit>().addEvent(event);
                      } else {
                        await context.read<EventCubit>().updateEvent(event);
                      }

                      // Explicitly reload events after adding/updating
                      if (context.mounted) {
                        Navigator.pop(context);

                        // Force immediate reload
                        await context.read<EventCubit>().loadEvents();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Event ${existingEvent == null ? 'added' : 'updated'} successfully',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    existingEvent == null ? 'Add Event' : 'Save Changes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
