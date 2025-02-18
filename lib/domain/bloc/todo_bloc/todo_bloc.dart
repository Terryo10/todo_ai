import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../model/todo_model.dart';
import '../../repositories/todo_repository/todo_repository.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository _repository;
  StreamSubscription? _todosSubscription;
  StreamSubscription? _connectivitySubscription;

  TodoBloc({required TodoRepository repository})
      : _repository = repository,
        super(TodoInitial()) {
    // Register event handlers
    on<LoadTodos>((event, emit) async {
      await _onLoadTodos(event, emit);
    });
    
    on<AddTodo>((event, emit) async {
      await _onAddTodo(event, emit);
    });
    
    on<UpdateTodo>((event, emit) async {
      await _onUpdateTodo(event, emit);
    });
    
    on<DeleteTodo>((event, emit) async {
      await _onDeleteTodo(event, emit);
    });
    
    on<AddTask>((event, emit) async {
      await _onAddTask(event, emit);
    });
    
    on<UpdateTask>((event, emit) async {
      await _onUpdateTask(event, emit);
    });
    
    on<DeleteTask>((event, emit) async {
      await _onDeleteTask(event, emit);
    });

    // Set up connectivity listener
    _connectivitySubscription = _repository
        .watchConnectivity()
        .listen((connectivityResult) {
      if (connectivityResult != ConnectivityResult.none) {
        _repository.syncWithFirebase();
      }
    });

    // Set up todos listener
    _todosSubscription = _repository
        .watchTodos()
        .listen((todos) {
      add(LoadTodos()); // Trigger a reload when local data changes
    });
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      final todos = _repository.getLocalTodos();
      emit(TodoLoaded(todos: todos));
      // Try to sync with Firebase
      await _repository.syncWithFirebase();
    } catch (e) {
      emit(TodoError(message: 'Failed to load todos: $e'));
    }
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    try {
      final currentState = state;
      if (currentState is TodoLoaded) {
        final todo = Todo(
          id: const Uuid().v4(),
          name: event.name,
          createdTime: DateTime.now(),
          collaborators: event.collaborators,
          tasks: [],
        );

        await _repository.saveLocalTodo(todo);
        // State will be updated via the todos listener
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to add todo: $e'));
    }
  }

  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    try {
      final currentState = state;
      if (currentState is TodoLoaded) {
        await _repository.saveLocalTodo(event.todo);
        // State will be updated via the todos listener
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to update todo: $e'));
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    try {
      final currentState = state;
      if (currentState is TodoLoaded) {
        await _repository.deleteLocalTodo(event.todoId);
        // State will be updated via the todos listener
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to delete todo: $e'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TodoState> emit) async {
    try {
      final currentState = state;
      if (currentState is TodoLoaded) {
        final todos = _repository.getLocalTodos();
        final todo = todos.firstWhere((todo) => todo.id == event.todoId);
        
        final newTask = Task(
          id: const Uuid().v4(),
          name: event.taskName,
          assignedTo: event.assignedTo,
          reminderTime: event.reminderTime,
          isImportant: event.isImportant,
        );

        final updatedTodo = todo.copyWith(
          tasks: [...todo.tasks, newTask],
        );

        await _repository.saveLocalTodo(updatedTodo);
        // State will be updated via the todos listener
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to add task: $e'));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TodoState> emit) async {
    try {
      final currentState = state;
      if (currentState is TodoLoaded) {
        final todos = _repository.getLocalTodos();
        final todo = todos.firstWhere((todo) => todo.id == event.todoId);

        final updatedTasks = todo.tasks.map((task) {
          return task.id == event.task.id ? event.task : task;
        }).toList();

        final updatedTodo = todo.copyWith(tasks: updatedTasks);
        await _repository.saveLocalTodo(updatedTodo);
        // State will be updated via the todos listener
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to update task: $e'));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TodoState> emit) async {
    try {
      final currentState = state;
      if (currentState is TodoLoaded) {
        final todos = _repository.getLocalTodos();
        final todo = todos.firstWhere((todo) => todo.id == event.todoId);

        final updatedTasks = todo.tasks.where((task) => task.id != event.taskId).toList();
        final updatedTodo = todo.copyWith(tasks: updatedTasks);
        
        await _repository.saveLocalTodo(updatedTodo);
        // State will be updated via the todos listener
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to delete task: $e'));
    }
  }

  @override
  Future<void> close() {
    _todosSubscription?.cancel();
    _connectivitySubscription?.cancel();
    return super.close();
  }
}