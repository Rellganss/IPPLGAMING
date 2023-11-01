import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    MaterialColor myPrimaryColor = const MaterialColor(0xFF00FDA4, {
      50: Color(0xFFE0FFF1),
      100: Color(0xFFB3FFDE),
      200: Color(0xFF80FFC8),
      300: Color(0xFF4DFFB1),
      400: Color(0xFF26FFA0),
      500: Color(0xFF00FDA4),
      600: Color(0xFF00DB94),
      700: Color(0xFF00B982),
      800: Color(0xFF009770),
      900: Color(0xFF006B5E),
    });

    return MaterialApp(
      title: 'Sensor Value App',
      theme: ThemeData(
        primarySwatch: myPrimaryColor,
        brightness:
            themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: const MySensorPage(),
    );
  }
}

class MySensorPage extends StatefulWidget {
  const MySensorPage({Key? key}) : super(key: key);

  @override
  _MySensorPageState createState() => _MySensorPageState();
}

class _MySensorPageState extends State<MySensorPage> {
  late double asapValue;
  late double suhuValue;
  late double kelembapanValue;
  late double apiValue;

  late DatabaseReference _asapRef;
  late DatabaseReference _suhuRef;
  late DatabaseReference _kelembapanRef;
  late DatabaseReference _apiRef;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> showNotification(String sensorName, double sensorValue) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'Sensor Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: 'mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Nilai Sensor Dibawah Ketentuan',
      '$sensorName: $sensorValue',
      platformChannelSpecifics,
    );
  }

  Future<void> showNotification2(String sensorName, double sensorValue) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'Sensor Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: 'mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Nilai Sensor melebihi Ketentuan',
      '$sensorName: $sensorValue',
      platformChannelSpecifics,
    );
  }

  @override
  void initState() {
    super.initState();
    asapValue = 0.0; // Initialize to some default value
    suhuValue = 0.0; // Initialize to some default value
    kelembapanValue = 0.0; // Initialize to some default value

    _asapRef = FirebaseDatabase.instance.reference().child('m2q/asap');
    _suhuRef = FirebaseDatabase.instance.reference().child('dht/suhu');
    _kelembapanRef =
        FirebaseDatabase.instance.reference().child('dht/kelembapan');
    _apiRef = FirebaseDatabase.instance.reference().child('flame/api');

    _suhuRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          suhuValue = double.parse(data.toString());
        });
      }
    });

    _asapRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          asapValue = double.parse(data.toString());
        });
      }
    });

    _kelembapanRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          kelembapanValue = double.parse(data.toString());
        });
      }
    });

    _apiRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          apiValue = double.parse(data.toString());
        });
      }
    });
  }

  @override
  void dispose() {
    _asapRef.onValue.drain();
    _suhuRef.onValue.drain();
    _kelembapanRef.onValue.drain();
    _apiRef.onValue.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff142870),
          title: const Text(
            'Inferno Sense',
            style: TextStyle(color: Colors.white, fontFamily: 'RobotoMono'),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 10.0),
                buildSensorCard(
                    'SUHU', suhuValue, '°C', themeProvider.isDarkMode),
                buildSensorCard(
                    'Asap', asapValue, '', themeProvider.isDarkMode),
                buildSensorCard('Kelembapan', kelembapanValue, 'pH',
                    themeProvider.isDarkMode),
              ],
            ),
          ),
        ));
  }
}

Widget buildSensorCard(
    String title, double value, String unit, bool isDarkMode) {
  Color cardBackgroundColor =
      isDarkMode ? Colors.black : const Color(0xff54DCC7);
  Color borderColor = isDarkMode ? Colors.white : const Color(0xff142870);
  Color textColor = isDarkMode ? Colors.white : const Color(0xff142870);

  return Container(
    width: 300.0,
    margin: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: cardBackgroundColor,
      borderRadius: BorderRadius.circular(15.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 20,
          offset: const Offset(0, 3),
        ),
      ],
      border: Border.all(
        color: borderColor,
        width: 2,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              fontFamily: 'RobotoMono',
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              fontFamily: 'RobotoMono',
              color: textColor,
            ),
          ),
        ],
      ),
    ),
  );
}
