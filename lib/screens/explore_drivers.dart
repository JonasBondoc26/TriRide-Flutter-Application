import 'package:flutter/material.dart';
import '../models/data_store.dart';
import '../models/driver.dart';
import 'driver_details.dart';
import 'dart:io';

class ExploreDriversScreen extends StatefulWidget {
  const ExploreDriversScreen({super.key});

  @override
  State<ExploreDriversScreen> createState() => _ExploreDriversScreenState();
}

class _ExploreDriversScreenState extends State<ExploreDriversScreen> {
  String _searchQuery = '';
  String _sortBy = 'distance'; // distance, rating, fare

  List<Driver> get _filteredAndSortedDrivers {
    var drivers = DataStore.drivers.where((driver) {
      return driver.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          driver.plateNumber.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    switch (_sortBy) {
      case 'distance':
        drivers.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case 'rating':
        drivers.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'fare':
        drivers.sort((a, b) => a.fare.compareTo(b.fare));
        break;
    }

    return drivers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Drivers'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search drivers or plate number...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Sorting
                Row(
                  children: [
                    const Text('Sort by: '),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'distance',
                            label: Text('Distance'),
                            icon: Icon(Icons.near_me, size: 16),
                          ),
                          ButtonSegment(
                            value: 'rating',
                            label: Text('Rating'),
                            icon: Icon(Icons.star, size: 16),
                          ),
                          ButtonSegment(
                            value: 'fare',
                            label: Text('Fare'),
                            icon: Icon(Icons.payments, size: 16),
                          ),
                        ],
                        selected: {_sortBy},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _sortBy = newSelection.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Driver List
          Expanded(
            child: _filteredAndSortedDrivers.isEmpty
                ? const Center(
                    child: Text('No drivers found'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredAndSortedDrivers.length,
                    itemBuilder: (context, index) {
                      final driver = _filteredAndSortedDrivers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DriverDetailsScreen(driver: driver),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Driver Image
                                _buildDriverAvatar(driver, context),
                                const SizedBox(width: 16),
                                // Driver Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        driver.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        driver.plateNumber,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 16,
                                            color: Colors.amber[700],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            driver.rating.toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          const Icon(
                                            Icons.near_me,
                                            size: 16,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 4),
                                          Text('${driver.distance} km'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Fare and ETA
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₱${driver.fare.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '~${driver.estimatedTime} min',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverAvatar(Driver driver, BuildContext context) {
    // Check if image path exists and is valid
    if (driver.imageUrl.startsWith('assets/')) {
      return CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        backgroundImage: AssetImage(driver.imageUrl),
        onBackgroundImageError: (exception, stackTrace) {
          // If image fails to load, it will show the default background color
        },
      );
    } else {
      // If it's not an asset path, treat it as emoji or icon
      return CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: driver.imageUrl.length <= 2
            ? Text(
                driver.imageUrl,
                style: const TextStyle(fontSize: 32),
              )
            : const Icon(Icons.person, size: 32),
      );
    }
  }
}