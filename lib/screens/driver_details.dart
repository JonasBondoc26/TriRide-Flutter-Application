import 'package:flutter/material.dart';
import '../models/driver.dart';

class DriverDetailsScreen extends StatelessWidget {
  final Driver driver;

  const DriverDetailsScreen({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF183D59),
        title: const Text('Driver Details'),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF183D59),
                    Color(0xFF31A9A2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  _buildDriverAvatar(driver, context),
                  const SizedBox(height: 16),
                  Text(
                    driver.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber[400],
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${driver.rating} Rating',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Info Cards
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    context,
                    'Vehicle Information',
                    [
                      _buildInfoRow(Icons.confirmation_number, 'Plate Number',
                          driver.plateNumber),
                      _buildInfoRow(
                          Icons.pedal_bike, 'Vehicle Type', 'Tricycle'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    'Trip Information',
                    [
                      _buildInfoRow(Icons.near_me, 'Distance',
                          '${driver.distance} km away'),
                      _buildInfoRow(Icons.access_time, 'Estimated Time',
                          '${driver.estimatedTime} minutes'),
                      _buildInfoRow(Icons.payments, 'Estimated Fare',
                          '₱${driver.fare.toStringAsFixed(0)}'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Book Ride Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Book Ride'),
                            content: Text(
                                'Book a ride with ${driver.name}?\n\nEstimated fare: ₱${driver.fare.toStringAsFixed(0)}'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF31A9A2),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Ride booked successfully!'),
                                    ),
                                  );
                                },
                                child: const Text('Confirm'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Book This Ride'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF183D59),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverAvatar(Driver driver, BuildContext context) {
    if (driver.imageUrl.startsWith('assets/')) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white,
        backgroundImage: AssetImage(driver.imageUrl),
        child: null,
      );
    } else {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white,
        child: driver.imageUrl.length <= 2
            ? Text(
                driver.imageUrl,
                style: const TextStyle(fontSize: 64, color: Color(0xFF183D59)),
              )
            : const Icon(Icons.person, size: 64, color: Colors.grey),
      );
    }
  }

  Widget _buildInfoCard(
      BuildContext context, String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF183D59),
                  ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
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
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF31A9A2),
            ),
          ),
        ],
      ),
    );
  }
}