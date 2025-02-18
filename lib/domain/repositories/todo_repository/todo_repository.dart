import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../model/todo_model.dart';

class TodoRepository {
  final FirebaseFirestore _firestore;
  final Box<Todo> _todoBox;
  final Connectivity _connectivity;
  
  static const String _boxName = 'todos';
  
  TodoRepository({
    required FirebaseFirestore firestore,
    required Box<Todo> todoBox,
    required Connectivity connectivity,
  })  : _firestore = firestore,
        _todoBox = todoBox,
        _connectivity = connectivity;

  // Initialize Hive and open box
  static Future<Box<Todo>> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TodoAdapter());
    Hive.registerAdapter(TaskAdapter());
    return await Hive.openBox<Todo>(_boxName);
  }

  // Stream of todos from local storage
  Stream<List<Todo>> watchTodos() {
    return _todoBox.watch().map((_) => _todoBox.values.toList());
  }

  // Get todos from local storage
  List<Todo> getLocalTodos() {
    return _todoBox.values.toList();
  }

  // Add or update todo locally
  Future<void> saveLocalTodo(Todo todo) async {
    await _todoBox.put(todo.id, todo);
    await _syncToFirebase(todo);
  }

  // Delete todo locally
  Future<void> deleteLocalTodo(String todoId) async {
    await _todoBox.delete(todoId);
    await _deleteTodoFromFirebase(todoId);
  }

  // Sync a single todo to Firebase if online
  Future<void> _syncToFirebase(Todo todo) async {
    if (await _isOnline()) {
      try {
        await _firestore
            .collection('todos')
            .doc(todo.id)
            .set(todo.toMap(), SetOptions(merge: true));
      } catch (e) {
        print('Error syncing todo to Firebase: $e');
        // You might want to implement a retry mechanism here
      }
    }
  }

  // Delete todo from Firebase if online
  Future<void> _deleteTodoFromFirebase(String todoId) async {
    if (await _isOnline()) {
      try {
        await _firestore.collection('todos').doc(todoId).delete();
      } catch (e) {
        print('Error deleting todo from Firebase: $e');
      }
    }
  }

  // Sync all local todos with Firebase
  Future<void> syncWithFirebase() async {
    if (!await _isOnline()) return;

    try {
      // Get all todos from Firebase
      final firebaseTodos = await _firestore.collection('todos').get();
      final firebaseTodosMap = {
        for (var doc in firebaseTodos.docs)
          doc.id: Todo.fromMap({...doc.data(), 'id': doc.id})
      };

      // Get all local todos
      final localTodos = _todoBox.values.toList();
      final localTodosMap = {for (var todo in localTodos) todo.id: todo};

      // Sync Firebase to local
      for (var firebaseTodo in firebaseTodosMap.values) {
        final localTodo = localTodosMap[firebaseTodo.id];
        if (localTodo == null || 
            _isFirebaseTodoNewer(firebaseTodo, localTodo)) {
          await _todoBox.put(firebaseTodo.id, firebaseTodo);
        }
      }

      // Sync local to Firebase
      for (var localTodo in localTodosMap.values) {
        if (!firebaseTodosMap.containsKey(localTodo.id)) {
          await _firestore
              .collection('todos')
              .doc(localTodo.id)
              .set(localTodo.toMap());
        }
      }
    } catch (e) {
      print('Error syncing with Firebase: $e');
    }
  }

  // Helper to check if Firebase todo is newer than local todo
  bool _isFirebaseTodoNewer(Todo firebaseTodo, Todo localTodo) {
    // You might want to add a lastModified timestamp to your Todo model
    // For now, we'll just check the creation time
    return firebaseTodo.createdTime.isAfter(localTodo.createdTime);
  }

  // Check if device is online
  Future<bool> _isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Listen to connectivity changes and sync when online
  Stream<ConnectivityResult> watchConnectivity() {
    return _connectivity.onConnectivityChanged;
  }
}

// Hive type adapters
@HiveType(typeId: 0)
class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final typeId = 0;

  @override
  Todo read(BinaryReader reader) {
    // Implement reading from Hive
    // This is a simplified version - you'll need to add all fields
    return Todo(
      id: reader.readString(),
      name: reader.readString(),
      createdTime: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      collaborators: List<String>.from(reader.readList()),
      isCompleted: reader.readBool(),
      tasks: List<Task>.from(reader.readList()),
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    // Implement writing to Hive
    // This is a simplified version - you'll need to add all fields
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.createdTime.millisecondsSinceEpoch);
    writer.writeList(obj.collaborators);
    writer.writeBool(obj.isCompleted);
    writer.writeList(obj.tasks);
  }
}

@HiveType(typeId: 1)
class TaskAdapter extends TypeAdapter<Task> {
  @override
  final typeId = 1;

  @override
  Task read(BinaryReader reader) {
    // Implement reading from Hive
    return Task(
      id: reader.readString(),
      name: reader.readString(),
      assignedTo: reader.readString(),
      reminderTime: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isImportant: reader.readBool(),
      isCompleted: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    // Implement writing to Hive
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.assignedTo ?? '');
    writer.writeInt(obj.reminderTime?.millisecondsSinceEpoch ?? 0);
    writer.writeBool(obj.isImportant);
    writer.writeBool(obj.isCompleted);
  }
}