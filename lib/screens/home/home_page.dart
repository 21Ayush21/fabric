import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'dart:math';
import '../../models/user.dart';
import '../../models/activity.dart';
import '../../services/location_service.dart';
import '../widgets/activity_card.dart';
import '../activity/create_activity_page.dart';
import '../auth/auth_page.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocationService _locationService = LocationService();
  final _auth = firebase_auth.FirebaseAuth.instance;
  Position? _currentPosition;
  String? _currentCity;
  bool _isLoading = true;
  bool _locationPermissionDenied = false;
  List<Activity> _activities = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
      _locationPermissionDenied = false;
    });

    // Try to get last known position first (faster)
    final lastKnown = await _locationService.getLastKnownPosition();
    if (lastKnown != null) {
      setState(() {
        _currentPosition = lastKnown;
      });
      _getCurrentCity();
      _loadNearbyActivities();
    }

    // Then get accurate current position
    final position = await _locationService.getCurrentLocation();
    
    if (position != null) {
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
      _getCurrentCity();
      _loadNearbyActivities();
    } else {
      setState(() {
        _isLoading = false;
        _locationPermissionDenied = true;
      });
    }
  }

  Future<void> _getCurrentCity() async {
    if (_currentPosition == null) return;
    
    final city = await _locationService.getCityFromCoordinates(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );
    
    setState(() {
      _currentCity = city;
    });
  }

  Future<void> _loadNearbyActivities() async {
    if (_currentPosition == null) return;

    setState(() {
      _isLoading = true;
    });

    final random = Random();
    final categories = ['Sports', 'Fitness', 'Social', 'Arts', 'Learning'];
    final activities = [
      'Basketball Game',
      'Yoga Session',
      'Coffee Meetup',
      'Painting Workshop',
      'Book Club',
      'Running Group',
      'Tennis Match',
      'Meditation Class',
      'Board Games Night',
      'Photography Walk'
    ];

    // Generate activities within 5km radius of current location
    List<Activity> tempActivities = [];
    
    for (int index = 0; index < 10; index++) {
      // Generate random coordinates within ~5km radius
      final randomDistance = random.nextDouble() * 5; // 0-5 km
      final randomBearing = random.nextDouble() * 360; // 0-360 degrees
      
      // Calculate offset in lat/lng (approximate)
      final latOffset = (randomDistance / 111.32) * cos(randomBearing * pi / 180);
      final lngOffset = (randomDistance / (111.32 * cos(_currentPosition!.latitude * pi / 180))) * 
                        sin(randomBearing * pi / 180);
      
      final activityLat = _currentPosition!.latitude + latOffset;
      final activityLng = _currentPosition!.longitude + lngOffset;

      // Calculate actual distance using Geolocator
      final actualDistance = _locationService.calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        activityLat,
        activityLng,
      );

      // Get address for this location
      final locationAddress = await _locationService.getShortAddress(activityLat, activityLng);

      tempActivities.add(Activity(
        id: 'activity_$index',
        name: activities[index],
        category: categories[random.nextInt(categories.length)],
        location: locationAddress,
        startTime: DateTime.now().add(Duration(hours: random.nextInt(8) + 1)),
        maxParticipants: random.nextInt(8) + 3,
        currentParticipants: random.nextInt(5),
        distance: actualDistance,
        description: 'Join us for a fun ${activities[index].toLowerCase()}!',
      ));
    }

    // Sort by distance (nearest first)
    tempActivities.sort((a, b) => a.distance.compareTo(b.distance));

    setState(() {
      _activities = tempActivities;
      _isLoading = false;
    });
  }

  Future<void> _handleSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      await _auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthPage()),
          (route) => false,
        );
      }
    }
  }

  void _showProfileMenu() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                widget.user.name.isNotEmpty 
                    ? widget.user.name[0].toUpperCase() 
                    : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.user.name,
                    style: const TextStyle(fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.user.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile editing coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon!')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _handleSignOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nearby Activities', style: TextStyle(fontSize: 18)),
            if (_currentCity != null)
              Text(
                _currentCity!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          // Show current location info
          if (_currentPosition != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              tooltip: 'Current Location',
              onPressed: () async {
                final address = await _locationService.getAddressFromCoordinates(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                );
                
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Your Location'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Address:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(address),
                          const SizedBox(height: 12),
                          const Text(
                            'Coordinates:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}'),
                          const SizedBox(height: 8),
                          Text('Accuracy: ±${_currentPosition!.accuracy.toStringAsFixed(1)}m'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          // User Profile Avatar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: InkWell(
              onTap: _showProfileMenu,
              borderRadius: BorderRadius.circular(20),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  widget.user.name.isNotEmpty 
                      ? widget.user.name[0].toUpperCase() 
                      : 'U',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _currentPosition != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateActivityPage(
                      user: widget.user,
                      currentPosition: _currentPosition,
                    ),
                  ),
                );
              },
              label: const Text('Create Activity'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Getting your location...'),
          ],
        ),
      );
    }

    if (_locationPermissionDenied) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_off,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Location Permission Required',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'To find activities near you, please enable location access.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  await _locationService.openAppSettings();
                  // Retry after returning from settings
                  _initializeLocation();
                },
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _initializeLocation,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentPosition == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Unable to get location'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeLocation,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _initializeLocation();
      },
      child: _activities.isEmpty
          ? const Center(
              child: Text('No activities found nearby'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return ActivityCard(
                  activity: activity,
                  user: widget.user,
                );
              },
            ),
    );
  }
}