import '../models/user.dart';

class AuthService {
  // Simulated user database (in-memory)
  static final List<User> _users = [];
  static User? _currentUser;

  // Get current logged-in user
  static User? get currentUser => _currentUser;

  // Check if user is logged in
  static bool get isLoggedIn => _currentUser != null;

  // Register new user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check if email already exists
    final existingUser = _users.firstWhere(
      (user) => user.email.toLowerCase() == email.toLowerCase(),
      orElse: () => User(id: '', email: '', password: '', name: '', phone: ''),
    );

    if (existingUser.id.isNotEmpty) {
      return {
        'success': false,
        'message': 'Email already registered',
      };
    }

    // Create new user
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      password: password,
      name: name,
      phone: phone,
    );

    _users.add(newUser);
    _currentUser = newUser;

    return {
      'success': true,
      'message': 'Account created successfully',
      'user': newUser,
    };
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Find user by email
    final user = _users.firstWhere(
      (user) => user.email.toLowerCase() == email.toLowerCase(),
      orElse: () => User(id: '', email: '', password: '', name: '', phone: ''),
    );

    // Check if user exists
    if (user.id.isEmpty) {
      return {
        'success': false,
        'message': 'Email not registered',
      };
    }

    // Check password
    if (user.password != password) {
      return {
        'success': false,
        'message': 'Incorrect password',
      };
    }

    _currentUser = user;

    return {
      'success': true,
      'message': 'Login successful',
      'user': user,
    };
  }

  // Logout user
  static Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  // Update user profile
  static void updateUserProfile({
    String? name,
    String? phone,
    String? email,
  }) {
    if (_currentUser == null) return;

    final updatedUser = User(
      id: _currentUser!.id,
      email: email ?? _currentUser!.email,
      password: _currentUser!.password,
      name: name ?? _currentUser!.name,
      phone: phone ?? _currentUser!.phone,
    );

    // Update in list
    final index = _users.indexWhere((u) => u.id == _currentUser!.id);
    if (index != -1) {
      _users[index] = updatedUser;
    }

    _currentUser = updatedUser;
  }

  // Get all registered users (for testing)
  static List<User> getAllUsers() => _users;
}