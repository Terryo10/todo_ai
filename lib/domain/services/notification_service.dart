import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  NotificationService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  // Initialize FCM and request permissions
  Future<void> initialize({
    required Future<void> Function(RemoteMessage) onBackgroundMessage,
    required void Function(RemoteMessage) onMessageOpenedApp,
  }) async {
    if (_initialized) return;

    // Request permission
    await _requestPermission();

    // Setup background message handler
    // Using the global handler which matches the required type
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Setup foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Setup app opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Store FCM token in Firestore for this user
    await _updateFcmToken();

    _initialized = true;
  }

  // Request permission for notifications
  Future<void> _requestPermission() async {
    if (Platform.isIOS) {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint(
          'User notification permission: ${settings.authorizationStatus}');
    } else {
      // For Android, permission is requested automatically
      // but we need to create a notification channel
      if (!kIsWeb && Platform.isAndroid) {
        await _firebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
    );

    // Create notification channel for Android
    if (!kIsWeb && Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              'todo_notifications', // id
              'Todo Notifications', // name
              description: 'Notifications related to todo tasks', // description
              importance: Importance.high,
            ),
          );
    }
  }

  // Update FCM token in Firestore
  Future<void> _updateFcmToken() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final token = await _firebaseMessaging.getToken();
      if (token == null) return;

      await _firestore.collection('users').doc(userId).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Set up token refresh listener
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        await _firestore.collection('users').doc(userId).set({
          'fcmTokens': FieldValue.arrayUnion([newToken]),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
    }
  }

  // Handle foreground message
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Got a message in foreground! ${message.notification?.title}');

    if (message.notification != null) {
      _showLocalNotification(message);
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (message.notification == null) return;

    final notification = message.notification!;
    final android = notification.android;

    if (android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'todo_notifications',
            'Todo Notifications',
            channelDescription: 'Notifications related to todo tasks',
            icon: android.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: json.encode(message.data),
      );
    } else {
      // iOS or other platforms
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: json.encode(message.data),
      );
    }
  }

  // Send notification to a specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user FCM tokens from Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data();
      if (userData == null) return;

      final fcmTokens = List<String>.from(userData['fcmTokens'] ?? []);
      if (fcmTokens.isEmpty) return;

      // Here we would typically use Firebase Cloud Functions to send the notification
      // However, for testing purposes, we can use a direct API call
      // In production, this should be done from a secure server-side environment

      // For demonstration purposes only - you should implement this in Cloud Functions
      // This code won't actually work without your Firebase server key
      debugPrint(
          'Would send notification to user $userId with tokens: $fcmTokens');

      /* 
      // Example of how this would be implemented in a Cloud Function
      for (final token in fcmTokens) {
        await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'key=YOUR_SERVER_KEY', // Replace with your server key
          },
          body: jsonEncode({
            'notification': {
              'title': title,
              'body': body,
            },
            'data': data ?? {},
            'to': token,
          }),
        );
      }
      */
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  // Create a cloud function to handle the actual sending of notifications
  // You'll need to implement this in Firebase Cloud Functions
  String getCloudFunctionCode() {
    return '''
    const functions = require('firebase-functions');
    const admin = require('firebase-admin');
    admin.initializeApp();

    exports.sendNotification = functions.https.onCall(async (data, context) => {
      // Check if the user is authenticated
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated to send notifications'
        );
      }

      const { userId, title, body, additionalData } = data;
      
      // Get user FCM tokens
      const userDoc = await admin.firestore().collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw new functions.https.HttpsError(
          'not-found',
          'User not found'
        );
      }
      
      const userData = userDoc.data();
      const fcmTokens = userData.fcmTokens || [];
      
      if (fcmTokens.length === 0) {
        return { success: false, message: 'No FCM tokens found for user' };
      }
      
      // Send notification to each token
      const messages = fcmTokens.map(token => ({
        notification: {
          title,
          body,
        },
        data: additionalData || {},
        token,
      }));
      
      try {
        const response = await admin.messaging().sendAll(messages);
        return {
          success: true,
          successCount: response.successCount,
          failureCount: response.failureCount,
        };
      } catch (error) {
        throw new functions.https.HttpsError(
          'internal',
          'Error sending notification',
          error
        );
      }
    });

    // Listen for task assignments and send notifications
    exports.onTaskAssigned = functions.firestore
      .document('todos/{todoId}')
      .onUpdate(async (change, context) => {
        const newValue = change.after.data();
        const previousValue = change.before.data();
        
        // Get all tasks
        const newTasks = newValue.tasks || [];
        const oldTasks = previousValue.tasks || [];
        
        // Find newly assigned tasks
        for (const newTask of newTasks) {
          // Skip if no assignment
          if (!newTask.assignedTo) continue;
          
          // Find matching task in old data
          const oldTask = oldTasks.find(t => t.id === newTask.id);
          
          // Check if this is a new assignment
          if (!oldTask || oldTask.assignedTo !== newTask.assignedTo) {
            // This is a new assignment, send notification
            const assignedUserId = newTask.assignedTo;
            
            // Get todo details
            const todoSnapshot = await admin.firestore().collection('todos').doc(context.params.todoId).get();
            const todoData = todoSnapshot.data();
            
            if (!todoData) continue;
            
            // Get user details for the person who made the assignment
            let assignerName = 'Someone';
            try {
              const assignerDoc = await admin.firestore().collection('users').doc(newValue.lastUpdatedBy).get();
              if (assignerDoc.exists) {
                const assignerData = assignerDoc.data();
                assignerName = assignerData.displayName || assignerData.email || 'Someone';
              }
            } catch (e) {
              console.error('Error getting assigner details:', e);
            }
            
            // Send notification
            const userDoc = await admin.firestore().collection('users').doc(assignedUserId).get();
            if (userDoc.exists) {
              const userData = userDoc.data();
              const fcmTokens = userData.fcmTokens || [];
              
              if (fcmTokens.length > 0) {
                const message = {
                  notification: {
                    title: 'New Task Assigned',
                    body: `\${assignerName} assigned you to "\${newTask.name}" in \${todoData.name}`,
                  },
                  data: {
                    type: 'task_assigned',
                    todoId: context.params.todoId,
                    taskId: newTask.id,
                  },
                  tokens: fcmTokens,
                };
                
                try {
                  await admin.messaging().sendMulticast(message);
                } catch (error) {
                  console.error('Error sending notification:', error);
                }
              }
            }
          }
        }
        
        return null;
      });

    // Listen for task completions and send notifications
    exports.onTaskCompleted = functions.firestore
      .document('todos/{todoId}')
      .onUpdate(async (change, context) => {
        const newValue = change.after.data();
        const previousValue = change.before.data();
        
        // Get who made the update
        const updatedBy = newValue.lastUpdatedBy;
        if (!updatedBy) return null;
        
        // Get all tasks
        const newTasks = newValue.tasks || [];
        const oldTasks = previousValue.tasks || [];
        
        // Find newly completed tasks
        for (const newTask of newTasks) {
          // Skip if not completed
          if (!newTask.isCompleted) continue;
          
          // Find matching task in old data
          const oldTask = oldTasks.find(t => t.id === newTask.id);
          
          // Check if this task was just completed
          if (oldTask && !oldTask.isCompleted) {
            // This task was just completed
            
            // Get todo details
            const todoSnapshot = await admin.firestore().collection('todos').doc(context.params.todoId).get();
            const todoData = todoSnapshot.data();
            
            if (!todoData) continue;
            
            // Get user details for the person who completed the task
            let completerName = 'Someone';
            try {
              const completerDoc = await admin.firestore().collection('users').doc(updatedBy).get();
              if (completerDoc.exists) {
                const completerData = completerDoc.data();
                completerName = completerData.displayName || completerData.email || 'Someone';
              }
            } catch (e) {
              console.error('Error getting completer details:', e);
            }
            
            // Notify all collaborators except the one who completed it
            const collaborators = [...(todoData.collaborators || []), todoData.uid];
            const uniqueCollaborators = [...new Set(collaborators)].filter(id => id !== updatedBy);
            
            for (const userId of uniqueCollaborators) {
              const userDoc = await admin.firestore().collection('users').doc(userId).get();
              if (userDoc.exists) {
                const userData = userDoc.data();
                const fcmTokens = userData.fcmTokens || [];
                
                if (fcmTokens.length > 0) {
                  const message = {
                    notification: {
                      title: 'Task Completed',
                      body: `\${completerName} completed "\${newTask.name}" in \${todoData.name}`,
                    },
                    data: {
                      type: 'task_completed',
                      todoId: context.params.todoId,
                      taskId: newTask.id,
                    },
                    tokens: fcmTokens,
                  };
                  
                  try {
                    await admin.messaging().sendMulticast(message);
                  } catch (error) {
                    console.error('Error sending notification:', error);
                  }
                }
              }
            }
          }
        }
        
        return null;
      });
    ''';
  }
}
