import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sportfolio/components/button.dart';
import 'package:sportfolio/components/text_feild.dart';
class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text editing controller
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //display msg
  void displayMessage (String message) {
    showDialog(context: context, builder: (context) => 
    AlertDialog(
      title: Text(message),
    ),
    );
  }

  //signup
  void signUp () async {

    //show loading
    showDialog(context: context,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
    );

    //make sure password match
    if (passwordTextController.text != confirmPasswordController.text){
      //pop loading
      Navigator.pop(context);
      displayMessage("Password don't match");
      return;
    }
    //try catch
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text, 
        password: passwordTextController.text,
        );
        if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e){
      Navigator.pop(context);
      displayMessage(e.code);
    }

  }


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
                  "Let's create an account"
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

                  const SizedBox(height: 15,),

                  MyTextField(
                  controller: confirmPasswordController, 
                  hintText: 'Confirm Password', 
                  obscureText: true
                  ),
            
            
                const SizedBox(height: 10,),
            
                //sign up
                MyButton(onTap: signUp,
                text: 'Sign Up'),

                const SizedBox(height: 10,),
          

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?"),
                    const SizedBox(width: 4,),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text("Sign In now",style: TextStyle(
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