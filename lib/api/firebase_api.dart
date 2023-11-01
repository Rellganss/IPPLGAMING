import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class FirebaseApi {
  final _FirebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _FirebaseMessaging.requestPermission();
    final fCMToken = await _FirebaseMessaging.getToken();
    print('Token: $fCMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future<SensorData> fetchDataFromFirebase() async {
    final response = await http.get(Uri.parse(
        'https://console.firebase.google.com/project/mark-i-inferno/database/mark-i-inferno-default-rtdb/data/.json'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return SensorData.fromJson(data);
    } else {
      throw Exception('Gagal mengambil data dari Firebase');
    }
  }
}

class SensorData {
  final double kelembapan;
  final int suhu;
  final bool asap;

  SensorData({
    required this.kelembapan,
    required this.suhu,
    required this.asap,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      kelembapan: json['kelembaban'] ??
          0.0, // Gantilah 0.0 dengan nilai default yang sesuai
      suhu: json['suhu'] ?? 0, // Gantilah 0 dengan nilai default yang sesuai
      asap: json['asap'] ??
          false, // Gantilah false dengan nilai default yang sesuai
    );
  }
}
