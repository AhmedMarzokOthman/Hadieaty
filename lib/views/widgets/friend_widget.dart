import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadieaty/cubits/friend_card/friend_card_cubit.dart';
import 'package:hadieaty/cubits/friend_card/friend_card_state.dart';
import 'package:hadieaty/models/user_model.dart';
import 'package:hadieaty/views/friend_details_page.dart';

class FriendWidget extends StatelessWidget {
  final UserModel friend;
  const FriendWidget({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => FriendCardCubit()..loadUpcomingEventsCount(friend.uid),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FriendDetailsPage(friend: friend),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      friend.profilePicture ?? "",
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    friend.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.red[500],
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: BlocBuilder<FriendCardCubit, FriendCardState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        );
                      }

                      return Text(
                        "${state.upcomingEventsCount}",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
