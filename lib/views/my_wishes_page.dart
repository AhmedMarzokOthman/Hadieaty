import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hadieaty/constants/colors.dart';
import 'package:hadieaty/controllers/wish_controller.dart';
import 'package:hadieaty/models/wish_model.dart';
import 'package:hadieaty/views/widgets/wish_card.dart';
import 'package:hive_flutter/adapters.dart';

class MyWishesPage extends StatefulWidget {
  const MyWishesPage({super.key});

  @override
  State<MyWishesPage> createState() => _MyWishesPageState();
}

class _MyWishesPageState extends State<MyWishesPage> {
  late Box<WishModel> wishBox;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    try {
      wishBox = await Hive.openBox<WishModel>('wishBox');
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      // Handle Hive error - this might happen if the model schema changed
      // print('Error opening wishBox: $e');
      // Clear the box data if there's a format error
      await Hive.deleteBoxFromDisk('wishBox');
      wishBox = await Hive.openBox<WishModel>('wishBox');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _deleteWish(String id) async {
    try {
      // Get the wish before deleting to check if it's pledged
      final wish = wishBox.get(id);

      if (wish != null && wish.pledgedBy != null) {
        // Get the UID of the person who pledged this gift
        final pledgerUid = wish.pledgedBy!["pldgerUid"];

        if (pledgerUid != null) {
          // Remove from the pledger's myPledgedGifts collection
          await FirebaseFirestore.instance
              .collection("Store Data")
              .doc(pledgerUid)
              .collection("myPledgedGifts")
              .doc(id)
              .delete();
        }
      }

      // Delete from Hive and Firestore as usual
      await wishBox.delete(id);
      await WishController().deleteWish(id);

      setState(() {}); // Refresh UI

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wish removed from your wishlist')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error removing wish: ${e.toString().substring(0, 50)}...',
            ),
          ),
        );
      }
    }
  }

  void _editWish(WishModel wish) async {
    // Check if the wish is already pledged
    if (wish.pledgedBy != null) {
      // Show a message indicating that pledged wishes can't be modified
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pledged wishes cannot be modified'),
          backgroundColor: Colors.red[400],
        ),
      );
      return; // Exit the method early
    }

    // Continue with editing for non-pledged wishes
    final TextEditingController nameController = TextEditingController(
      text: wish.name,
    );
    final TextEditingController priceController = TextEditingController(
      text: wish.price,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Edit Wish'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Wish Name',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                    cursorColor: primaryColor,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Wish Price',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                    cursorColor: primaryColor,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                // Update wish and save
                final updatedWish = WishModel(
                  id: wish.id,
                  name: nameController.text,
                  price: priceController.text,
                  image: wish.image, // Keep the same image
                  pledgedBy: wish.pledgedBy, // Preserve the pledgedBy data
                  associatedEvent:
                      wish.associatedEvent, // Preserve associatedEvent
                );

                await wishBox.put(wish.id, updatedWish);
                await WishController().editWish(updatedWish);
                if (context.mounted) {
                  Navigator.pop(context);
                }
                setState(() {}); // Refresh UI

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Wish updated successfully')),
                  );
                }
              },
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (wishBox.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.card_giftcard, size: 80, color: Colors.grey[300]),
              SizedBox(height: 16),
              Text(
                'Your wishlist is empty',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Add wishes to your wishlist by pressing the + button',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: wishBox.values.length,
        itemBuilder: (context, index) {
          final wish = wishBox.getAt(index);
          return WishCard(
            wish: wish!,
            onDelete: () => _deleteWish(wish.id),
            onEdit: () => _editWish(wish),
          );
        },
      ),
    );
  }
}
