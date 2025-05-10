import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadieaty/cubits/pledge/pledge_cubit.dart';
import 'package:hadieaty/cubits/pledge/pledge_state.dart';
import 'package:intl/intl.dart';

class PledgedGiftsPage extends StatelessWidget {
  final bool showAppBar;
  const PledgedGiftsPage({super.key, this.showAppBar = false});

  @override
  Widget build(BuildContext context) {
    // Load pledged gifts when the page is shown
    context.read<PledgeCubit>().loadPledgedGifts();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          showAppBar
              ? AppBar(
                title: Text('Pledged Gifts'),
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              )
              : AppBar(toolbarHeight: 0),
      body: BlocBuilder<PledgeCubit, PledgeState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFFFB6938)),
            );
          }

          if (state.error != null) {
            return Center(
              child: Text('Error loading pledged gifts: ${state.error}'),
            );
          }

          final pledgedGifts = state.pledgedGifts;

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
              final wish = item['wish'];
              final friendName = item['friendName'];

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
                                    color: Color(0xFFFB6938).withAlpha(30),
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
                                  onPressed: () {
                                    context.read<PledgeCubit>().unpledgeGift(
                                      item['friendUid'],
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
}
