import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:projet/components/TextField.dart';
import 'package:projet/components/button.dart';
import 'package:projet/constants.dart';
import 'package:projet/pages/auth/register.dart';
import 'package:projet/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidden = true;
  final storage = FlutterSecureStorage();

  void _submit() {
    login(usernameController.text, passwordController.text);
  }

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$apiUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'token', value: data['access_token']);

        Get.snackbar(
          "Connexion réussie",
          "Bienvenue!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        });

        return true;
      } else {
        Get.snackbar(
          "Erreur de connexion",
          "Identifiants incorrects. Veuillez réessayer.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Impossible de se connecter. Vérifiez votre connexion.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const Icon(Icons.house, size: 120),
                  const SizedBox(height: 20),
                  const Text(
                    "LOGGING IN",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    controller: usernameController,
                    label: 'username or email',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: passwordController,
                    label: 'password',
                    icon: Icons.password,
                    passwd: hidden,
                    icon2: hidden ? Icons.visibility_off : Icons.visibility,
                    onClicked: () {
                      setState(() {
                        hidden = !hidden;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomButton(action: _submit, label: 'Login'),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        child: Text(
                          "Don't have an account? register now",
                          style: TextStyle(color: Colors.blue[900]),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupPage()),
                          );
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
