import 'package:flutter/material.dart';

class NewTasksScreen extends StatelessWidget {
  const NewTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 40.0,
          child: Text('20:00 PM'),
        ),
        SizedBox(width: 20.0),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'New Tasks',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
      ],
    );
  }
}
