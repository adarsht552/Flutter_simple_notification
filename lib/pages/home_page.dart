import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  List<Map<String, String>> schedules = [];

  @override
  void initState() {
    super.initState();
    loadSchedules();
    // Initialize Awesome Notifications
    AwesomeNotifications().initialize(
      'resource://drawable/ic_launcher',
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Notification channel for basic notifications',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
        ),
      ],
    );
    // Schedule notifications for existing tasks
    scheduleAllNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Notifications'),
      ),
      body: Column(
        children: [
          Expanded(
            child: schedules.isEmpty
                ? Center(
                    child: Text('No schedules added yet.'),
                  )
                : ListView.builder(
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      var schedule = schedules[index];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(schedule['title']!),
                          subtitle: Text(schedule['time']!),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              removeSchedule(index);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                  ),
                ),
                SizedBox(height: 12.0),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _timeController,
                        decoration: InputDecoration(
                          labelText: 'Time (HH:mm)',
                        ),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    ElevatedButton(
                      onPressed: () {
                        showTimePickerDialog();
                      },
                      child: Icon(Icons.access_time),
                    ),
                  ],
                ),
                SizedBox(height: 12.0),
                ElevatedButton(
                  onPressed: () {
                    addSchedule();
                  },
                  child: Text('Add Task'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showTimePickerDialog() async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (_timeController.text.isNotEmpty) {
      List<String> parts = _timeController.text.split(':');
      initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      String formattedTime = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      _timeController.text = formattedTime;
    }
  }

  void addSchedule() {
    String title = _titleController.text;
    String time = _timeController.text;

    if (title.isNotEmpty && time.isNotEmpty) {
      List<String> parts = time.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      setState(() {
        schedules.add({
          'title': title,
          'time': time,
        });
      });

      scheduleNotification(hour, minute, title, 'Reminder: $title');

      saveSchedules();
      _titleController.clear();
      _timeController.clear();
    }
  }

void scheduleNotification(int hour, int minute, String title, String body) {
  try {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: 'basic_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        icon: 'resource://mipmap/ic_launcher',  // Using the app icon
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: false, // Change this to true if you want it to repeat daily
      ),
    );
    print('Notification scheduled for $hour:$minute');
  } catch (e) {
    print('Error scheduling notification: $e');
  }
}


  void scheduleAllNotifications() {
    for (var schedule in schedules) {
      List<String> parts = schedule['time']!.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      scheduleNotification(hour, minute, schedule['title']!, 'Reminder: ${schedule['title']}');
    }
  }

  void removeSchedule(int index) {
    setState(() {
      schedules.removeAt(index);
    });
    saveSchedules();
  }

  int createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  void saveSchedules() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      'schedules',
      schedules.map((e) => '${e['title']}|${e['time']}').toList(),
    );
  }

  void loadSchedules() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedSchedules = prefs.getStringList('schedules');

    if (savedSchedules != null && savedSchedules.isNotEmpty) {
      setState(() {
        schedules = savedSchedules.map((e) {
          List<String> parts = e.split('|');
          return {'title': parts[0], 'time': parts[1]};
        }).toList();
      });
    }
    
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}