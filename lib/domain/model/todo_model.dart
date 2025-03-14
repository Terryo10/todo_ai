import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String id;
  final String uid;
  final String name;
  final DateTime createdTime;
  final List<String> collaborators;
  final bool isCompleted;
  final List<Task> tasks;

  Todo({
    required this.id,
    required this.uid,
    required this.name,
    required this.createdTime,
    required this.collaborators,
    this.isCompleted = false,
    required this.tasks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid, // Added to map
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
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      createdTime: (map['createdTime'] as Timestamp).toDate(),
      collaborators: List<String>.from(map['collaborators'] ?? []),
      isCompleted: map['isCompleted'] ?? false,
      tasks: (map['tasks'] as List<dynamic>?)
              ?.map((task) => Task.fromMap(task))
              .toList() ??
          [],
    );
  }

  Todo copyWith({
    String? id,
    String? uid,
    String? name,
    DateTime? createdTime,
    List<String>? collaborators,
    bool? isCompleted,
    List<Task>? tasks,
  }) {
    return Todo(
      id: id ?? this.id,
      uid: uid ?? this.uid,
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
  final String todoId;
  final String name;
  final String? assignedTo;
  final DateTime? reminderTime;
  final bool isImportant;
  final bool isCompleted;
  // Add these new fields
  final List<TaskStep> steps;
  final String? note;
  final DateTime? dueDate;
  final String? repeatPattern;
  final List<String> attachments;
  final bool isInMyDay;

  Task({
    required this.id,
    required this.todoId,
    required this.name,
    this.assignedTo,
    this.reminderTime,
    this.isImportant = false,
    this.isCompleted = false,
    // Initialize the new fields with defaults
    this.steps = const [],
    this.note,
    this.dueDate,
    this.repeatPattern,
    this.attachments = const [],
    this.isInMyDay = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'todoId': todoId,
      'name': name,
      'assignedTo': assignedTo,
      'reminderTime':
          reminderTime != null ? Timestamp.fromDate(reminderTime!) : null,
      'isImportant': isImportant,
      'isCompleted': isCompleted,
      // Add the new fields to the map
      'steps': steps.map((step) => step.toMap()).toList(),
      'note': note,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'repeatPattern': repeatPattern,
      'attachments': attachments,
      'isInMyDay': isInMyDay,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      todoId: map['todoId'] ?? '',
      name: map['name'] ?? '',
      assignedTo: map['assignedTo'],
      reminderTime: map['reminderTime'] != null
          ? (map['reminderTime'] as Timestamp).toDate()
          : null,
      isImportant: map['isImportant'] ?? false,
      isCompleted: map['isCompleted'] ?? false,
      // Parse the new fields from the map
      steps: (map['steps'] as List<dynamic>?)
              ?.map((step) => TaskStep.fromMap(step))
              .toList() ??
          [],
      note: map['note'],
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as Timestamp).toDate()
          : null,
      repeatPattern: map['repeatPattern'],
      attachments: List<String>.from(map['attachments'] ?? []),
      isInMyDay: map['isInMyDay'] ?? false,
    );
  }

  Task copyWith({
    String? id,
    String? todoId,
    String? name,
    String? assignedTo,
    DateTime? reminderTime,
    bool? isImportant,
    bool? isCompleted,
    // Add the new fields to copyWith
    List<TaskStep>? steps,
    String? note,
    DateTime? dueDate,
    String? repeatPattern,
    List<String>? attachments,
    bool? isInMyDay,
  }) {
    return Task(
      id: id ?? this.id,
      todoId: todoId ?? this.todoId,
      name: name ?? this.name,
      assignedTo: assignedTo ?? this.assignedTo,
      reminderTime: reminderTime ?? this.reminderTime,
      isImportant: isImportant ?? this.isImportant,
      isCompleted: isCompleted ?? this.isCompleted,
      // Use the new fields in copyWith
      steps: steps ?? this.steps,
      note: note ?? this.note,
      dueDate: dueDate ?? this.dueDate,
      repeatPattern: repeatPattern ?? this.repeatPattern,
      attachments: attachments ?? this.attachments,
      isInMyDay: isInMyDay ?? this.isInMyDay,
    );
  }
}

class TaskStep {
  final String id;
  final String description;
  final bool isCompleted;

  TaskStep({
    required this.id,
    required this.description,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  factory TaskStep.fromMap(Map<String, dynamic> map) {
    return TaskStep(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  TaskStep copyWith({
    String? id,
    String? description,
    bool? isCompleted,
  }) {
    return TaskStep(
      id: id ?? this.id,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
