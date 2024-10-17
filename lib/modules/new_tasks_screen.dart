import 'package:flutter/material.dart';
import 'package:todo_app/components/components.dart';

class NewTasksScreen extends StatelessWidget {
  final List<Map>? tasks;

  const NewTasksScreen({super.key, this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) => buildTaskItem(),
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: double.infinity,
          height: 1.0,
          color: Colors.grey[300],
        ),
      ),
      itemCount: tasks?.length ?? 0,
    );
  }
}
