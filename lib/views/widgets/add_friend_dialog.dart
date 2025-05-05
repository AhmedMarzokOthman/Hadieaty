import 'package:flutter/material.dart';
import 'package:hadieaty/controllers/user_controller.dart';

class AddFriendDialog extends StatefulWidget {
  const AddFriendDialog({super.key});

  @override
  State<AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text('Add Friend'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Friend Username',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFB6938)),
                  ),
                ),
                cursorColor: Color(0xFFFB6938),
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
              usernameController.clear();
            });
          },
          child: Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFB6938),
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            if (usernameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please enter a username')),
              );
              return;
            }

            try {
              final friend = await UserController().getUserByUsername(
                usernameController.text.trim(),
              );

              if (friend != null) {
                // Add friend logic here
                print(
                  '\x1B[32mFound user: ${friend.name} (${friend.username})\x1B[0m',
                );

                // Close dialog and show success message
                Navigator.pop(context);
                await UserController().addFriend(friend.username);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Friend request sent to ${friend.name}'),
                    duration: Duration(seconds: 1),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                // User not found
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User not found'),
                    duration: Duration(seconds: 1),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } catch (e) {
              // Handle error
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Text('Add Friend'),
        ),
      ],
    );
  }
}
