import 'package:flutter/material.dart';
import '../services/local_auth_service.dart';

class AuthDebugPage extends StatefulWidget {
  const AuthDebugPage({Key? key}) : super(key: key);

  @override
  State<AuthDebugPage> createState() => _AuthDebugPageState();
}

class _AuthDebugPageState extends State<AuthDebugPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _status = 'Ready';
  List<String> _allUsers = [];
  String? _currentUser;
  
  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }
  
  void _refreshStatus() {
    setState(() {
      _allUsers = LocalAuthService.getAllUsers();
      _currentUser = LocalAuthService.getCurrentUsername();
      _status = 'Users: ${_allUsers.length}, Current: $_currentUser';
    });
  }
  
  Future<void> _registerUser() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _status = 'Please fill all fields');
      return;
    }
    
    final success = await LocalAuthService.registerUser(username, email, password);
    setState(() {
      _status = success ? 'User $username registered!' : 'Registration failed';
    });
    
    if (success) {
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _refreshStatus();
    }
  }
  
  Future<void> _loginUser() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    
    if (username.isEmpty || password.isEmpty) {
      setState(() => _status = 'Please enter username and password');
      return;
    }
    
    final result = await LocalAuthService.loginUser(username, password);
    setState(() {
      _status = result != null ? 'Login successful!' : 'Login failed';
    });
    
    if (result != null) {
      _refreshStatus();
    }
  }
  
  Future<void> _logout() async {
    await LocalAuthService.logout();
    setState(() => _status = 'Logged out');
    _refreshStatus();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Debug'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Status: $_status',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            
            // Form fields
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _registerUser,
                    child: const Text('Register'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loginUser,
                    child: const Text('Login'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
            const SizedBox(height: 16),
            
            // Users list
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registered Users (${_allUsers.length}):',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_allUsers.isEmpty)
                    const Text('No users registered')
                  else
                    ...(_allUsers.map((user) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '• $user ${user == _currentUser ? "(logged in)" : ""}',
                        style: TextStyle(
                          color: user == _currentUser ? Colors.green : null,
                          fontWeight: user == _currentUser ? FontWeight.bold : null,
                        ),
                      ),
                    ))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Refresh button
            ElevatedButton(
              onPressed: _refreshStatus,
              child: const Text('Refresh Status'),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}