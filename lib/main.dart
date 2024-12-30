import 'dart:convert';
import 'package:crypto/crypto.dart'; // For sha256
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'welcome_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:camera/camera.dart';
import 'package:confetti/confetti.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppSettings(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskManagerState(),
      child: Consumer<TaskManagerState>(
        builder: (context, taskManagerState, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            title: 'Task_Master_Demo_AAY',
            theme: ThemeData(
              primarySwatch:
                  taskManagerState.isDarkMode ? Colors.blueGrey : Colors.blue,
              brightness: taskManagerState.isDarkMode
                  ? Brightness.dark
                  : Brightness.light,
              scaffoldBackgroundColor: taskManagerState.isDarkMode
                  ? Colors.blueGrey[900]
                  : Colors.blue[50],
              textTheme: TextTheme(
                bodyLarge: TextStyle(
                    color: taskManagerState.isDarkMode
                        ? Colors.white
                        : Colors.black),
                bodyMedium: TextStyle(
                    color: taskManagerState.isDarkMode
                        ? Colors.white
                        : Colors.black),
              ),
            ),
            home: WelcomePage(),
          );
        },
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var taskManagerState = context.watch<TaskManagerState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize:
                taskManagerState.isBigMode ? 24 : 18, // Adjusted font size
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: taskManagerState.isBigMode ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color:
                      taskManagerState.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Type your new username',
                  labelStyle: TextStyle(
                    color: taskManagerState.isDarkMode
                        ? Colors.white
                        : Colors.black,
                    fontSize: taskManagerState.isBigMode ? 18 : 14,
                  ),
                  filled: true,
                  fillColor: taskManagerState.isDarkMode
                      ? Colors.blueGrey[700]
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: TextStyle(
                  color:
                      taskManagerState.isDarkMode ? Colors.white : Colors.black,
                  fontSize: taskManagerState.isBigMode ? 18 : 14,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  taskManagerState.changeUsername(usernameController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Username updated successfully')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: taskManagerState.isDarkMode
                      ? Colors.blueGrey
                      : Colors.blue,
                  padding: EdgeInsets.symmetric(
                    horizontal: taskManagerState.isBigMode ? 60 : 50,
                    vertical: taskManagerState.isBigMode ? 20 : 15,
                  ),
                  textStyle: TextStyle(
                    fontSize: taskManagerState.isBigMode ? 20 : 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Update Username'),
              ),
              SizedBox(height: 20),

              // Profile Picture Section
              Text(
                'Profile Picture',
                style: TextStyle(
                  fontSize: taskManagerState.isBigMode ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color:
                      taskManagerState.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  backgroundImage: AssetImage(taskManagerState.profilePicture),
                  radius: taskManagerState.isBigMode ? 60 : 50,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePictureSelectionPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: taskManagerState.isDarkMode
                      ? Colors.blueGrey
                      : Colors.blue,
                  padding: EdgeInsets.symmetric(
                    horizontal: taskManagerState.isBigMode ? 60 : 50,
                    vertical: taskManagerState.isBigMode ? 20 : 15,
                  ),
                  textStyle: TextStyle(
                    fontSize: taskManagerState.isBigMode ? 20 : 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Change Profile Picture'),
              ),
              SizedBox(height: 30),
              Divider(
                color: taskManagerState.isDarkMode
                    ? Colors.white
                    : Colors.grey[400],
                thickness: 1,
              ),
              SizedBox(height: 20),

              // Accessibility Section
              Text(
                'Accessibility',
                style: TextStyle(
                  fontSize: taskManagerState.isBigMode ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color:
                      taskManagerState.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  taskManagerState.toggleBigMode();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: taskManagerState.isDarkMode
                      ? Colors.blueGrey
                      : Colors.blue,
                  padding: EdgeInsets.symmetric(
                    horizontal: taskManagerState.isBigMode ? 60 : 50,
                    vertical: taskManagerState.isBigMode ? 20 : 15,
                  ),
                  textStyle: TextStyle(
                    fontSize: taskManagerState.isBigMode ? 20 : 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  taskManagerState.isBigMode
                      ? 'Disable Big Text'
                      : 'Enable Big Text',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppSettings with ChangeNotifier {
  double _fontSizeScale = 1.0;

  double get fontSizeScale => _fontSizeScale;

  void updateFontSizeScale(double scale) {
    _fontSizeScale = scale;
    notifyListeners();
  }
}

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}

class TaskManagerState extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isDarkMode = false;
  bool _isBigMode = false;
  bool _notificationsEnabled = false;
  String _username = 'User';
  int _tokens = 0;
  int _level = 1;
  List<String> _achievements = [];
  Map<String, String> _achievementBadges = {};
  String _profilePicture = 'assets/images/pic1.png'; // Default profile picture
  String _currentBadge = '';

  final NotificationService _notificationService = NotificationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TaskManagerState() {
    _notificationService.initialize();
    _loadTasksFromFirestore();
  }

  List<Task> get tasks => _tasks;
  bool get isDarkMode => _isDarkMode;
  bool get isBigMode => _isBigMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get username => _username;
  int get tokens => _tokens;
  int get level => _level;
  List<String> get achievements => _achievements;
  Map<String, String> get achievementBadges => _achievementBadges;
  String get profilePicture => _profilePicture;
  String get currentBadge => _currentBadge;

  void toggleBigMode() {
    _isBigMode = !_isBigMode;
    notifyListeners();
  }

  Future<void> _loadTasksFromFirestore() async {
    try {
      final querySnapshot = await _firestore.collection('tasks').get();
      _tasks = querySnapshot.docs
          .map((doc) => Task.fromFirestore(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading tasks from Firestore: $e');
    }
  }

  void addTask(String title, DateTime deadline, String priority) async {
    Task task = Task(title: title, deadline: deadline, priority: priority);
    _tasks.add(task);
    notifyListeners();
    try {
      final docRef = await _firestore.collection('tasks').add(task.toMap());
      task.id = docRef.id;
      notifyListeners();
      if (_notificationsEnabled) {
        _notificationService.showNotification(
            'New Task Added', 'Task "$title" has been added.');
      }
    } catch (e) {
      print('Error adding task to Firestore: $e');
    }
    _checkAchievements();
  }

  void removeTask(int index) async {
    String taskTitle = _tasks[index].title;
    String taskId = _tasks[index].id;
    _tasks.removeAt(index);
    notifyListeners();
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      if (_notificationsEnabled) {
        _notificationService.showNotification(
            'Task Deleted', 'Task "$taskTitle" has been deleted.');
      }
    } catch (e) {
      print('Error removing task from Firestore: $e');
    }

    _checkAchievements();
  }

  void toggleTaskCompletion(int index) async {
    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    notifyListeners();
    try {
      await _firestore
          .collection('tasks')
          .doc(_tasks[index].id)
          .update({'isCompleted': _tasks[index].isCompleted});
      if (_tasks[index].isCompleted) {
        addToken();
      } else {
        removeToken();
      }
      if (_notificationsEnabled) {
        _notificationService.showNotification(
            'Task Updated', 'Task "${_tasks[index].title}" has been updated.');
      }
    } catch (e) {
      print('Error updating task completion in Firestore: $e');
    }

    _checkAchievements();
  }

  void editTask(int index, String newTitle, DateTime newDeadline,
      String newPriority) async {
    _tasks[index].title = newTitle;
    _tasks[index].deadline = newDeadline;
    _tasks[index].priority = newPriority;
    notifyListeners();
    try {
      await _firestore.collection('tasks').doc(_tasks[index].id).update({
        'title': newTitle,
        'deadline': newDeadline.toIso8601String(),
        'priority': newPriority,
      });
      if (_notificationsEnabled) {
        _notificationService.showNotification(
            'Task Edited', 'Task "$newTitle" has been edited.');
      }
    } catch (e) {
      print('Error editing task in Firestore: $e');
    }

    _checkAchievements();
  }

  void clearAllTasks() {
    tasks.clear();
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }

  void changeUsername(String newUsername) {
    _username = newUsername;
    notifyListeners();
  }

  void changeProfilePicture(String newProfilePicture) {
    _profilePicture = newProfilePicture;
    notifyListeners();
  }

  void addToken() {
    _tokens++;
    _checkLevelUp();
    _checkAchievements();
    notifyListeners();
  }

  void removeToken() {
    if (_tokens > 0) {
      _tokens--;
      notifyListeners();
    }
  }

  void _checkLevelUp() {
    int newLevel = (_tokens / 10).floor() + 1;
    if (newLevel > _level) {
      _level = newLevel;
      if (_notificationsEnabled) {
        _notificationService.showNotification(
            'Level Up!', 'You have reached level $_level!');
      }
    }
  }

  void _checkAchievements() {
    if (_tokens >= 10 && !_achievements.contains('First 10 Tokens')) {
      _achievements.add('First 10 Tokens');
      _achievementBadges['First 10 Tokens'] = 'assets/images/badStar.png';
      _showAchievementDialog('First 10 Tokens');
      _updateBadge('assets/images/badStar.png');
    }
    if (_tokens >= 50 && !_achievements.contains('First 50 Tokens')) {
      _achievements.add('First 50 Tokens');
      _achievementBadges['First 50 Tokens'] = 'assets/images/badDiamond.png';
      _showAchievementDialog('First 50 Tokens');
      _updateBadge('assets/images/badDiamond.png');
    }
    if (_tokens >= 100 && !_achievements.contains('First 100 Tokens')) {
      _achievements.add('First 100 Tokens');
      _achievementBadges['First 100 Tokens'] = 'assets/images/badFist.png';
      _showAchievementDialog('First 100 Tokens');
      _updateBadge('assets/images/badFist.png');
    }
    if (_tasks.length >= 10 && !_achievements.contains('First 10 Tasks')) {
      _achievements.add('First 10 Tasks');
      _achievementBadges['First 10 Tasks'] = 'assets/images/badStar.png';
      _showAchievementDialog('First 10 Tasks');
      _updateBadge('assets/images/badStar.png');
    }
    if (_tasks.length >= 50 && !_achievements.contains('First 50 Tasks')) {
      _achievements.add('First 50 Tasks');
      _achievementBadges['First 50 Tasks'] = 'assets/images/badDiamond.png';
      _showAchievementDialog('First 50 Tasks');
      _updateBadge('assets/images/badDiamond.png');
    }
    if (_tasks.length >= 100 && !_achievements.contains('First 100 Tasks')) {
      _achievements.add('First 100 Tasks');
      _achievementBadges['First 100 Tasks'] = 'assets/images/badFist.png';
      _showAchievementDialog('First 100 Tasks');
      _updateBadge('assets/images/badFist.png');
    }
    if (_level >= 5 && !_achievements.contains('Reached Level 5')) {
      _achievements.add('Reached Level 5');
      _achievementBadges['Reached Level 5'] = 'assets/images/badStar.png';
      _showAchievementDialog('Reached Level 5');
      _updateBadge('assets/images/badStar.png');
    }
    if (_level >= 10 && !_achievements.contains('Reached Level 10')) {
      _achievements.add('Reached Level 10');
      _achievementBadges['Reached Level 10'] = 'assets/images/badDiamond.png';
      _showAchievementDialog('Reached Level 10');
      _updateBadge('assets/images/badDiamond.png');
    }
  }

  void _updateBadge(String badgePath) {
    if (_currentBadge.isEmpty ||
        badgePath == 'assets/images/badFist.png' ||
        (badgePath == 'assets/images/badDiamond.png' &&
            _currentBadge != 'assets/images/badFist.png') ||
        (badgePath == 'assets/images/badStar.png' &&
            _currentBadge == 'assets/images/badStar.png')) {
      _currentBadge = badgePath;
      notifyListeners();
    }
  }

  void _showAchievementDialog(String achievement) {
    if (_notificationsEnabled) {
      _notificationService.showNotification(
          'Achievement Unlocked', achievement);
    }
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Achievement Unlocked!'),
          content: Text(achievement),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  double getProgressToBadge(int badgeLevel) {
    if (badgeLevel == 1) {
      return _tokens < 10 ? _tokens / 10 : 1.0;
    } else if (badgeLevel == 2) {
      return _tokens < 50 ? (_tokens - 10) / 40 : 1.0;
    } else if (badgeLevel == 3) {
      return _tokens < 100 ? (_tokens - 50) / 50 : 1.0;
    } else {
      return 1.0;
    }
  }

  String getBadgeMessage(int badgeLevel) {
    if (badgeLevel == 1) {
      return 'Earn 10 tokens to unlock the first badge!';
    } else if (badgeLevel == 2) {
      return 'Earn 50 tokens to unlock the second badge!';
    } else if (badgeLevel == 3) {
      return 'Earn 100 tokens to unlock the third badge!';
    } else {
      return 'You have unlocked all badges!';
    }
  }
}

class Task {
  String id;
  String title;
  bool isCompleted;
  DateTime deadline;
  String priority;

  Task({
    required this.title,
    this.isCompleted = false,
    required this.deadline,
    this.priority = 'Medium',
    this.id = '',
  });
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'deadline':
          deadline.toIso8601String(), // Save as ISO8601 string for Firestore
      'priority': priority,
    };
  }

  factory Task.fromFirestore(Map<String, dynamic> data, String id) {
    return Task(
      id: id,
      title: data['title'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      deadline: DateTime.parse(data['deadline']),
      priority: data['priority'] ?? 'Medium',
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final username = usernameController.text.trim();
                final password = passwordController.text.trim();

                if (username.isNotEmpty && password.isNotEmpty) {
                  try {
                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(username)
                        .get();
                    if (userDoc.exists &&
                        userDoc.data()?['password'] == hashPassword(password)) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TaskManagerHomePage(username: username),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid username or password')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error logging in: ${e.toString()}')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter all fields')),
                  );
                }
              },
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegistrationPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final username = usernameController.text.trim();
                final password = passwordController.text.trim();

                if (username.isNotEmpty && password.isNotEmpty) {
                  if (username.length < 3 || password.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Username must be at least 3 characters, and password 6 characters long')),
                    );
                    return;
                  }

                  if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Username must be alphanumeric')),
                    );
                    return;
                  }
                  if (!RegExp(r'^(?=.*[A-Z])(?=.*\d).{6,}$')
                      .hasMatch(password)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Password must include 1 uppercase and 1 number')),
                    );
                    return;
                  }

                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                          Center(child: CircularProgressIndicator()),
                    );

                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(username)
                        .get();

                    Navigator.pop(context); // Close the loading dialog

                    if (userDoc.exists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User already exists')),
                      );
                    } else {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(username)
                          .set({'password': hashPassword(password)});
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TaskManagerHomePage(username: username),
                        ),
                      );
                    }
                  } catch (e) {
                    Navigator.pop(context); // Close the loading dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Registration failed. Please try again.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter all fields')),
                  );
                }
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskManagerHomePage extends StatefulWidget {
  final String username;

  TaskManagerHomePage({required this.username});

  @override
  _TaskManagerHomePageState createState() => _TaskManagerHomePageState();
}

