import 'package:flutter/material.dart';
import 'package:smartlocker/models/package.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/receiver_drawer.dart';

class PackageDetailScreen extends StatelessWidget {
  final Package package;

  const PackageDetailScreen({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Package Details'),
      ),
      drawer: const ReceiverDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              package.packageName,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(package.status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              package.status.toString().split('.').last.toUpperCase(),
                              style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Tracking Number', package.trackingNumber),
                      const SizedBox(height: 8),
                      if (package.courier != null) _buildDetailRow('Courier', package.courier!),
                      const SizedBox(height: 8),
                      if (package.orderDate != null)
                        _buildDetailRow('Order Date', _formatDate(package.orderDate!)),
                      const SizedBox(height: 8),
                      if (package.deliveredDate != null)
                        _buildDetailRow('Delivered Date', _formatDate(package.deliveredDate!)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Tracking History Title
              const Text(
                'Tracking History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Tracking History List
              if (package.trackingHistory.isEmpty)
                const Center(
                  child: Text('No tracking history available'),
                )
              else
                ..._buildTrackingTimeline(package.trackingHistory),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTrackingTimeline(List<PackageTrackingEvent> events) {
    // Sort events by timestamp (newest first)
    final sortedEvents = List<PackageTrackingEvent>.from(events)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    List<Widget> timeline = [];
    
    for (int i = 0; i < sortedEvents.length; i++) {
      final event = sortedEvents[i];
      
      timeline.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (i < sortedEvents.length - 1)
                  Container(
                    width: 2,
                    height: 50,
                    color: AppColors.primary,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            
            // Event details
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.description,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.location,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            event.status,
                            style: TextStyle(
                              color: _getStatusEventColor(event.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatDateTime(event.timestamp),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return timeline;
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  Color _getStatusColor(PackageStatus status) {
    switch (status) {
      case PackageStatus.inTransit:
        return Colors.orange;
      case PackageStatus.delivered:
        return Colors.blue;
      case PackageStatus.completed:
        return Colors.green;
    }
  }

  Color _getStatusEventColor(String status) {
    if (status.toLowerCase().contains('received')) {
      return Colors.orange;
    } else if (status.toLowerCase().contains('transit')) {
      return Colors.blue;
    } else if (status.toLowerCase().contains('delivery')) {
      return Colors.purple;
    } else if (status.toLowerCase().contains('delivered')) {
      return Colors.green;
    } else if (status.toLowerCase().contains('completed')) {
      return Colors.green;
    }
    return AppColors.grey;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}