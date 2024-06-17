import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Delay to ensure that the widget is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scheduleDailyNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Text(
              'Your Daily Notifications',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        Icons.notifications,
                        color: Colors.deepPurple,
                      ),
                      title: Text(schedules[index]['title']),
                      subtitle: Text(
                        '${schedules[index]['hour'].toString().padLeft(2, '0')}:${schedules[index]['minute'].toString().padLeft(2, '0')} - ${schedules[index]['body']}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // List of times and messages
  final List<Map<String, dynamic>> schedules = [
    {'hour': 7, 'minute': 0, 'title': 'Wake Up', 'body': 'Time to wake up!'},
    {'hour': 8, 'minute': 0, 'title': 'Go to Gym', 'body': 'Time to hit the gym!'},
    {'hour': 9, 'minute': 0, 'title': 'Breakfast', 'body': 'Don’t forget to have breakfast!'},
    {'hour': 10, 'minute': 0, 'title': 'Meeting', 'body': 'You have a meeting now.'},
    {'hour': 12, 'minute': 0, 'title': 'Lunch', 'body': 'Time for lunch!'},
    {'hour': 14, 'minute': 0, 'title': 'Quick Nap', 'body': 'Take a quick nap.'},
    {'hour': 17, 'minute': 0, 'title': 'Go to Library', 'body': 'Time to go to the library.'},
    {'hour': 20, 'minute': 0, 'title': 'Dinner', 'body': 'Dinner time!'},
    {'hour': 22, 'minute': 0, 'title': 'Go to Sleep', 'body': 'Time to go to sleep.'},
  ];

  void scheduleDailyNotifications() {
    print("Scheduling notifications...");
    for (var schedule in schedules) {
      print("Scheduling: ${schedule['title']} at ${schedule['hour']}:${schedule['minute']}");
      scheduleNotification(
        schedule['hour'],
        schedule['minute'],
        schedule['title'],
        schedule['body']
      );
    }
  }

  void scheduleNotification(int hour, int minute, String title, String body) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: 'basic_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        icon: 'resource://mipmap/ic_launcher', // Using the default Flutter launcher icon
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
    );
    print("Notification scheduled: $title at $hour:$minute");
  }

  int createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }
}
