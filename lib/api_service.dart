import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ApiService {
  static final ApiService _singleton = ApiService._internal();

  factory ApiService() {
    return _singleton;
  }

  ApiService._internal();

  bool isConnected = false;
  var ipAddr = '10.0.2.2:8000'; //localhost of emulator

  // This next 3 functions are used to send the flight plan to RESTAPI which then in turn send it to the external broker, and the autopilot service
  // Its not the optimal way of doing it since it should be sent to the external broker through MQTT directly but i couldnt get it to work
  // This should be changed in the future you can try to follow this example https://github.com/shamblett/mqtt_client/blob/master/example/mqtt_server_client_websocket.dart
  Future<void> disconnectBroker() async {
    var url = Uri.parse('http://$ipAddr/disconnect');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      debugPrint('Successfully disconnected from the broker.');
      isConnected = false;
    } else {
      debugPrint(
          'Failed to disconnect from the broker: ${response.statusCode}: ${response.body}}');
    }
  }

  Future<void> connectBroker() async {
    var url = Uri.parse('http://$ipAddr/connect');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      debugPrint('Successfully connected to the broker.');
      isConnected = true;
    } else {
      debugPrint(
          'Failed to connect to the broker: ${response.statusCode}: ${response.body}');
    }
  }

  Future<bool> callApiFlightPlan(List waypoints) async {
    var url = Uri.parse('http://$ipAddr/executeFlightPlan');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(waypoints),
    );

    if (response.statusCode == 200) {
      debugPrint('Successfully posted waypoints.');
      return true;
    } else {
      debugPrint(
          'Failed to post waypoints: ${response.statusCode}: ${response.body}');
      return false;
    }
  }

  Future<List<dynamic>> fetchFlightPlans() async {
    final response =
        await http.get(Uri.parse('http://$ipAddr/get_all_flightPlans'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['Waypoints'];
    } else {
      throw Exception('Failed to load flight plans');
    }
  }

  Future<List<dynamic>> fetchPastFlights() async {
    final response =
        await http.get(Uri.parse('http://$ipAddr/get_all_flights'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to load flight plans');
    }
  }

  Future<void> checkConnection() async {
    var url = Uri.parse('http://$ipAddr/connection_status');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      isConnected = data['is_connected'];
    }
  }

  String getImageUrl(String imagePath) {
    return 'http://$ipAddr/media/pictures/$imagePath';
  }

  String getVideoUrl(String videoPath) {
    return 'http://$ipAddr/media/videos/$videoPath';
  }

  String getThumbnailUrl(String videoPath) {
    return 'http://$ipAddr/thumbnail/$videoPath';
  }

  // Add other API calls here
}
