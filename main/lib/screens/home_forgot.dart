import 'package:flutter/material.dart';
import 'package:main/screens/home.dart';
import 'package:main/screens/home_login.dart';
import 'package:main/screens/home_register.dart';

class ForgotPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white, // Set the background color to white
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Instagram logo or any other logo
            Center(
              child: 
              Container(
              margin: EdgeInsets.only(top: 80), // Top margin
              child: Center(
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontFamily: 'Billabong', // Instagram's logo font
                    fontSize: 30,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            ),
            SizedBox(height: 40),
            // Username TextField
          
           TextField(
              decoration: InputDecoration(
                labelText: 'phone number',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                color: Colors.grey, // Set the text color to grey
                fontSize: 12,
              ),
            ),

            SizedBox(height: 10),
            // Password TextField
          
            // Login Button
            ElevatedButton(
              onPressed: () {
                // Perform login logic here
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
               child: Text(
                'Password Reset',
                style: TextStyle(
                  color: Colors.black, // Set the text color to grey
                ),
              ),
              
              style: ElevatedButton.styleFrom(
                
                backgroundColor: Color(0xff1CA1F1), // Instagram-like blue
                padding: EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              
              
            ),
            SizedBox(height: 20),
            // Forgot Password link
            Center(
              child: GestureDetector(
                onTap: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                  // Handle forgot password
                },
                child: Text(
                  'dont have an Account?',
                  style: TextStyle(
                    color: Color(0xff1CA1F1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
         
              
             
          ],
        ),
      ),
    );
  }
}