part of 'todo_bloc.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object> get props => [];
}
class LoadTodos extends TodoEvent {}

class AddTodo extends TodoEvent {
  final String name;
  final List<String> collaborators;

  const AddTodo({required this.name, required this.collaborators});
}

class UpdateTodo extends TodoEvent {
  final Todo todo;

  const UpdateTodo({required this.todo});
}

class DeleteTodo extends TodoEvent {
  final String todoId;

  const DeleteTodo({required this.todoId});
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
}

class UpdateTask extends TodoEvent {
  final String todoId;
  final Task task;

  const UpdateTask({required this.todoId, required this.task});
}

class DeleteTask extends TodoEvent {
  final String todoId;
  final String taskId;

  const DeleteTask({required this.todoId, required this.taskId});
}
