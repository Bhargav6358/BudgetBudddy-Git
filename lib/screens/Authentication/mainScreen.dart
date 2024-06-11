import 'package:expense_track/screens/Authentication/SignUpScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'SignInScreen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height:100,
            ),
            CircleAvatar(
              backgroundColor: Color(0xff222831),
              radius:36,
              child: ClipOval(
                child: Image.asset("assets/img/budget.png",fit: BoxFit.fill,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,),
              ),
            ),
            const SizedBox(
              height:20,
            ),
            const Text("Welcome to",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 16),),
            const SizedBox(
              height:10,
            ),
            Container(
              height: 50,
              child: Image.asset("assets/img/BudgetBuddy.png"),
            ),
            const SizedBox(
              height:15,
            ),
            const Text("A place where you can track all your expenses and incomes...",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
            const SizedBox(
              height:60,
            ),
            const Text("Let's Get Started...",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 16),),
            const SizedBox(
              height:15,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 55,
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    side: BorderSide(width: 2)
                  ),
                  backgroundColor: Colors.transparent,
                ),
                onPressed: (){},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/img/google.png",height: 25,),
                    SizedBox(width: 15,),
                    Text('Continue with Google',style: TextStyle(color: Colors.black,fontSize: 15),),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height:15,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 55,
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(width: 2)
                  ),
                  backgroundColor: Colors.transparent,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignUpScreen()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/img/mail.png",height: 45,),
                    SizedBox(width: 10,),
                    Text('Continue with Email',style: TextStyle(color: Colors.black,fontSize: 15),),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?"),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignInScreen()));
                    },
                    child: Text("SignIn",style: TextStyle(decoration: TextDecoration.underline,),)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
