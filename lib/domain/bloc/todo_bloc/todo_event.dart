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