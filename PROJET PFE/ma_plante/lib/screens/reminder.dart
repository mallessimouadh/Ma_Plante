import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io'; 

class ReminderPage extends StatefulWidget {
  const ReminderPage({Key? key}) : super(key: key);

  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  DateTime? _selectedDateTime;
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, dynamic>> _reminders = [];
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _requestPermissions();
    _loadReminders();
    _testImmediateNotification();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Paris'));
    print('Timezone initialized: ${tz.local.name}');

    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification tapped: ${response.payload}');
      },
    );
    print('Notifications plugin initialized');

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminder_channel_id',
      'Reminders',
      description: 'Channel for plant care reminders',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      ledColor: Colors.green,
      enableLights: true,
    );

    final androidPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);

    if (Platform.isAndroid) {
      await _handleBatteryOptimizations();
    }

    print('Notification channel created');
  }

  Future<void> _handleBatteryOptimizations() async {
    try {
      var status = await Permission.ignoreBatteryOptimizations.status;

      if (status.isDenied) {
        status = await Permission.ignoreBatteryOptimizations.request();

        if (status.isPermanentlyDenied) {
          print('Battery optimization permission permanently denied');
          await openAppSettings();
        } else if (status.isGranted) {
          print('Battery optimization permission granted');
        }
      } else if (status.isGranted) {
        print('Battery optimization permission already granted');
      }
    } catch (e) {
      print('Error handling battery optimizations: $e');
    }
  }

  Future<void> _requestPermissions() async {
    final androidPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (Platform.isAndroid) {
      if (!(await androidPlugin?.canScheduleExactNotifications() ?? false)) {
        await androidPlugin?.requestExactAlarmsPermission();
      }
    }


    bool? notificationPermissionGranted =
        await androidPlugin?.requestNotificationsPermission();
    print('Notification permission granted: $notificationPermissionGranted');

    
    PermissionStatus notificationStatus = await Permission.notification.status;
    print('POST_NOTIFICATIONS status: $notificationStatus');
    if (notificationStatus.isDenied) {
      notificationStatus = await Permission.notification.request();
      print('POST_NOTIFICATIONS requested, new status: $notificationStatus');
    }

    PermissionStatus batteryStatus =
        await Permission.ignoreBatteryOptimizations.status;
    print('Ignore battery optimizations status: $batteryStatus');
    if (batteryStatus.isDenied) {
      batteryStatus = await Permission.ignoreBatteryOptimizations.request();
      print(
          'Ignore battery optimizations requested, new status: $batteryStatus');
    }
  }

  Future<void> _testImmediateNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'reminder_channel_id',
      'Reminders',
      channelDescription: 'Channel for plant care reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      visibility: NotificationVisibility.public,
      enableVibration: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification to check if notifications work.',
      notificationDetails,
    );
    print('Immediate notification triggered');
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final reminderList = prefs.getStringList('reminders') ?? [];
    setState(() {
      _reminders = reminderList.map((reminder) {
        final parts = reminder.split('|');
        return {
          'dateTime': DateTime.parse(parts[0]),
          'description': parts[1],
          'notificationId': int.parse(parts[2]),
        };
      }).toList();
    });
    print('Loaded reminders: $_reminders');
  }

  Future<void> _saveReminder() async {
    if (_selectedDateTime == null || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Veuillez sélectionner une date, une heure et une description'),
        ),
      );
      return;
    }
    if (_selectedDateTime!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez une date future')),
      );
      return;
    }

    final uniqueId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final reminder = {
      'dateTime': _selectedDateTime!,
      'description': _descriptionController.text,
      'notificationId': uniqueId,
    };

    setState(() {
      _reminders.add(reminder);
    });

    final prefs = await SharedPreferences.getInstance();
    final reminderString =
        '${_selectedDateTime!.toIso8601String()}|${_descriptionController.text}|$uniqueId';
    final reminderList = prefs.getStringList('reminders') ?? [];
    reminderList.add(reminderString);
    await prefs.setStringList('reminders', reminderList);

    await _scheduleNotification(reminder);
    _descriptionController.clear();
    setState(() {
      _selectedDateTime = null;
    });
  }

  Future<void> _deleteReminder(int index) async {
    final reminder = _reminders[index];
    final notificationId = reminder['notificationId'];

    await _flutterLocalNotificationsPlugin.cancel(notificationId);
    print('Canceled notification with ID: $notificationId');

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _reminders.removeAt(index);
    });

    final reminderList = _reminders.map((reminder) {
      return '${reminder['dateTime'].toIso8601String()}|${reminder['description']}|${reminder['notificationId']}';
    }).toList();
    await prefs.setStringList('reminders', reminderList);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rappel supprimé')),
    );
  }

  Future<void> _scheduleNotification(Map<String, dynamic> reminder) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'reminder_channel_id',
      'Reminders',
      channelDescription: 'Channel for plant care reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
      timeoutAfter: 0,
      ledColor: Colors.green,
      enableLights: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    final scheduledTime = reminder['dateTime'] as DateTime;
    final notificationId = reminder['notificationId'] as int;
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Rappel pour votre plante',
      reminder['description'],
      tzScheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: 'reminder|${reminder['description']}',
    );

    print(
        'Notification scheduled - ID: $notificationId, Time: $tzScheduledTime');
    await _logPendingNotifications();
  }

  Future<void> _logPendingNotifications() async {
    final pendingNotifications =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print('Pending notifications: ${pendingNotifications.length}');
    for (var notification in pendingNotifications) {
      print(
          'ID: ${notification.id}, Title: ${notification.title}, Scheduled Time: ${notification.payload}');
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  int _currentNavIndex = 0;

  void _onNavItemTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/homepage');
        break;
      case 1:
        Navigator.pushNamed(context, '/categories');
        break;
      case 2:
        Navigator.pushNamed(context, '/camera');
        break;
      case 3:
        Navigator.pushNamed(context, '/chat');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fond.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Rappel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _selectDateTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 27, 10, 10)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDateTime != null
                              ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} ${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
                              : 'Sélectionner la date et l\'heure',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Entrez une description (ex: Arroser la tomate)',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveReminder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Programmer le rappel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Rappels programmés',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _reminders.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun rappel programmé',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _reminders.length,
                          itemBuilder: (context, index) {
                            final reminder = _reminders[index];
                            final dateTime = reminder['dateTime'] as DateTime;
                            return Card(
                              color: Colors.white.withOpacity(0.1),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Text(
                                  '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  reminder['description'],
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteReminder(index),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
