import 'package:flutter/material.dart';
import 'package:main/screens/home.dart';
import 'package:main/screens/home_forgot.dart';
import 'package:main/screens/home_register.dart';
class LoginPage extends StatelessWidget {
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
                  'LinkIT',
                  style: TextStyle(
                    fontFamily: 'Billabong', // Instagram's logo font
                    fontSize: 50,
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
            TextField(
              decoration: InputDecoration(
                labelText: 'password',
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
              obscureText: true,
            ),
            SizedBox(height: 20),
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
                'Log In',
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
                  // Handle forgot password

                   Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                );
                },
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: Color(0xff1CA1F1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Spacer(),
            // Sign Up link at the bottom
            Divider(color: Colors.grey),
            Center(
              child: GestureDetector(
              onTap: () {
                  // Navigate to RegisterPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: Colors.black),
                   
                    children: [
                      TextSpan(
                        text: 'Sign Up.',
                        style: TextStyle(
                          color: Color(0xff1CA1F1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

