import 'package:flutter/material.dart';
import 'package:projet/components/TextField.dart';
import 'package:projet/components/button.dart';
import 'package:projet/constants.dart';
import 'package:projet/pages/auth/login.dart';
import 'package:projet/pages/home_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final password2Controller = TextEditingController();
  bool hidden = true;
  final storage = FlutterSecureStorage();

  void _submit() {
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final password2 = password2Controller.text;

    if (username.isEmpty || password.isEmpty || password2.isEmpty) {
      Get.snackbar(
        "Champs manquants",
        "Veuillez remplir tous les champs.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (password != password2) {
      Get.snackbar(
        "Mot de passe",
        "Les mots de passe ne correspondent pas.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    register(username, password);
  }

  Future<bool> register(String username, String password) async {
    final url = Uri.parse('$apiUrl/register');

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
          "Inscription réussie",
          "Bienvenue !",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomePage()));
        });

        return true;
      } else {
        Get.snackbar(
          "Erreur",
          "Username already exist",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Une erreur est survenue. Vérifiez votre connexion.",
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
                    "SIGN UP",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 3),
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
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: password2Controller,
                    label: 'confirm password',
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
                  CustomButton(action: _submit, label: 'Sign Up'),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        child: Text(
                          "Have an account? login now",
                          style: TextStyle(color: Colors.blue[900]),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
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
