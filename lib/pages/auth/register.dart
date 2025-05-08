import 'package:flutter/material.dart';
import 'package:projet/components/TextField.dart';
import 'package:projet/components/button.dart';
import 'package:projet/pages/auth/login.dart';
import 'package:projet/pages/home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final password2Controller = TextEditingController();
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

                GestureDetector(
                  onTap: ()=>{
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    )
                  },
                    child: Icon(Icons.house,size: 120,)),
                const SizedBox(height: 40,),

                CustomTextField(controller: usernameController, label: 'username or email', icon: Icons.person),
                const SizedBox(height: 10,),
                CustomTextField(controller: passwordController, label: 'password', icon: Icons.password,passwd: true,),
                const SizedBox(height: 20,),
                CustomTextField(controller: passwordController, label: 'password', icon: Icons.password,passwd: true,),
                const SizedBox(height: 20,),

                CustomButton(action: ()=>{}, label: 'Sign Up'),
                const SizedBox(height: 10,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      child: Text("Have an acount? login now",
                        style: TextStyle(color: Colors.blue[900]
                        ),
                      ),
                      onTap: ()=>{
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
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
