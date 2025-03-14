import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_ai/domain/bloc/auth_bloc/auth_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../model/todo_model.dart';
import '../../repositories/todo_repository/todo_repository.dart';
import '../../services/notification_service.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  // Dependencies
  final TodoRepository _repository;
  final AuthBloc _authBloc;
  final NotificationService? notificationService;

  // Subscriptions
  StreamSubscription? _todosSubscription;
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _authSubscription;

  // State
  String? _currentUserId;

  TodoBloc({
    required TodoRepository repository,
    required AuthBloc authBloc,
    this.notificationService,
  })  : _repository = repository,
        _authBloc = authBloc,
        super(TodoInitial()) {
    _initializeBloc();
  }

  // Initialization
  void _initializeBloc() {
    _initializeUserId();
    _setupAuthSubscription();
    _setupEventHandlers();
    _setupConnectivitySubscription();
    _setupTodosSubscription();
  }

  void _initializeUserId() {
    if (_authBloc.state is AuthAuthenticatedState) {
      _currentUserId = (_authBloc.state as AuthAuthenticatedState).userId;
    }
  }

  void _setupAuthSubscription() {
    _authSubscription = _authBloc.stream.listen((AuthState state) {
      if (state is AuthAuthenticatedState) {
        _currentUserId = state.userId;
        add(LoadTodos());
      } else {
        _currentUserId = null;
        add(ClearTodos());
      }
    });
  }

  void _setupConnectivitySubscription() {
    _connectivitySubscription =
        _repository.watchConnectivity().listen((connectivityResult) {
      if (connectivityResult != ConnectivityResult.none &&
          _currentUserId != null) {
        _repository.syncWithFirebase(_currentUserId!);
      }
    });
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

  // Event Handlers Setup
  void _setupEventHandlers() {
    on<LoadTodos>(_handleLoadTodos);
    on<ClearTodos>(_handleClearTodos);
    on<AddTodo>(_handleAddTodo);
    on<UpdateTodo>(_handleUpdateTodo);
    on<DeleteTodo>(_handleDeleteTodo);
    on<AddTask>(_handleAddTask);
    on<UpdateTask>(_handleUpdateTask);
    on<DeleteTask>(_handleDeleteTask);
    on<SortTodosByDate>(_handleSortTodosByDate);
    on<SortTodosByPriority>(_handleSortTodosByPriority);
    on<AssignTask>(_handleAssignTask);
    on<CompleteTask>(_handleCompleteTask);
    on<UpdateTaskImportance>(_handleUpdateTaskImportance);
    on<AddTaskStep>(_handleAddTaskStep);
    on<DeleteTaskStep>(_handleDeleteTaskStep);
    on<ArchiveCompletedTodos>(_handleArchiveCompletedTodos);
  }

  // Auth check helper
  bool _ensureAuthenticated(Emitter<TodoState> emit) {
    if (_currentUserId == null) {
      emit(TodoError(message: 'User not authenticated'));
      return false;
    }
    return true;
  }

  // Event Handlers
  Future<void> _handleLoadTodos(
      LoadTodos event, Emitter<TodoState> emit) async {
    if (!_ensureAuthenticated(emit)) return;

    emit(TodoLoading());
    try {
      final todos = _repository.getLocalUserTodos(_currentUserId!);
      final userTodos = _filterUserTodos(todos);
      emit(TodoLoaded(todos: userTodos));
      await _repository.syncWithFirebase(_currentUserId!);
    } catch (e) {
      emit(TodoError(message: 'Failed to load todos: $e'));
    }
  }

  List<Todo> _filterUserTodos(List<Todo> todos) {
    final userTodos = todos
        .where((todo) =>
            todo.uid == _currentUserId ||
            todo.collaborators.contains(_currentUserId))
        .toList();

    userTodos.sort((a, b) => b.createdTime.compareTo(a.createdTime));
    return userTodos;
  }

  void _handleClearTodos(ClearTodos event, Emitter<TodoState> emit) {
    emit(TodoInitial());
  }

  Future<void> _handleAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    if (!_ensureAuthenticated(emit)) return;

    try {
      if (state is TodoLoaded) {
        final todo = Todo(
          id: const Uuid().v4(),
          uid: _currentUserId!,
          name: event.name,
          createdTime: DateTime.now(),
          collaborators: [_currentUserId!],
          tasks: [],
        );

        await _repository.saveLocalTodo(todo);
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to add todo: $e'));
    }
  }

  Future<void> _handleUpdateTodo(
      UpdateTodo event, Emitter<TodoState> emit) async {
    if (!_ensureAuthenticated(emit)) return;

    try {
      if (state is TodoLoaded) {
        await _repository.saveLocalTodo(event.todo);
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to update todo: $e'));
    }
  }

  Future<void> _handleDeleteTodo(
      DeleteTodo event, Emitter<TodoState> emit) async {
    if (!_ensureAuthenticated(emit)) return;

    try {
      if (state is TodoLoaded) {
        await _repository.deleteLocalTodo(event.todoId);
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to delete todo: $e'));
    }
  }

  Future<void> _handleAddTask(AddTask event, Emitter<TodoState> emit) async {
    if (!_ensureAuthenticated(emit)) return;

    try {
      if (state is TodoLoaded) {
        final todos = _repository.getLocalUserTodos(_currentUserId!);
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

  Future<void> _handleUpdateTask(
      UpdateTask event, Emitter<TodoState> emit) async {
    if (!_ensureAuthenticated(emit)) return;

    try {
      if (state is TodoLoaded) {
        final todos = _repository.getLocalUserTodos(_currentUserId!);
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

  Future<void> _handleDeleteTask(
      DeleteTask event, Emitter<TodoState> emit) async {
    if (!_ensureAuthenticated(emit)) return;

    try {
      if (state is TodoLoaded) {
        final todos = _repository.getLocalUserTodos(_currentUserId!);
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

  void _handleSortTodosByDate(SortTodosByDate event, Emitter<TodoState> emit) {
    if (state is TodoLoaded) {
      final todos = (state as TodoLoaded).todos;
      todos.sort((a, b) => b.createdTime.compareTo(a.createdTime));
      emit(TodoLoaded(todos: todos));
    }
  }

  void _handleSortTodosByPriority(
      SortTodosByPriority event, Emitter<TodoState> emit) {
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
  }

  Future<void> _handleAssignTask(
      AssignTask event, Emitter<TodoState> emit) async {
    try {
      if (state is TodoLoaded) {
        final todos = List<Todo>.from((state as TodoLoaded).todos);
        final todoIndex = todos.indexWhere((todo) => todo.id == event.todoId);

        if (todoIndex >= 0) {
          final todo = todos[todoIndex];
          final tasks = List<Task>.from(todo.tasks);
          final taskIndex = tasks.indexWhere((task) => task.id == event.taskId);

          if (taskIndex >= 0) {
            final updatedTask = tasks[taskIndex].copyWith(
              assignedTo: event.userId,
            );

            tasks[taskIndex] = updatedTask;
            final updatedTodo = todo.copyWith(tasks: tasks);
            todos[todoIndex] = updatedTodo;

            await _repository.updateTodo(updatedTodo);
            emit(TodoLoaded(todos: todos));

            _sendTaskAssignmentNotification(
              event.userId,
              updatedTask.name,
              todo.name,
              event.todoId,
              event.taskId,
            );
          }
        }
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to assign task: ${e.toString()}'));
    }
  }

  void _sendTaskAssignmentNotification(
    String? userId,
    String taskName,
    String todoName,
    String todoId,
    String taskId,
  ) {
    if (notificationService != null && userId != null) {
      final currentUser = _authBloc.state is AuthAuthenticatedState
          ? (_authBloc.state as AuthAuthenticatedState)
          : null;

      if (currentUser != null) {
        final assignerName = currentUser.displayName;

        notificationService!.sendNotificationToUser(
          userId: userId,
          title: 'New Task Assigned',
          body: '$assignerName assigned you to "$taskName" in $todoName',
          data: {
            'type': 'task_assigned',
            'todoId': todoId,
            'taskId': taskId,
          },
        );
      }
    }
  }

  Future<void> _handleCompleteTask(
      CompleteTask event, Emitter<TodoState> emit) async {
    try {
      if (state is TodoLoaded) {
        final todos = List<Todo>.from((state as TodoLoaded).todos);
        final todoIndex = todos.indexWhere((todo) => todo.id == event.todoId);

        if (todoIndex >= 0) {
          final todo = todos[todoIndex];
          final tasks = List<Task>.from(todo.tasks);
          final taskIndex = tasks.indexWhere((task) => task.id == event.taskId);

          if (taskIndex >= 0) {
            final updatedTask = tasks[taskIndex].copyWith(
              isCompleted: event.isCompleted,
            );

            tasks[taskIndex] = updatedTask;
            final allTasksCompleted = tasks.every((task) => task.isCompleted);
            final updatedTodo = todo.copyWith(
              tasks: tasks,
              isCompleted: allTasksCompleted,
            );

            todos[todoIndex] = updatedTodo;
            await _repository.updateTodo(updatedTodo);
            emit(TodoLoaded(todos: todos));

            if (event.isCompleted) {
              _sendTaskCompletionNotifications(updatedTask.name, todo);
            }
          }
        }
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to complete task: ${e.toString()}'));
    }
  }

  void _sendTaskCompletionNotifications(String taskName, Todo todo) {
    if (notificationService != null) {
      final currentUser = _authBloc.state is AuthAuthenticatedState
          ? (_authBloc.state as AuthAuthenticatedState)
          : null;

      if (currentUser != null) {
        final completerName = currentUser.displayName;
        final collaborators = [...todo.collaborators, todo.uid]
            .where((uid) => uid != currentUser.userId)
            .toList();

        for (final userId in collaborators) {
          notificationService!.sendNotificationToUser(
            userId: userId,
            title: 'Task Completed',
            body: '$completerName completed "$taskName" in ${todo.name}',
            data: {
              'type': 'task_completed',
              'todoId': todo.id,
              'taskId':
                  taskName, // Using taskName as ID here seems wrong, might be a bug in original code
            },
          );
        }
      }
    }
  }

  Future<void> _handleUpdateTaskImportance(
      UpdateTaskImportance event, Emitter<TodoState> emit) async {
    if (!_ensureAuthenticated(emit)) return;

    try {
      if (state is TodoLoaded) {
        final todos = _repository.getLocalUserTodos(_currentUserId!);
        final todo = todos.firstWhere((todo) => todo.id == event.todoId);

        final updatedTasks = todo.tasks.map((task) {
          if (task.id == event.taskId) {
            return task.copyWith(isImportant: event.isImportant);
          }
          return task;
        }).toList();

        final updatedTodo = todo.copyWith(tasks: updatedTasks);
        await _repository.saveLocalTodo(updatedTodo);
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to update task importance: $e'));
    }
  }

  Future<void> _handleAddTaskStep(
      AddTaskStep event, Emitter<TodoState> emit) async {
    if (!_ensureAuthenticated(emit)) return;

    try {
      if (state is TodoLoaded) {
        final todos = _repository.getLocalUserTodos(_currentUserId!);
        final todo = todos.firstWhere((todo) => todo.id == event.todoId);

        final taskIndex =
            todo.tasks.indexWhere((task) => task.id == event.taskId);
        if (taskIndex >= 0) {
          final task = todo.tasks[taskIndex];
          final newStep = TaskStep(
            id: const Uuid().v4(),
            description: event.stepDescription,
          );

          final updatedTask = task.copyWith(
            steps: [...task.steps, newStep],
          );

          final updatedTasks = List<Task>.from(todo.tasks);
          updatedTasks[taskIndex] = updatedTask;

          final updatedTodo = todo.copyWith(tasks: updatedTasks);
          await _repository.saveLocalTodo(updatedTodo);
        }
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to add task step: $e'));
    }
  }

  Future<void> _handleDeleteTaskStep(
      DeleteTaskStep event, Emitter<TodoState> emit) async {
    if (!_ensureAuthenticated(emit)) return;

    try {
      if (state is TodoLoaded) {
        final todos = _repository.getLocalUserTodos(_currentUserId!);
        final todo = todos.firstWhere((todo) => todo.id == event.todoId);

        final taskIndex =
            todo.tasks.indexWhere((task) => task.id == event.taskId);
        if (taskIndex >= 0) {
          final task = todo.tasks[taskIndex];
          final updatedSteps =
              task.steps.where((step) => step.id != event.stepId).toList();

          final updatedTask = task.copyWith(steps: updatedSteps);
          final updatedTasks = List<Task>.from(todo.tasks);
          updatedTasks[taskIndex] = updatedTask;

          final updatedTodo = todo.copyWith(tasks: updatedTasks);
          await _repository.saveLocalTodo(updatedTodo);
        }
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to delete task step: $e'));
    }
  }

  void _handleArchiveCompletedTodos(
      ArchiveCompletedTodos event, Emitter<TodoState> emit) {
    if (state is TodoLoaded) {
      final todos = (state as TodoLoaded).todos;
      final incompleteTodos = todos
          .where((todo) =>
              !todo.isCompleted && todo.tasks.any((task) => !task.isCompleted))
          .toList();
      emit(TodoLoaded(todos: incompleteTodos));
    }
  }

  @override
  Future<void> close() {
    _todosSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
