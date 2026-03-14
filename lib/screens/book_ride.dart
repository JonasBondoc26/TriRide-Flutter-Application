import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import '../models/data_store.dart';
import '../models/ride.dart';

class BookRideScreen extends StatefulWidget {
  const BookRideScreen({super.key});

  @override
  State<BookRideScreen> createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  String _selectedPayment = 'Cash';
  
  GoogleMapController? _mapController;
  LatLng? _pickupLocation;
  LatLng? _destinationLocation;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isSelectingPickup = true;

  @override
  void initState() {
    super.initState();
    _addDriverMarkers();
  }

  void _addDriverMarkers() {
    for (var driver in DataStore.drivers) {
      _markers.add(
        Marker(
          markerId: MarkerId(driver.id),
          position: driver.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: driver.name,
            snippet: '${driver.plateNumber} - ₱${driver.fare.toStringAsFixed(0)}',
          ),
        ),
      );
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      if (_isSelectingPickup) {
        _pickupLocation = position;
        _pickupController.text = 'Selected on map';
        
        _markers.removeWhere((m) => m.markerId.value == 'pickup');
        _markers.add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: position,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: '📍 Pickup Location',
              snippet: 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}',
            ),
          ),
        );
        
        _isSelectingPickup = false;
      } else {
        _destinationLocation = position;
        _destinationController.text = 'Selected on map';
        
        _markers.removeWhere((m) => m.markerId.value == 'destination');
        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: position,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: '🎯 Destination',
              snippet: 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}',
            ),
          ),
        );
        
        if (_pickupLocation != null) {
          _drawRoute();
        }
      }
    });
  }

  void _drawRoute() {
    if (_pickupLocation != null && _destinationLocation != null) {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [_pickupLocation!, _destinationLocation!],
          color: Colors.blue,
          width: 5,
        ),
      );
      
      setState(() {});
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371;
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _bookRide() {
    if (_formKey.currentState!.validate() && 
        _pickupLocation != null && 
        _destinationLocation != null) {
      final randomDriver =
          DataStore.drivers[Random().nextInt(DataStore.drivers.length)];

      final newRide = Ride(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        driverName: randomDriver.name,
        pickup: _pickupController.text,
        destination: _destinationController.text,
        dateTime: DateTime.now(),
        fare: randomDriver.fare,
        status: 'Completed',
        plateNumber: randomDriver.plateNumber,
      );

      setState(() {
        DataStore.rideHistory.insert(0, newRide);
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
          title: const Text('Ride Booked!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Driver: ${randomDriver.name}'),
              Text('Plate: ${randomDriver.plateNumber}'),
              Text('ETA: ${randomDriver.estimatedTime} minutes'),
              Text('Fare: ₱${randomDriver.fare.toStringAsFixed(0)}'),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both pickup and destination on the map'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Ride'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: DataStore.centerLocation,
                    zoom: 14,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onTap: _onMapTap,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isSelectingPickup ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _isSelectingPickup ? Icons.my_location : Icons.location_on,
                                  color: _isSelectingPickup ? Colors.green : Colors.red,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isSelectingPickup ? '📍 Select Pickup' : '🎯 Select Destination',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Tap anywhere on the map',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (_pickupLocation != null && _destinationLocation != null) ...[
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.straighten, size: 16, color: Colors.blue),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Distance: ${_calculateDistance(
                                        _pickupLocation!.latitude,
                                        _pickupLocation!.longitude,
                                        _destinationLocation!.latitude,
                                        _destinationLocation!.longitude,
                                      ).toStringAsFixed(2)} km',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.local_taxi, size: 16, color: Colors.orange),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${DataStore.drivers.length} drivers nearby',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Map Legend',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on, color: Colors.blue[700], size: 16),
                              const SizedBox(width: 4),
                              const Text('Drivers', style: TextStyle(fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on, color: Colors.green[700], size: 16),
                              const SizedBox(width: 4),
                              const Text('Pickup', style: TextStyle(fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on, color: Colors.red[700], size: 16),
                              const SizedBox(width: 4),
                              const Text('Destination', style: TextStyle(fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isSelectingPickup = true;
                              });
                            },
                            icon: Icon(
                              Icons.my_location,
                              color: _isSelectingPickup ? Colors.white : Colors.green,
                            ),
                            label: Text(
                              _pickupLocation == null ? 'Set Pickup' : 'Change Pickup',
                              style: TextStyle(
                                color: _isSelectingPickup ? Colors.white : Colors.green,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _isSelectingPickup 
                                  ? Colors.green
                                  : Colors.transparent,
                              side: BorderSide(
                                color: Colors.green,
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isSelectingPickup = false;
                              });
                            },
                            icon: Icon(
                              Icons.location_on,
                              color: !_isSelectingPickup ? Colors.white : Colors.red,
                            ),
                            label: Text(
                              _destinationLocation == null ? 'Set Destination' : 'Change Destination',
                              style: TextStyle(
                                color: !_isSelectingPickup ? Colors.white : Colors.red,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: !_isSelectingPickup 
                                  ? Colors.red
                                  : Colors.transparent,
                              side: BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pickupController,
                      decoration: InputDecoration(
                        labelText: 'Pickup Location',
                        prefixIcon: const Icon(Icons.my_location, color: Colors.green),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select pickup location on map';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _destinationController,
                      decoration: InputDecoration(
                        labelText: 'Destination',
                        prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select destination on map';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPayment,
                      decoration: InputDecoration(
                        labelText: 'Payment Method',
                        prefixIcon: const Icon(Icons.payment),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: ['Cash', 'GCash', 'PayMaya']
                          .map((method) => DropdownMenuItem(
                                value: method,
                                child: Text(method),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPayment = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _bookRide,
                        icon: const Icon(Icons.search),
                        label: const Text('Find Driver'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
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
}