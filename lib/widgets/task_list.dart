import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/providers/task_form_provider.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/screens/add_new_task_screen.dart';
import 'package:task_manager/utils/extensions/date_extension.dart';
import 'package:task_manager/utils/extensions/string_extension.dart';

class TaskList extends StatelessWidget {
  const TaskList({super.key, required this.allTaskList});
  final List<Task> allTaskList;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: allTaskList.length,
      itemBuilder: (context, index) {
        final task = allTaskList[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider(
                  create: (context) => TaskFormProvider(),
                  child: AddNewTaskScreen(task: task),
                ),
              ),
            );
          },
          child: Dismissible(
            key: ValueKey(task.id),
            background: Container(
              padding: EdgeInsets.only(right: 10),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete, color: Colors.white, size: 25),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) {
              return getConfirmation(context: context);
            },
            onDismissed: (direction) async {
              await context.read<TaskProvider>().removeTask(id: task.id!);
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Checkbox(
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      value: task.isCompleted,
                      onChanged: (value) {
                        task.isCompleted = value!;
                      },
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          task.description,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(task.category.name.toCapitalize()),
                        Text(task.createdDateTime.toShortDate()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<bool?> getConfirmation({required BuildContext context}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete task'),
      content: Text('Are you sure to delete this task'),
      actions: [
        Row(
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Yes'),
            ),
          ],
        ),
      ],
    ),
  );
}
