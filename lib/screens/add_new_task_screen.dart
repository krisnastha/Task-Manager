import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/providers/task_form_provider.dart';
import 'package:task_manager/providers/task_provider.dart';

class AddNewTaskScreen extends StatefulWidget {
  const AddNewTaskScreen({super.key, this.task});

  final Task? task;
  @override
  State<AddNewTaskScreen> createState() => _AddNewTaskScreenState();
}

class _AddNewTaskScreenState extends State<AddNewTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final formProvider = context.read<TaskFormProvider>();
      if (widget.task != null) {
        _titleController.text = widget.task!.title;
        _descController.text = widget.task!.description;
        formProvider.setDate(widget.task!.createdDateTime);
        formProvider.setCategory(widget.task!.category);
      } else {
        formProvider.reset();
      }
    });
  }

  // To select Date
  void selectDateForTask() async {
    log('this date picker function is called');
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      if (mounted) {
        log('selected date widget called');
        context.read<TaskFormProvider>().setDate(pickedDate);
      }
    }
    return;
  }

  void saveTask() async {
    final formProvider = context.read<TaskFormProvider>();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // shows error message if date is not selected
    if (formProvider.validateDate() != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          content: Text("Please select a date"),
        ),
      );
      return;
    }

    final taskProvider = context.read<TaskProvider>();
    bool success = false;
    if (widget.task != null) {
      // update existing task
      final updatedTask = widget.task!.copyWith(
        id: widget.task!.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        createdDateTime: formProvider.selectedDate,
        category: formProvider.selectedCategory,
      );

      success = await taskProvider.updateTask(todo: updatedTask);
    } else {
      // create new task
      final newTask = Task(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        createdDateTime: formProvider.selectedDate!,
        category: formProvider.selectedCategory,
      );

      success = await taskProvider.addNewTask(newtask: newTask);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
            content: Text(
              widget.task != null
                  ? "Task updated successfully"
                  : "Task added successfuly",
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
            content: Text("Failed to add task"),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExisted = widget.task != null;
    log('build method called');
    return Scaffold(
      appBar: AppBar(title: Text(isExisted ? 'Update Task' : 'Add new task')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 16,
            children: [
              // title input field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty || value == '') {
                    return 'Please enter your title';
                  } else if (value.length < 4) {
                    return 'Please enter at least 4 character length';
                  }
                  return null;
                },
              ),

              // description input field
              TextFormField(
                maxLines: 4,
                maxLength: 50,
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty || value == '') {
                    return 'Please enter your title';
                  } else if (value.length < 4) {
                    return 'Please enter at least 4 character length';
                  }
                  return null;
                },
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Selector<TaskFormProvider, DateTime?>(
                    selector: (ctx, provider) => provider.selectedDate,
                    builder: (context, date, child) {
                      return IconButton(
                        onPressed: selectDateForTask,
                        icon: date == null
                            ? Icon(Icons.calendar_month_outlined)
                            : Text('${date.year}-${date.month}-${date.day}'),
                      );
                    },
                  ),
                  // drop down button for category selection
                  Selector<TaskFormProvider, TaskCategory>(
                    selector: (context, provider) => provider.selectedCategory,
                    builder: (context, category, child) {
                      return DropdownButton(
                        value: category,
                        items: TaskCategory.values
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          log('drop down button built');
                          context.read<TaskFormProvider>().setCategory(value);
                        },
                      );
                    },
                  ),
                ],
              ),
              // cancel + add/update buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 12,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),

                  Consumer<TaskProvider>(
                    builder: (context, provider, child) {
                      return Expanded(
                        child: ElevatedButton(
                          onPressed: saveTask,
                          child: provider.isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(isExisted ? 'Update' : 'Add'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
