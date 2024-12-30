import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'main.dart';

class WelcomePage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Function to hash passwords
  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  @override
  Widget build(BuildContext context) {
    var taskManagerState = Provider.of<TaskManagerState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Task Manager'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Welcome Message
            Text(
              'Welcome! Please log in or register.',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:
                    taskManagerState.isDarkMode ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Username Input
            _buildTextField(
              controller: usernameController,
              labelText: 'Username',
              taskManagerState: taskManagerState,
            ),
            SizedBox(height: 20),

            // Password Input
            _buildTextField(
              controller: passwordController,
              labelText: 'Password',
              taskManagerState: taskManagerState,
              obscureText: true,
            ),
            SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: () async {
                await _login(context, taskManagerState);
              },
              style: _buttonStyle(taskManagerState),
              child: Text('Login'),
            ),
            SizedBox(height: 20),

            // Registration Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
              style: _buttonStyle(taskManagerState),
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login(
      BuildContext context, TaskManagerState taskManagerState) async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter all fields')),
      );
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(username)
          .get();

      if (userDoc.exists &&
          userDoc.data()?['password'] == hashPassword(password)) {
        // Successful login
        taskManagerState.changeUsername(username);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TaskManagerHomePage(username: username),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid username or password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging in. Please try again.')),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required TaskManagerState taskManagerState,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: taskManagerState.isDarkMode ? Colors.white : Colors.black,
        ),
        filled: true,
        fillColor:
            taskManagerState.isDarkMode ? Colors.blueGrey[700] : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      style: TextStyle(
        color: taskManagerState.isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }
  ButtonStyle _buttonStyle(TaskManagerState taskManagerState) {
    return ElevatedButton.styleFrom(
      backgroundColor:
          taskManagerState.isDarkMode ? Colors.blueGrey : Colors.blue,
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      textStyle: TextStyle(fontSize: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
