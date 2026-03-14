class Ride {
  final String id;
  final String driverName;
  final String pickup;
  final String destination;
  final DateTime dateTime;
  final double fare;
  final String status;
  final String plateNumber;

  Ride({
    required this.id,
    required this.driverName,
    required this.pickup,
    required this.destination,
    required this.dateTime,
    required this.fare,
    required this.status,
    required this.plateNumber,
  });
}