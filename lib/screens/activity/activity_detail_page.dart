import 'package:flutter/material.dart';
import '../../models/activity.dart';
import '../../models/user.dart';

class ActivityDetailPage extends StatefulWidget {
  final Activity activity;
  final User user;

  const ActivityDetailPage({
    Key? key,
    required this.activity,
    required this.user,
  }) : super(key: key);

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  DateTime? selectedTime;
  bool hasJoined = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              color: Colors.blue[100],
              child: Icon(
                Icons.sports_basketball,
                size: 80,
                color: Colors.blue[700],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.activity.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.category,
                    'Category',
                    widget.activity.category,
                  ),
                  _buildInfoRow(
                    Icons.location_on,
                    'Location',
                    widget.activity.location,
                  ),
                  _buildInfoRow(
                    Icons.access_time,
                    'Time',
                    '${widget.activity.startTime.hour}:${widget.activity.startTime.minute.toString().padLeft(2, '0')}',
                  ),
                  _buildInfoRow(
                    Icons.people,
                    'Participants',
                    '${widget.activity.currentParticipants}/${widget.activity.maxParticipants}',
                  ),
                  _buildInfoRow(
                    Icons.map,
                    'Distance',
                    '${widget.activity.distance.toStringAsFixed(1)} km away',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.activity.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Select Your Time',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: List.generate(4, (index) {
                      final time = widget.activity.startTime
                          .add(Duration(hours: index));
                      return ChoiceChip(
                        label: Text(
                          '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                        ),
                        selected: selectedTime == time,
                        onSelected: (selected) {
                          setState(() {
                            selectedTime = selected ? time : null;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: selectedTime == null || hasJoined
                ? null
                : () {
                    setState(() {
                      hasJoined = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Successfully joined ${widget.activity.name}!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              hasJoined ? 'Joined!' : 'Join Group',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}