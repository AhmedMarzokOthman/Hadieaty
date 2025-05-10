import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hadieaty/controllers/event_controller.dart';
import 'package:hadieaty/controllers/wish_controller.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:hadieaty/models/wish_model.dart';
import 'package:hadieaty/models/event_model.dart';

class AddWishDialog extends StatefulWidget {
  final TextEditingController? nameController;
  final TextEditingController? priceController;
  final VoidCallback? onSuccess;

  const AddWishDialog({
    super.key,
    this.nameController,
    this.priceController,
    this.onSuccess,
  });

  @override
  State<AddWishDialog> createState() => _AddWishDialogState();
}

class _AddWishDialogState extends State<AddWishDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  File? _selectedImage;
  String? _imageUrl;
  bool _isLoading = false;
  String? _selectedEventId;
  List<EventModel> _events = [];
  bool _loadingEvents = true;

  @override
  void initState() {
    super.initState();
    _nameController = widget.nameController ?? TextEditingController();
    _priceController = widget.priceController ?? TextEditingController();
    _fetchEvents();
  }

  @override
  void dispose() {
    // Only dispose controllers if we created them internally
    if (widget.nameController == null) {
      _nameController.dispose();
    }
    if (widget.priceController == null) {
      _priceController.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    try {
      // Use FirestoreService instead of directly accessing Hive
      final events = await EventController().getEvents();

      // Filter only upcoming and current events
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final filteredEvents =
          events.where((event) {
            final eventDate = DateTime(
              event.date.year,
              event.date.month,
              event.date.day,
            );
            return eventDate.isAtSameMomentAs(today) ||
                eventDate.isAfter(today);
          }).toList();

      if (mounted) {
        setState(() {
          _events = filteredEvents;
          _loadingEvents = false;
        });
      }
    } catch (e) {
      log('Error loading events: $e');
      if (mounted) {
        setState(() {
          _loadingEvents = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text('Add Wish to Wishlist'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Wish Name',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                cursorColor: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Wish Price',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                cursorColor: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 16),

              // Event dropdown
              _loadingEvents
                  ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                  : _events.isEmpty
                  ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No upcoming events available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                  : Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      hint: Text('Select an event (optional)'),
                      value: _selectedEventId,
                      isExpanded: true,
                      underline: SizedBox(),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('No event'),
                        ),
                        ..._events
                            .map(
                              (event) => DropdownMenuItem<String>(
                                value: event.id,
                                child: Text('${event.name} (${event.type})'),
                              ),
                            )
                            .toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedEventId = value;
                        });
                      },
                    ),
                  ),

              SizedBox(height: 16),
              _selectedImage != null
                  ? Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            if (_imageUrl != null) {
                              setState(() {
                                _selectedImage = null;
                                _imageUrl = null;
                                _isLoading = false;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  )
                  : Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                      ),
                      onPressed: () async {
                        final result = await _pickImageFromGallery();
                        if (result) {
                          setState(() {
                            // Image is already set in _pickImageFromGallery
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_rounded,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Add Image",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              _selectedImage = null;
            });
          },
          child: Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        _isLoading
            ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 2,
              ),
            )
            : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                // Validate inputs
                if (_nameController.text.isEmpty ||
                    _priceController.text.isEmpty ||
                    _selectedImage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill all fields and add an image'),
                    ),
                  );
                  return;
                }

                // Create and save wish
                final wish = WishModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text,
                  price: _priceController.text,
                  image: _imageUrl, // Store the image path as string
                  associatedEvent:
                      _selectedEventId, // Pass the selected event ID
                );

                try {
                  if (_imageUrl != null) {
                    await WishController().saveWishToLocal(wish);
                    await WishController().addWish(wish);
                  }
                  Navigator.pop(context);

                  // Clear the image after saving
                  setState(() {
                    _selectedImage = null;
                  });

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Wish added to your wishlist!'),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // If currently on the wishlist page, refresh it by changing to another tab and back
                  if (widget.onSuccess != null) {
                    widget.onSuccess!();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving wish: ${e.toString()}'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Add to Wishlist'),
            ),
      ],
    );
  }

  Future _pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (returnedImage == null) return;
    setState(() {
      _selectedImage = File(returnedImage.path);
    });
    setState(() {
      _isLoading = true;
    });
    await _uploadImageToCloudinary().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
    log(_imageUrl!);
  }

  Future<void> _uploadImageToCloudinary() async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/imigicloud/upload");
    final request =
        http.MultipartRequest("POST", url)
          ..fields["upload_preset"] = "hadieaty_preset"
          ..files.add(
            await http.MultipartFile.fromPath("file", _selectedImage!.path),
          );
    final response = await request.send();
    if (response.statusCode == 200) {
      final resData = await response.stream.toBytes();
      final resString = String.fromCharCodes(resData);
      final jsonMap = jsonDecode(resString);
      setState(() {
        final url = jsonMap["url"];
        _imageUrl = url;
      });
    }
  }
}
