part of 'todo_bloc.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodos extends TodoEvent {}

class AddTodo extends TodoEvent {
  final String name;

  const AddTodo({required this.name});

  @override
  List<Object> get props => [name];
}

class UpdateTodo extends TodoEvent {
  final Todo todo;

  const UpdateTodo({required this.todo});

  @override
  List<Object> get props => [todo];
}

class DeleteTodo extends TodoEvent {
  final String todoId;

  const DeleteTodo({required this.todoId});

  @override
  List<Object> get props => [todoId];
}

class AddTask extends TodoEvent {
  final String todoId;
  final String taskName;
  final String? assignedTo;
  final DateTime? reminderTime;
  final bool isImportant;

  const AddTask({
    required this.todoId,
    required this.taskName,
    this.assignedTo,
    this.reminderTime,
    this.isImportant = false,
  });

  @override
  List<Object?> get props => [todoId, taskName, assignedTo, reminderTime, isImportant];
}

class UpdateTask extends TodoEvent {
  final String todoId;
  final Task task;

  const UpdateTask({
    required this.todoId,
    required this.task,
  });

  @override
  List<Object> get props => [todoId, task];
}

class DeleteTask extends TodoEvent {
  final String todoId;
  final String taskId;

  const DeleteTask({
    required this.todoId,
    required this.taskId,
  });

  @override
  List<Object> get props => [todoId, taskId];
}

class ClearTodos extends TodoEvent {
  @override
  List<Object?> get props => [];
}

class SortTodosByDate extends TodoEvent {}
class SortTodosByPriority extends TodoEvent {}
class ArchiveCompletedTodos extends TodoEvent {}

class AssignTask extends TodoEvent {
  final String todoId;
  final String taskId;
  final String? userId; // Null means unassign

  const AssignTask({
    required this.todoId,
    required this.taskId,
    this.userId,
  });

  @override
  List<Object?> get props => [todoId, taskId, userId];
}

class CompleteTask extends TodoEvent {
  final String todoId;
  final String taskId;
  final bool isCompleted;

  const CompleteTask({
    required this.todoId,
    required this.taskId,
    required this.isCompleted,
  });

  @override
  List<Object> get props => [todoId, taskId, isCompleted];
}

class AddTaskStep extends TodoEvent {
  final String todoId;
  final String taskId;
  final String stepDescription;

  const AddTaskStep({
    required this.todoId,
    required this.taskId,
    required this.stepDescription,
  });

  @override
  List<Object> get props => [todoId, taskId, stepDescription];
}

class CompleteTaskStep extends TodoEvent {
  final String todoId;
  final String taskId;
  final String stepId;
  final bool isCompleted;

  const CompleteTaskStep({
    required this.todoId,
    required this.taskId,
    required this.stepId,
    required this.isCompleted,
  });

  @override
  List<Object> get props => [todoId, taskId, stepId, isCompleted];
}

class UpdateTaskImportance extends TodoEvent {
  final String todoId;
  final String taskId;
  final bool isImportant;

  const UpdateTaskImportance({
    required this.todoId,
    required this.taskId,
    required this.isImportant,
  });

  @override
  List<Object> get props => [todoId, taskId, isImportant];
}

class DeleteTaskStep extends TodoEvent {
  final String todoId;
  final String taskId;
  final String stepId;

  const DeleteTaskStep({
    required this.todoId,
    required this.taskId,
    required this.stepId,
  });

  @override
  List<Object> get props => [todoId, taskId, stepId];
}

