import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadieaty/cubits/event/event_cubit.dart';
import 'package:hadieaty/cubits/event/event_state.dart';
import 'package:hadieaty/models/event_model.dart';
import 'package:hadieaty/views/widgets/event_card.dart';
import 'package:intl/intl.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCubit, EventState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final events = state.getSortedAndFilteredEvents();

        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddEditEventDialog(context),
            shape: CircleBorder(),
            backgroundColor: Color(0xFFFB6938),
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
                                                ? Color(0xFFFB6938)
                                                : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(20),
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
                                            ? Color(0xFFFB6938)
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
                                          duration: Duration(milliseconds: 200),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isSelected
                                                    ? statusColor
                                                    : statusColor.withAlpha(30),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
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
                        : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return EventCard(
                              event: event,
                              onEdit:
                                  () => _showAddEditEventDialog(context, event),
                              onDelete: () => _deleteEvent(context, event.id),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
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
                  child: Text('Cancel', style: TextStyle(color: Colors.black)),
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

                    if (existingEvent == null) {
                      await context.read<EventCubit>().addEvent(event);
                    } else {
                      await context.read<EventCubit>().updateEvent(event);
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Event ${existingEvent == null ? 'added' : 'updated'} successfully',
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    existingEvent == null ? 'Add Event' : 'Save Changes',
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
