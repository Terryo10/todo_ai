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

  // Stream of todos from local storage for a specific user
  Stream<List<Todo>> watchUserTodos(String uid) {
    return _todoBox.watch().map((_) => 
      _todoBox.values.where((todo) => todo.uid == uid).toList()
    );
  }

  // Get todos from local storage for a specific user
  List<Todo> getLocalUserTodos(String uid) {
    return _todoBox.values.where((todo) => todo.uid == uid).toList();
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

  // Sync all local todos with Firebase for a specific user
  Future<void> syncWithFirebase(String uid) async {
    if (!await _isOnline()) return;

    try {
      // Get all todos from Firebase for the specific user
      final firebaseTodos = await _firestore
          .collection('todos')
          .where('uid', isEqualTo: uid)
          .get();
      
      final firebaseTodosMap = {
        for (var doc in firebaseTodos.docs)
          doc.id: Todo.fromMap({...doc.data(), 'id': doc.id})
      };

      // Get all local todos for the user
      final localTodos = _todoBox.values.where((todo) => todo.uid == uid).toList();
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

  bool _isFirebaseTodoNewer(Todo firebaseTodo, Todo localTodo) {
    return firebaseTodo.createdTime.isAfter(localTodo.createdTime);
  }

  Future<bool> _isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Stream<ConnectivityResult> watchConnectivity() {
    return _connectivity.onConnectivityChanged;
  }
}

@HiveType(typeId: 0)
class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final typeId = 0;

  @override
  Todo read(BinaryReader reader) {
    return Todo(
      id: reader.readString(),
      uid: reader.readString(), // Added uid
      name: reader.readString(),
      createdTime: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      collaborators: List<String>.from(reader.readList()),
      isCompleted: reader.readBool(),
      tasks: List<Task>.from(reader.readList()),
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.uid); // Added uid
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
    return Task(
      id: reader.readString(),
      todoId: reader.readString(), // Added todoId
      name: reader.readString(),
      assignedTo: reader.readString(),
      reminderTime: reader.readInt() == 0 
          ? null 
          : DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isImportant: reader.readBool(),
      isCompleted: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.todoId); // Added todoId
    writer.writeString(obj.name);
    writer.writeString(obj.assignedTo ?? '');
    writer.writeInt(obj.reminderTime?.millisecondsSinceEpoch ?? 0);
    writer.writeBool(obj.isImportant);
    writer.writeBool(obj.isCompleted);
  }
}