import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/providers/task_form_provider.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/screens/add_new_task_screen.dart';
import 'package:task_manager/widgets/task_list.dart';
import 'package:task_manager/widgets/task_section.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task')),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final todayTasks = taskProvider.getTodayTasks;
          final upComingTasks = taskProvider.upComingTask;
          if (todayTasks.isEmpty && upComingTasks.isEmpty) {
            return Center(child: Text('No task added yet!!'));
          }
          return Column(
            children: [
              if (todayTasks.isNotEmpty)
                TaskSection(
                  labelText: 'Today Tasks',
                  content: TaskList(allTaskList: todayTasks),
                ),

              if (upComingTasks.isNotEmpty)
                TaskSection(
                  labelText: 'Upcoming Tasks',
                  content: TaskList(allTaskList: upComingTasks),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (context) => TaskFormProvider(),
                child: const AddNewTaskScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
