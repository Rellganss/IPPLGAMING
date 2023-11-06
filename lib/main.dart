import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Sensor Value App',
      theme: ThemeData(
        primarySwatch: Colors.blue
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
  late double suhuValue;
  late double apiValue;
  late double kelembapanValue;

  late DatabaseReference _suhuRef;
  late DatabaseReference _apiRef;
  late DatabaseReference _kelembapanRef;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final double apiThreshold = 1;
  final double suhuThreshold = 35;

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
      'kondisi aman, tidak ada Api pada ruangan',
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
      'Terdapat Api pada ruangan',
      '$sensorName: $sensorValue',
      platformChannelSpecifics,
    );
  }

  Future<void> showNotification3(String sensorName, double sensorValue) async {
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
      'Nilai Suhu melebihi Ketentuan',
      '$sensorName: $sensorValue',
      platformChannelSpecifics,
    );
  }

  @override
  void initState() {
    super.initState();

    apiValue = 0.0;
    suhuValue = 0.0;
    kelembapanValue = 0.0;

    _suhuRef = FirebaseDatabase.instance.reference().child('dht/suhu');
    _kelembapanRef =
        FirebaseDatabase.instance.reference().child('dht/kelembapan');
    _apiRef = FirebaseDatabase.instance.reference().child('flame/api');

    _suhuRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          suhuValue = double.parse(data.toString());
          if (suhuValue >= suhuThreshold) {
            showNotification3('kondisi suhu menunjukkan', suhuValue);
          }
        });
      }
    });

    _apiRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          apiValue = double.parse(data.toString());
          if (apiValue >= apiThreshold) {
            showNotification('kondisi api menunjukkan', apiValue);
          }
          if (apiValue < apiThreshold) {
            showNotification2('Terdapat api pada ruangan', apiValue);
          }
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
  }

  @override
  void dispose() {
    _suhuRef.onValue.drain();
    _kelembapanRef.onValue.drain();
    _apiRef.onValue.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 200, 16, 16),
        title: const Text(
          'Inferno Sense',
          style: TextStyle(color: Colors.white, fontFamily: 'RobotoMono'),
        ),
      ),
      body: Center(
        // Wrap the card with a Center widget
        child: Container(
          width: 300.0,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color:Color(0xFFF0F8FF),
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
              color: const Color(0xff142870),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  children: [
                    const Text(
                      'SUHU',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'RobotoMono',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${suhuValue.toStringAsFixed(1)} °C',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'RobotoMono',
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    const Text(
                      'Kelembapan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'RobotoMono',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${kelembapanValue.toStringAsFixed(1)} ',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'RobotoMono',
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    const Text(
                      'API',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'RobotoMono',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      apiValue.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'RobotoMono',
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
