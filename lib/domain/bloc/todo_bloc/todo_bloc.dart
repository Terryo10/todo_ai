import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_ai/domain/bloc/auth_bloc/auth_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../model/todo_model.dart';
import '../../repositories/todo_repository/todo_repository.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository _repository;
  final AuthBloc _authBloc;
  StreamSubscription? _todosSubscription;
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _authSubscription;
  String? _currentUserId;

  TodoBloc({
    required TodoRepository repository,
    required AuthBloc authBloc,
  })  : _repository = repository,
        _authBloc = authBloc,
        super(TodoInitial()) {
    if (_authBloc.state is AuthAuthenticatedState) {
      _currentUserId = (_authBloc.state as AuthAuthenticatedState).userId;
    }

    // Listen to auth state changes
    _authSubscription = _authBloc.stream.listen((AuthState state) {
      if (state is AuthAuthenticatedState) {
        _currentUserId = state.userId;
        add(LoadTodos());
      } else {
        _currentUserId = null;
        add(ClearTodos());
      }
    });

    on<LoadTodos>((event, emit) async {
      if (_currentUserId == null) {
        emit(TodoError(message: 'User not authenticated'));
        return;
      }
      await _onLoadTodos(event, emit);
    });

    on<ClearTodos>((event, emit) {
      emit(TodoInitial());
    });

    on<AddTodo>((event, emit) async {
      if (_currentUserId == null) {
        emit(TodoError(message: 'User not authenticated'));
        return;
      }
      await _onAddTodo(event, emit);
    });

    on<UpdateTodo>((event, emit) async {
      if (_currentUserId == null) {
        emit(TodoError(message: 'User not authenticated'));
        return;
      }
      await _onUpdateTodo(event, emit);
    });

    on<DeleteTodo>((event, emit) async {
      if (_currentUserId == null) {
        emit(TodoError(message: 'User not authenticated'));
        return;
      }
      await _onDeleteTodo(event, emit);
    });

    on<AddTask>((event, emit) async {
      if (_currentUserId == null) {
        emit(TodoError(message: 'User not authenticated'));
        return;
      }
      await _onAddTask(event, emit);
    });

    on<UpdateTask>((event, emit) async {
      if (_currentUserId == null) {
        emit(TodoError(message: 'User not authenticated'));
        return;
      }
      await _onUpdateTask(event, emit);
    });

    on<DeleteTask>((event, emit) async {
      if (_currentUserId == null) {
        emit(TodoError(message: 'User not authenticated'));
        return;
      }
      await _onDeleteTask(event, emit);
    });

    on<SortTodosByDate>((event, emit) async {
      if (state is TodoLoaded) {
        final todos = (state as TodoLoaded).todos;
        todos.sort((a, b) => b.createdTime.compareTo(a.createdTime));
        emit(TodoLoaded(todos: todos));
      }
    });

    on<SortTodosByPriority>((event, emit) async {
      if (state is TodoLoaded) {
        final todos = (state as TodoLoaded).todos;
        todos.sort((a, b) {
          final aImportantTasksCount =
              a.tasks.where((task) => task.isImportant).length;
          final bImportantTasksCount =
              b.tasks.where((task) => task.isImportant).length;

          if (aImportantTasksCount != bImportantTasksCount) {
            return bImportantTasksCount.compareTo(aImportantTasksCount);
          }

          return b.createdTime.compareTo(a.createdTime);
        });
        emit(TodoLoaded(todos: todos));
      }
    });

    on<ArchiveCompletedTodos>((event, emit) async {
      if (state is TodoLoaded) {
        final todos = (state as TodoLoaded).todos;
        final incompleteTodos = todos
            .where((todo) =>
                !todo.isCompleted &&
                todo.tasks.any((task) => !task.isCompleted))
            .toList();
        emit(TodoLoaded(todos: incompleteTodos));
      }
    });

    _connectivitySubscription =
        _repository.watchConnectivity().listen((connectivityResult) {
      if (connectivityResult != ConnectivityResult.none &&
          _currentUserId != null) {
        _repository.syncWithFirebase(_currentUserId!);
      }
    });

    _setupTodosSubscription();
  }

  void _setupTodosSubscription() {
    _todosSubscription?.cancel();
    if (_currentUserId != null) {
      _todosSubscription =
          _repository.watchUserTodos(_currentUserId!).listen((todos) {
        add(LoadTodos());
      });
    }
  }

  @override
  Future<void> close() {
    _todosSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      final todos = _repository.getLocalUserTodos(_currentUserId ?? '');
      final userTodos = todos
          .where((todo) =>
              todo.uid == _currentUserId ||
              todo.collaborators.contains(_currentUserId))
          .toList();

      userTodos.sort((a, b) => b.createdTime.compareTo(a.createdTime));

      emit(TodoLoaded(todos: userTodos));
      await _repository.syncWithFirebase(_currentUserId ?? '');
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
          uid: _currentUserId ?? '',
          name: event.name,
          createdTime: DateTime.now(),
          collaborators: [_currentUserId ?? ''],
          tasks: [],
        );

        await _repository.saveLocalTodo(todo);
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
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to delete todo: $e'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TodoState> emit) async {
    try {
      final currentState = state;
      if (currentState is TodoLoaded) {
        final todos = _repository.getLocalUserTodos(_currentUserId ?? '');
        final todo = todos.firstWhere((todo) => todo.id == event.todoId);

        final newTask = Task(
          id: const Uuid().v4(),
          todoId: todo.id,
          name: event.taskName,
          assignedTo: event.assignedTo,
          reminderTime: event.reminderTime,
          isImportant: event.isImportant,
        );

        final updatedTodo = todo.copyWith(
          tasks: [...todo.tasks, newTask],
        );

        await _repository.saveLocalTodo(updatedTodo);
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to add task: $e'));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TodoState> emit) async {
    try {
      final currentState = state;
      if (currentState is TodoLoaded) {
        final todos = _repository.getLocalUserTodos(_currentUserId ?? '');
        final todo = todos.firstWhere((todo) => todo.id == event.todoId);

        final updatedTasks = todo.tasks.map((task) {
          return task.id == event.task.id ? event.task : task;
        }).toList();

        final updatedTodo = todo.copyWith(tasks: updatedTasks);
        await _repository.saveLocalTodo(updatedTodo);
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to update task: $e'));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TodoState> emit) async {
    try {
      final currentState = state;
      if (currentState is TodoLoaded) {
        final todos = _repository.getLocalUserTodos(_currentUserId ?? '');
        final todo = todos.firstWhere((todo) => todo.id == event.todoId);

        final updatedTasks =
            todo.tasks.where((task) => task.id != event.taskId).toList();
        final updatedTodo = todo.copyWith(tasks: updatedTasks);

        await _repository.saveLocalTodo(updatedTodo);
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to delete task: $e'));
    }
  }
}
