import 'package:flutter/material.dart';
import 'package:task_manager/models/task.dart';

class TaskProvider extends ChangeNotifier {
  // to store list of task in a variable
  final List<Task> _allTasks = [];

  // getter functions
  List<Task> get allTask => _allTasks;

  /// Add new task
  void addNewTask({required Task newtask}) {
    final index = _allTasks.indexWhere((task) => task.id == newtask.id);
    if (index != -1) {
      _allTasks[index] = newtask;
    } else {
      _allTasks.add(newtask);
    }
    notifyListeners();
  }

  List<Task> get getTodayTasks {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return _allTasks.where((task) {
      final taskDate = DateTime(
        task.createdDateTime.year,
        task.createdDateTime.month,
        task.createdDateTime.day,
      );
      return taskDate.isAtSameMomentAs(todayDate);
    }).toList();
  }

  List<Task> get upComingTask {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _allTasks
        .where((task) => task.createdDateTime.isAfter(today))
        .toList();
  }

  /// Remove existing task
  void removeTask({required Task existedTask}) {
    _allTasks.remove(existedTask);
    notifyListeners();
  }
}
