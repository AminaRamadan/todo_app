import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/layout/todo_layout/cubit/cubit.dart';
import 'package:todo_app/layout/todo_layout/cubit/states.dart';
import 'package:todo_app/shared/components/components.dart';


class DoneTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,CubitStates>(
      listener: (BuildContext context, state) {  },
      builder: (BuildContext context, Object? state) {
        var tasks = AppCubit.get(context).doneTasks;
        return taskBuilder(
          tasks: tasks
        );
      },

    );
  }
}
