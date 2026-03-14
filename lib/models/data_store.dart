import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'driver.dart';
import 'ride.dart';

class DataStore {
  // Center location: Angeles City, Pampanga
  static const LatLng centerLocation = LatLng(15.1450, 120.5887);
  
  static final List<Driver> drivers = [
    Driver(
      id: '1',
      name: 'Max Verstappen',
      plateNumber: 'ABC-123',
      rating: 4.8,
      imageUrl: 'assets/images/drivers/Max Verstappen.jpg',
      distance: 0.5,
      estimatedTime: 3,
      fare: 20.0,
      location: const LatLng(15.1470, 120.5900),
    ),
    Driver(
      id: '2',
      name: 'Charles Leclerc',
      plateNumber: 'XYZ-456',
      rating: 4.9,
      imageUrl: 'assets/images/drivers/Charles Leclerc.png',
      distance: 0.8,
      estimatedTime: 5,
      fare: 25.0,
      location: const LatLng(15.1430, 120.5870),
    ),
    Driver(
      id: '3',
      name: 'Lewis Hamilton',
      plateNumber: 'DEF-789',
      rating: 4.7,
      imageUrl: 'assets/images/drivers/Lewis Hamilton.jpg',
      distance: 1.2,
      estimatedTime: 7,
      fare: 30.0,
      location: const LatLng(15.1460, 120.5920),
    ),
    Driver(
      id: '4',
      name: 'Oscar Piastri',
      plateNumber: 'GHI-321',
      rating: 5.0,
      imageUrl: 'assets/images/drivers/Oscar Piastri.png',
      distance: 0.3,
      estimatedTime: 2,
      fare: 15.0,
      location: const LatLng(15.1440, 120.5880),
    ),
  ];

  static final List<Ride> rideHistory = [
    Ride(
      id: '1',
      driverName: 'Max Verstappen',
      pickup: 'Barangay San Jose',
      destination: 'Barangay Santa Cruz',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      fare: 25.0,
      status: 'Completed',
      plateNumber: 'ABC-123',
    ),
    Ride(
      id: '2',
      driverName: 'Charles Leclerc',
      pickup: 'Barangay Los Santos',
      destination: 'Barangay San Miguel',
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      fare: 30.0,
      status: 'Completed',
      plateNumber: 'XYZ-456',
    ),
  ];

  static String userName = 'Passenger User';
  static String userPhone = '+63 912 345 6789';
  static String userEmail = 'passenger@triride.com';
  static Uint8List? userProfileImage;
}