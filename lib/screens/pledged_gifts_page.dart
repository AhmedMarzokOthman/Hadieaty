import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hadieaty/models/wish_model.dart';
import 'package:hadieaty/services/firestore_service.dart';
import 'package:intl/intl.dart';

class PledgedGiftsPage extends StatefulWidget {
  const PledgedGiftsPage({super.key});

  @override
  State<PledgedGiftsPage> createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _unpledgeGift(String friendUid, String giftId) async {
    await _firestoreService.unpledgeGift(friendUid, giftId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getPledgedGiftsWithDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFFFB6938)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading pledged gifts: ${snapshot.error}'),
            );
          }

          final pledgedGifts = snapshot.data ?? [];

          if (pledgedGifts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.redeem, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No pledged gifts yet',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pledge gifts from your friends\' wishlists',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: pledgedGifts.length,
            itemBuilder: (context, index) {
              final item = pledgedGifts[index];
              final wish = item['wish'] as WishModel;
              final friendName = item['friendName'] as String;

              return SafeArea(
                child: Card(
                  margin: EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      if (wish.image != null && wish.image!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            wish.image!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 180,
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    wish.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFB6938).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '\$${wish.price}',
                                    style: TextStyle(
                                      color: Color(0xFFFB6938),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'For: $friendName',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Pledged on: ${DateFormat.yMMMd().format(DateTime.now())}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () async {
                                    await _unpledgeGift(
                                      item['friendUid'] as String,
                                      wish.id,
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  icon: Icon(Icons.remove_circle_outline),
                                  label: Text('Unpledge'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getPledgedGiftsWithDetails() async {
    try {
      // Get the pledged gifts collection data
      final snapshot =
          await FirebaseFirestore.instance
              .collection("Store Data")
              .doc(_firestoreService.uid)
              .collection("myPledgedGifts")
              .get();

      List<Map<String, dynamic>> result = [];

      // Process each document
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final gift = WishModel.fromJson(data['gift']);
        final friendUid = data['friendUid'] as String;

        // Get friend details
        final friendDoc =
            await FirebaseFirestore.instance
                .collection("Store Data")
                .doc(friendUid)
                .get();

        final friendData = friendDoc.data() ?? {};
        final friendName = friendData['name'] ?? 'Unknown';

        result.add({
          'wish': gift,
          'friendUid': friendUid,
          'friendName': friendName,
        });
      }

      return result;
    } catch (e) {
      print('Error fetching pledged gifts: $e');
      return [];
    }
  }
}