class _TaskManagerHomePageState extends State<TaskManagerHomePage> {
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    // Dispose controllers when no longer needed
    _confettiController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var taskManagerState = context.watch<TaskManagerState>();
    List<Task> filteredTasks = taskManagerState.tasks.where((task) {
      return task.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
    List<Task> todayTasks = [];
    List<Task> thisWeekTasks = [];
    List<Task> thisMonthTasks = [];
    List<Task> longTermTasks = [];
    DateTime now = DateTime.now();
    DateTime startOfNextWeek = now.add(Duration(days: 7 - now.weekday));
    DateTime startOfNextMonth = DateTime(now.year, now.month + 1, 1);

    for (var task in filteredTasks) {
      if (isSameDay(task.deadline, now)) {
        todayTasks.add(task);
      } else if (task.deadline.isBefore(startOfNextWeek)) {
        thisWeekTasks.add(task);
      } else if (task.deadline.isBefore(startOfNextMonth)) {
        thisMonthTasks.add(task);
      } else {
        longTermTasks.add(task);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(taskManagerState.profilePicture),
              radius: 20,
            ),
            SizedBox(width: 10),
            Text('Welcome, ${widget.username}'),
          ],
        ),
      ),
      drawer: _buildDrawer(context, taskManagerState),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Search Tasks',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await taskManagerState._loadTasksFromFirestore();
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildUserInfo(context, taskManagerState),
                      _buildTaskSection(
                          context, 'Today', todayTasks, Colors.blueAccent),
                      _buildTaskSection(context, 'This Week', thisWeekTasks,
                          Colors.greenAccent),
                      _buildTaskSection(context, 'This Month', thisMonthTasks,
                          Colors.orangeAccent),
                      _buildTaskSection(context, 'Long Term', longTermTasks,
                          Colors.redAccent),
                      AchievementsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.orange
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 80, // Adjust vertical position
            right: 20, // Adjust horizontal position
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTaskPage()),
                );
              },
              backgroundColor: Colors.blue,
              heroTag: 'addTask',
              child: Icon(Icons.add),
            ),
          ),
          Positioned(
            bottom: 20, // Adjust vertical position
            right: 20, // Adjust horizontal position
            child: FloatingActionButton(
              onPressed: () {
                _showClearAllDialog(context, taskManagerState);
              },
              backgroundColor: Colors.red,
              heroTag: 'clearTasks',
              child: Icon(Icons.delete_forever),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(
      BuildContext context, TaskManagerState taskManagerState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Tasks'),
        content: Text('Are you sure you want to clear all tasks?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              taskManagerState.clearAllTasks();
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  // Drawer widget remains unchanged
  Widget _buildDrawer(BuildContext context, TaskManagerState taskManagerState) {
    return Drawer(
      backgroundColor: taskManagerState.isDarkMode
          ? Colors.blueGrey[900]
          : Colors.white, // Background color adjusts based on theme
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: taskManagerState.isDarkMode
                    ? [Colors.blueGrey[900]!, Colors.blueGrey[700]!]
                    : [Colors.blue[50]!, Colors.blue[200]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(taskManagerState.profilePicture),
                  radius: 30,
                ),
                SizedBox(height: 10),
                Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          SwitchListTile(
            title: Text('Dark Mode'),
            value: taskManagerState.isDarkMode,
            onChanged: (bool value) {
              taskManagerState.toggleDarkMode();
            },
            secondary: Icon(Icons.brightness_6),
          ),
          SwitchListTile(
            title: Text('Enable Notifications'),
            value: taskManagerState.notificationsEnabled,
            onChanged: (bool value) {
              taskManagerState.toggleNotifications();
            },
            secondary: Icon(Icons.notifications),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(
      BuildContext context, TaskManagerState taskManagerState) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(taskManagerState.profilePicture),
                  radius: 30,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${taskManagerState.username}!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: taskManagerState.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Level: ${taskManagerState.level}',
                      style: TextStyle(
                        fontSize: 16,
                        color: taskManagerState.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                // Display the current badge if it exists
                if (taskManagerState.currentBadge.isNotEmpty)
                  Column(
                    children: [
                      Text(
                        'Current Badge',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: taskManagerState.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      SizedBox(height: 5),
                      Image.asset(
                        taskManagerState.currentBadge,
                        width: 50,
                        height: 50,
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tokens:',
                      style: TextStyle(
                        fontSize: 16,
                        color: taskManagerState.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    Text(
                      '${taskManagerState.tokens}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: taskManagerState.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
                Image.asset(
                  'assets/images/token.png',
                  width: 50,
                  height: 50,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSection(
      BuildContext context, String title, List<Task> tasks, Color color) {
    var taskManagerState = context.watch<TaskManagerState>();

    int totalTasks = tasks.length;
    int completedTasks = tasks.where((task) => task.isCompleted).length;
    double completionPercentage =
        totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: ExpansionTile(
        backgroundColor: color.withAlpha((0.1 * 255).toInt()),
        title: Text(
          title,
          style: TextStyle(
            color: taskManagerState.isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: totalTasks > 0 ? completedTasks / totalTasks : 0,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                SizedBox(height: 10),
                Text(
                  'Completion: ${completionPercentage.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: taskManagerState.isDarkMode
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tokens: ${taskManagerState.tokens}',
                      style: TextStyle(
                        color: taskManagerState.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    SizedBox(width: 5),
                    Image.asset(
                      'assets/images/token.png',
                      width: 24,
                      height: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
          ...tasks.map((task) {
            return Dismissible(
              key: Key(task.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                taskManagerState
                    .removeTask(taskManagerState.tasks.indexOf(task));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${task.title} dismissed')),
                );
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: ListTile(
                title: Text(
                  task.title,
                  style: TextStyle(
                    color: taskManagerState.isDarkMode
                        ? Colors.white
                        : Colors.black,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  'Due: ${DateFormat.yMMMd().format(task.deadline)}',
                  style: TextStyle(
                    color: taskManagerState.isDarkMode
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        task.isCompleted
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: taskManagerState.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                      onPressed: () {
                        if (!task.isCompleted) {
                          _confettiController.play();
                        }
                        taskManagerState.toggleTaskCompletion(
                            taskManagerState.tasks.indexOf(task));
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.star,
                        color: task.priority == 'High'
                            ? Colors.red
                            : task.priority == 'Medium'
                                ? Colors.orange
                                : Colors.green,
                      ),
                      onPressed: () {
                        String newPriority;
                        if (task.priority == 'High') {
                          newPriority = 'Medium';
                        } else if (task.priority == 'Medium') {
                          newPriority = 'Low';
                        } else {
                          newPriority = 'High';
                        }
                        taskManagerState.editTask(
                            taskManagerState.tasks.indexOf(task),
                            task.title,
                            task.deadline,
                            newPriority);
                      },
                    ),
                  ],
                ),
                onLongPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditTaskPage(
                            task: task,
                            index: taskManagerState.tasks.indexOf(task))),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class AddTaskPage extends StatefulWidget {
  @override
  AddTaskPageState createState() => AddTaskPageState();
}

class AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController taskController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String selectedPriority = 'Medium';

  stt.SpeechToText _speechToText =
      stt.SpeechToText(); // Speech-to-Text instance
  bool _isListening = false; // For tracking listening state
  List<CameraDescription> _cameras = [];
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _cameraController =
          CameraController(_cameras[0], ResolutionPreset.medium);
      await _cameraController.initialize();
    }
  }

  Future<void> _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });
      _speechToText.listen(onResult: (result) {
        setState(() {
          taskController.text = result.recognizedWords; // Update text field
        });
      });
    }
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var taskManagerState = context.watch<TaskManagerState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      labelStyle: TextStyle(
                          color: taskManagerState.isDarkMode
                              ? Colors.white
                              : Colors.black),
                      filled: true,
                      fillColor: taskManagerState.isDarkMode
                          ? Colors.blueGrey[700]
                          : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: TextStyle(
                        color: taskManagerState.isDarkMode
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
                IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
              ],
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text(
                'Deadline: ${DateFormat.yMMMd().format(selectedDate)}',
                style: TextStyle(
                    color: taskManagerState.isDarkMode
                        ? Colors.white
                        : Colors.black),
              ),
              trailing: Icon(Icons.calendar_today,
                  color: taskManagerState.isDarkMode
                      ? Colors.white
                      : Colors.black),
              onTap: _pickDate,
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedPriority,
              items: ['High', 'Medium', 'Low']
                  .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedPriority = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Priority',
                labelStyle: TextStyle(
                    color: taskManagerState.isDarkMode
                        ? Colors.white
                        : Colors.black),
                filled: true,
                fillColor: taskManagerState.isDarkMode
                    ? Colors.blueGrey[700]
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(
                  color: taskManagerState.isDarkMode
                      ? Colors.white
                      : Colors.black),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                taskManagerState.addTask(
                  taskController.text,
                  selectedDate,
                  selectedPriority,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    taskManagerState.isDarkMode ? Colors.blueGrey : Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }
}

class EditTaskPage extends StatefulWidget {
  final Task task;
  final int index;

  EditTaskPage({required this.task, required this.index});

  @override
  EditTaskPageState createState() => EditTaskPageState();
}

class EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _titleController;
  late DateTime _selectedDate;
  late String _selectedPriority;

  stt.SpeechToText _speechToText =
      stt.SpeechToText(); // Speech-to-Text instance
  bool _isListening = false; // For tracking listening state
  List<CameraDescription> _cameras = [];
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _selectedDate = widget.task.deadline;
    _selectedPriority = widget.task.priority;
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _cameraController =
          CameraController(_cameras[0], ResolutionPreset.medium);
      await _cameraController.initialize();
    }
  }

  Future<void> _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });
      _speechToText.listen(onResult: (result) {
        setState(() {
          _titleController.text = result.recognizedWords; // Update text field
        });
      });
    }
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var taskManagerState = context.watch<TaskManagerState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      labelStyle: TextStyle(
                        color: taskManagerState.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                      filled: true,
                      fillColor: taskManagerState.isDarkMode
                          ? Colors.blueGrey[700]
                          : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: TextStyle(
                      color: taskManagerState.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
              ],
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text(
                'Deadline: ${DateFormat.yMMMd().format(_selectedDate)}',
                style: TextStyle(
                  color:
                      taskManagerState.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              trailing: Icon(
                Icons.calendar_today,
                color:
                    taskManagerState.isDarkMode ? Colors.white : Colors.black,
              ),
              onTap: _pickDate,
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              items: ['High', 'Medium', 'Low']
                  .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Priority',
                labelStyle: TextStyle(
                  color:
                      taskManagerState.isDarkMode ? Colors.white : Colors.black,
                ),
                filled: true,
                fillColor: taskManagerState.isDarkMode
                    ? Colors.blueGrey[700]
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(
                color:
                    taskManagerState.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                taskManagerState.editTask(
                  widget.index,
                  _titleController.text,
                  _selectedDate,
                  _selectedPriority,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    taskManagerState.isDarkMode ? Colors.blueGrey : Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
}

class ProfilePictureSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var taskManagerState = context.watch<TaskManagerState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Profile Picture'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          String imagePath = 'assets/images/pic${index + 1}.png';
          return GestureDetector(
            onTap: () {
              taskManagerState.changeProfilePicture(imagePath);
              Navigator.pop(context);
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(imagePath),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AchievementsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var taskManagerState = context.watch<TaskManagerState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: taskManagerState.achievements.map((achievement) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              child: ListTile(
                title: Text(
                  achievement,
                  style: TextStyle(
                    color: taskManagerState.isDarkMode
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class AchievementsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var taskManagerState = context.watch<TaskManagerState>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: taskManagerState.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 20),
          _buildBadgeProgress(
            context,
            taskManagerState,
            'First Badge',
            'assets/images/badStar.png',
            taskManagerState.getProgressToBadge(1),
            taskManagerState.getBadgeMessage(1),
          ),
          SizedBox(height: 20),
          _buildBadgeProgress(
            context,
            taskManagerState,
            'Second Badge',
            'assets/images/badDiamond.png',
            taskManagerState.getProgressToBadge(2),
            taskManagerState.getBadgeMessage(2),
          ),
          SizedBox(height: 20),
          _buildBadgeProgress(
            context,
            taskManagerState,
            'Third Badge',
            'assets/images/badFist.png',
            taskManagerState.getProgressToBadge(3),
            taskManagerState.getBadgeMessage(3),
          ),
          SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            itemCount: taskManagerState.achievements.length,
            itemBuilder: (context, index) {
              String achievement = taskManagerState.achievements[index];
              String badgePath =
                  taskManagerState.achievementBadges[achievement] ?? '';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                child: ListTile(
                  leading: badgePath.isNotEmpty
                      ? Image.asset(
                          badgePath,
                          width: 40,
                          height: 40,
                        )
                      : null,
                  title: Text(
                    achievement,
                    style: TextStyle(
                      color: taskManagerState.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Level: ${taskManagerState.level}',
                    style: TextStyle(
                      color: taskManagerState.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeProgress(
      BuildContext context,
      TaskManagerState taskManagerState,
      String title,
      String badgePath,
      double progress,
      String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              badgePath,
              width: 40,
              height: 40,
            ),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    taskManagerState.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        SizedBox(height: 10),
        Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: taskManagerState.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}
