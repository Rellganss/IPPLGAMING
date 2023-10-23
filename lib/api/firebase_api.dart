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
    final response = await http.get(
        'https://mark-i-inferno-default-rtdb.firebaseio.com/data.json?auth=AIzaSyCqkcY3yQUz77BH7oAilr1hskvZsld6rDw'
            as Uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return SensorData.fromJson(data);
    } else {
      throw Exception('Gagal mengambil data dari Firebase');
    }
  }
}

class SensorData {
  final String status;
  final String asap;
  final String suhu;
  final String kelembapan;

  SensorData({
    required this.status,
    required this.asap,
    required this.suhu,
    required this.kelembapan,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      status: json['status'],
      asap: json['asap'],
      suhu: json['suhu'],
      kelembapan: json['kelembapan'],
    );
  }
}
