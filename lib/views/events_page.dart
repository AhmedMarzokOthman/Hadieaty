import 'package:flutter/material.dart';
import 'package:hadieaty/controllers/event_controller.dart';
import 'package:hadieaty/models/event_model.dart';
import 'package:hadieaty/views/widgets/event_card.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late Box<EventModel> eventBox;
  bool isLoading = true;
  String sortBy = 'date'; // Default sort
  bool sortAscending = true;
  String filterStatus = 'All'; // Default filter: All, Upcoming, Current, Past

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    eventBox = await Hive.openBox<EventModel>('eventBox');
    setState(() {
      isLoading = false;
    });
  }

  List<EventModel> _getSortedAndFilteredEvents() {
    List<EventModel> events = eventBox.values.toList();

    // Apply filter
    if (filterStatus != 'All') {
      events = events.where((event) => event.status == filterStatus).toList();
    }

    // Apply sort
    events.sort((a, b) {
      int result;

      switch (sortBy) {
        case 'name':
          result = a.name.compareTo(b.name);
          break;
        case 'type':
          result = a.type.compareTo(b.type);
          break;
        case 'date':
        default:
          result = a.date.compareTo(b.date);
          break;
      }

      return sortAscending ? result : -result;
    });

    return events;
  }

  void _deleteEvent(String id) async {
    await eventBox.delete(id);
    await EventController().deleteEvent(id);
    setState(() {}); // Refresh UI
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Event deleted successfully')));
  }

  void _showAddEditEventDialog([EventModel? existingEvent]) {
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

                    await eventBox.put(event.id, event);
                    await EventController().addEvent(event);
                    Navigator.pop(context);
                    setState(() {}); // Refresh UI

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Event ${existingEvent == null ? 'added' : 'updated'} successfully',
                        ),
                      ),
                    );
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final events = _getSortedAndFilteredEvents();

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditEventDialog(),
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
                  color: Colors.black.withOpacity(0.05),
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
                              bool isSelected = sortBy == option;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (sortBy == option) {
                                      sortAscending = !sortAscending;
                                    } else {
                                      sortBy = option;
                                      sortAscending = true;
                                    }
                                  });
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
                                        option.substring(0, 1).toUpperCase() +
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
                                          sortAscending
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
                                bool isSelected = filterStatus == status;
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
                                      setState(() {
                                        filterStatus = status;
                                      });
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
                                                : statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? Colors.transparent
                                                  : statusColor.withOpacity(
                                                    0.5,
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
                              filterStatus == 'All'
                                  ? 'No events found'
                                  : 'No ${filterStatus.toLowerCase()} events',
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
                          onEdit: () => _showAddEditEventDialog(event),
                          onDelete: () => _deleteEvent(event.id),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
