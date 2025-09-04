import 'package:flutter/material.dart';
import 'package:sportfolio/components/button.dart';
import 'package:sportfolio/components/text_feild.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //text editing controller
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                Icon(Icons.lock,
                size: 100,
                ),
            
                const SizedBox(height: 35,),
                //welcome
                Text(
                  "Welcome to Sportfolio"
                ),
            
                const SizedBox(height: 30,),
            
            
                //email
                MyTextField(
                  controller: emailTextController, 
                  hintText: 'Email', 
                  obscureText: false
                  ),



                  const SizedBox(height: 15,),
                
            
            
                //passwoed
                MyTextField(
                  controller: passwordTextController, 
                  hintText: 'Password', 
                  obscureText: true
                  ),
            
            
                const SizedBox(height: 10,),
            
                //sign in
                MyButton(onTap: () {},
                text: 'Sign In'),

                const SizedBox(height: 10,),
          

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("New user?"),
                    const SizedBox(width: 4,),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text("Register here",style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[300],
                      ),),
                    ),
                  ],
                ),

            
                //register

              ],
            ),
          ),
        ),
      ),
    );
  }
}