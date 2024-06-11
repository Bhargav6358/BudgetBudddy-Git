

import 'package:expense_track/screens/Authentication/mainScreen.dart';
import 'package:expense_track/screens/Home/views/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Expense Tracker",
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          background: Colors.grey.shade100,
          onBackground: Colors.black,
          primary: Color(0xff06141b),
          secondary: Color(0xff11212d),
          outline:Color(0xff4a5c6a),
        ),
      ),
      home: AuthWrapper(),
    );
  }
}
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading indicator while checking authentication state
        } else {
          if (snapshot.hasData && snapshot.data != null) {
            return HomeScreen(); // User is signed in, navigate to main screen
          } else {
            return MainScreen(); // User is not signed in, show sign-in screen
          }
        }
      },
    );
  }
}