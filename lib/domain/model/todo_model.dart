import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String id;
  final String name;
  final DateTime createdTime;
  final List<String> collaborators;
  final bool isCompleted;
  final List<Task> tasks;

  Todo({
    required this.id,
    required this.name,
    required this.createdTime,
    required this.collaborators,
    this.isCompleted = false,
    required this.tasks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdTime': Timestamp.fromDate(createdTime),
      'collaborators': collaborators,
      'isCompleted': isCompleted,
      'tasks': tasks.map((task) => task.toMap()).toList(),
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      createdTime: (map['createdTime'] as Timestamp).toDate(),
      collaborators: List<String>.from(map['collaborators'] ?? []),
      isCompleted: map['isCompleted'] ?? false,
      tasks: (map['tasks'] as List<dynamic>?)
          ?.map((task) => Task.fromMap(task))
          .toList() ?? [],
    );
  }

  Todo copyWith({
    String? id,
    String? name,
    DateTime? createdTime,
    List<String>? collaborators,
    bool? isCompleted,
    List<Task>? tasks,
  }) {
    return Todo(
      id: id ?? this.id,
      name: name ?? this.name,
      createdTime: createdTime ?? this.createdTime,
      collaborators: collaborators ?? this.collaborators,
      isCompleted: isCompleted ?? this.isCompleted,
      tasks: tasks ?? this.tasks,
    );
  }
}

class Task {
  final String id;
  final String name;
  final String? assignedTo;
  final DateTime? reminderTime;
  final bool isImportant;
  final bool isCompleted;

  Task({
    required this.id,
    required this.name,
    this.assignedTo,
    this.reminderTime,
    this.isImportant = false,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'assignedTo': assignedTo,
      'reminderTime': reminderTime != null ? Timestamp.fromDate(reminderTime!) : null,
      'isImportant': isImportant,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      assignedTo: map['assignedTo'],
      reminderTime: map['reminderTime'] != null 
          ? (map['reminderTime'] as Timestamp).toDate()
          : null,
      isImportant: map['isImportant'] ?? false,
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Task copyWith({
    String? id,
    String? name,
    String? assignedTo,
    DateTime? reminderTime,
    bool? isImportant,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      assignedTo: assignedTo ?? this.assignedTo,
      reminderTime: reminderTime ?? this.reminderTime,
      isImportant: isImportant ?? this.isImportant,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}