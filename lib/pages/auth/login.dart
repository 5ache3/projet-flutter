import 'package:flutter/material.dart';
import 'package:projet/components/TextField.dart';
import 'package:projet/components/button.dart';
import 'package:projet/pages/auth/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(child: Center(
        child:
        Padding(
        padding: const EdgeInsets.all(16),
     child:
        Column(
          children: [
            const SizedBox(height: 50),
            
            Icon(Icons.house,size: 120,),
            const SizedBox(height: 40,),

            CustomTextField(controller: usernameController, label: 'username or email', icon: Icons.person),
            const SizedBox(height: 10,),
            CustomTextField(controller: passwordController, label: 'password', icon: Icons.password,passwd: true,),
            const SizedBox(height: 20,),
            
            CustomButton(action: ()=>{}, label: 'Login'),
            const SizedBox(height: 10,),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                    child: Text("Don't have an acount? register now",
                      style: TextStyle(color: Colors.blue[900]
                      ),
                    ),
                  onTap: ()=>{
                  Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage()),
                  )
                  },
                )
              ],
            )
          ],
        )),
      )),
    );
  }
}
