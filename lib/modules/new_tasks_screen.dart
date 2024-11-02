import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shared/components/components.dart';
import '../shared/app_cubit/app_cubit.dart';
import '../shared/app_cubit/app_states.dart';

class NewTasksScreen extends StatelessWidget {
  const NewTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var tasks = AppCubit.get(context).newTasks;
        return taskBuilder(tasks: tasks);
      },
    );
  }
}
