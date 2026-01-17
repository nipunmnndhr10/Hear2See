import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slf_teachable_model/services/database_helper.dart';

class AlertHistoryScreen extends StatefulWidget {
  const AlertHistoryScreen({super.key});

  @override
  State<AlertHistoryScreen> createState() => _AlertHistoryScreenState();
}

class _AlertHistoryScreenState extends State<AlertHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _refreshAlerts();
  }

  void _refreshAlerts() {
    setState(() {
      _alertsFuture = DatabaseHelper().getAlerts();
    });
  }

  String _formatDate(String isoString) {
    final DateTime dateTime = DateTime.parse(isoString);
    return DateFormat('MMM d, y hh:mm a').format(dateTime);
  }

  IconData _getIconForType(String type) {
    if (type == 'emergency') {
      return Icons.local_hospital; // Or local_hospital / fire_truck if specific
    } else if (type == 'horn') {
      return Icons.directions_car;
    }
    return Icons.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading history',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No alerts recorded yet.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          final alerts = snapshot.data!;

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return ListTile(
                leading: Icon(
                  _getIconForType(alert['type']),
                  color: Colors.redAccent,
                  size: 32,
                ),
                title: Text(
                  alert['label'].toString().toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  alert['type'].toString().toUpperCase(),
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Text(
                  _formatDate(alert['timestamp']),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
