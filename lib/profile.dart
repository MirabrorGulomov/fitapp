import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  double totalDistance = 0.0;
  Position? _lastPosition;
  Duration waitTime = const Duration();
  Timer? _timer;
  bool isWaiting = false;

  final double speedThreshold = 30.0;
  final double distanceThreshold = 5.0;

  Future<void> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  void _trackLocation() {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((Position position) {
      if (_lastPosition != null) {
        double distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        if (distance > distanceThreshold) {
          totalDistance += distance / 1000;
        }

        if (position.speed * 3.6 >= speedThreshold && isWaiting) {
          _stopWaiting();
        } else if (position.speed * 3.6 < speedThreshold && !isWaiting) {
          _resetWaitingState();
        }
      }
      _lastPosition = position;
      setState(() {});
    });
  }

  void _startWaiting() {
    isWaiting = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        waitTime = waitTime + Duration(seconds: 1);
      });
    });
  }

  void _stopWaiting() {
    isWaiting = false;
    _timer?.cancel();
  }

  void _resetWaitingState() {
    setState(() {
      isWaiting = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _trackLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Distance Tracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Umumiy masofa: ${totalDistance.toStringAsFixed(2)} km'),
            Text('Kutish vaqti: ${waitTime.inHours}:${(waitTime.inMinutes % 60).toString().padLeft(2, '0')}:${(waitTime.inSeconds % 60).toString().padLeft(2, '0')}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isWaiting ? null : _startWaiting,
                  child: const Text("To'xtatish"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isWaiting ? _stopWaiting : null,
                  child: const Text('Davom etirish'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}