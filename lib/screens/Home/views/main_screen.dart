import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../Authentication/SignInScreen.dart';
import '../../Authentication/user_login.dart';
import '../../view_all_Transactions.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  double totalAmount = 0;
  double totalExpense = 0;
  double totalIncome = 0;
  late String userName = '';
  final UserLogin _userLogin = UserLogin();
  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _updateTotals();
    _fetchUserName();
  }

  void _updateTotals() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .snapshots()
        .listen((snapshot) {
      double tempTotalAmount = 0;
      double tempTotalExpense = 0;
      double tempTotalIncome = 0;

      snapshot.docs.forEach((doc) {
        double amount = doc['amount'] ?? 0.0;
        String type = doc['type'] ?? '';

        if (type == 'expense') {
          tempTotalExpense += amount;
          tempTotalAmount -= amount;
        } else {
          tempTotalIncome += amount;
          tempTotalAmount += amount;
        }
      });

      setState(() {
        totalAmount = tempTotalAmount;
        totalExpense = tempTotalExpense;
        totalIncome = tempTotalIncome;
      });
    });
  }

  Future<void> _fetchUserName() async {
    // Fetch the current user's document from Firestore
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        setState(() {
          userName = userData['username'] ??
              ''; // Assuming 'name' is the field storing user's name
        });
      }
    } catch (e) {
      return;
    }
  }

  Future<void> _deleteTransaction(String id) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(id)
        .delete();
  }

  Future<void> _updateTransaction(
      String id, Map<String, dynamic> newData) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(id)
        .update(newData);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xff9ba8ab),
                          ),
                        ),
                        const Icon(
                          CupertinoIcons.person_fill,
                          color: Color(0xff06141b),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        Text(
                          userName ?? "Loading...",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                IconButton(
                    onPressed: () async {
                      await _userLogin.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignInScreen()),
                      );
                    },
                    icon: const Icon(Icons.logout))
              ],
            ), // appbar
            const SizedBox(
              height: 20,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width / 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 4,
                      color: Colors.grey.shade300,
                      offset: const Offset(5, 5)),
                ],
                gradient: const LinearGradient(
                  colors: [
                    Colors.black,
                    Color(0xff06141b),
                    Color(0xff11212d),
                    Color(0xff253745),
                    Color(0xff4a5c6a),
                  ],
                  end: Alignment(0.5, 0),
                  transform: GradientRotation(pi / 2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Total Balance",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "₹$totalAmount",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                color: Colors.lightGreen.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  CupertinoIcons.arrow_down,
                                  size: 12,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Income",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    )),
                                Text("₹$totalIncome",
                                    style: TextStyle(
                                      color: Colors.lightGreen.shade100,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  CupertinoIcons.arrow_up,
                                  size: 12,
                                  color: Colors.red.shade900,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Expense",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    )),
                                Text("₹$totalExpense",
                                    style: TextStyle(
                                      color: Colors.red.shade100,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ), //card
            const SizedBox(
              height: 30.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Transactions",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewAllTransactions(),
                      ),
                    );
                  },
                  child: Text(
                    "View All",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ), // tarnsaction title
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('transactions')
                    .limit(4)
                    .snapshots(),
                builder: (_, snapshot) {
                  if (snapshot.hasError)
                    return Text('Error = ${snapshot.error}');

                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());

                  if (snapshot.hasData) {
                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (_, i) {
                        final data = docs[i].data();
                        final id = docs[i].id;

                        return Dismissible(
                          key: UniqueKey(),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              bool deleteConfirmed = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: Text("Confirm Delete"),
                                    content: Text(
                                        "Are you sure you want to delete this transaction?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(true); // Confirm delete
                                        },
                                        child: Text("Delete"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(false); // Cancel delete
                                        },
                                        child: Text("Cancel"),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (deleteConfirmed == true) {
                                await _deleteTransaction(id);
                                return true;
                              } else {
                                return false; // Cancel deletion
                              }
                            } else {
                              // Show update dialog
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  TextEditingController descriptionController =
                                      TextEditingController(
                                          text: data['description']);
                                  TextEditingController amountController =
                                      TextEditingController(
                                          text: data['amount'].toString());
                                  TextEditingController categoryController =
                                      TextEditingController(
                                          text: data['category'].toString());

                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: Text("Update Transaction"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          maxLines: 1,
                                          controller: descriptionController,
                                          decoration: InputDecoration(
                                            labelText: 'Description',
                                            filled: true,
                                            fillColor: Colors.white,
                                            labelStyle:
                                                TextStyle(color: Colors.black),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        TextFormField(
                                          keyboardType: TextInputType.text,
                                          controller: categoryController,
                                          readOnly: true,
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return StreamBuilder<
                                                    QuerySnapshot<
                                                        Map<String, dynamic>>>(
                                                  stream: FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(userId)
                                                      .collection('category')
                                                      .snapshots(),
                                                  builder: (_, snapshot) {
                                                    if (snapshot.hasError)
                                                      return Text(
                                                          'Error = ${snapshot.error}');

                                                    if (snapshot.hasData) {
                                                      final docs =
                                                          snapshot.data!.docs;
                                                      final existingCategories =
                                                          Set<String>.from(docs
                                                              .map((doc) => doc
                                                                          .data()[
                                                                      'name']
                                                                  as String));

                                                      return ListView.builder(
                                                        itemCount:
                                                            existingCategories
                                                                .length,
                                                        itemBuilder: (_, i) {
                                                          final category =
                                                              existingCategories
                                                                  .elementAt(i);
                                                          return ListTile(
                                                            title:
                                                                Text(category),
                                                            onTap: () {
                                                              setState(() {
                                                                categoryController
                                                                        .text =
                                                                    category;
                                                              });
                                                              Navigator.pop(
                                                                  context); // Close the bottom sheet
                                                            },
                                                          );
                                                        },
                                                      );
                                                    }

                                                    return Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            labelText: "Category",
                                            labelStyle:
                                                TextStyle(color: Colors.black),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),

                                        TextField(
                                          controller: amountController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Amount',
                                            filled: true,
                                            fillColor: Colors.white,
                                            labelStyle:
                                                TextStyle(color: Colors.black),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () async {
                                                String newDescription =
                                                    descriptionController.text;
                                                double newAmount = double.parse(
                                                    amountController.text);

                                                Map<String, dynamic> newData = {
                                                  'description': newDescription,
                                                  'amount': newAmount,
                                                };

                                                await _updateTransaction(
                                                    id, newData);
                                                Navigator.of(context)
                                                    .pop(); // Close dialog
                                              },
                                              child: Text("Update"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close dialog
                                              },
                                              child: Text("Cancel"),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );

                              return false; // Cancel swipe action
                            }
                          },
                          child: Material(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              FaIcon(
                                                data['type'] == 'expense'
                                                    ? Icons
                                                        .money_off // Expense icon
                                                    : Icons.attach_money,
                                                color: const Color(0xff9ba8ab),
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['category']
                                                    .toString()
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              Material(
                                                color: Colors.white,
                                                child: Container(
                                                  width: 130,
                                                  child: Text(
                                                    data['description'],
                                                    style: TextStyle(
                                                      letterSpacing: 1,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .outline,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            children: [
                                              data['type'] == 'expense'
                                                  ? Icon(
                                                      CupertinoIcons
                                                          .arrow_down_circle_fill,
                                                      size: 15,
                                                      color:
                                                          Colors.red.shade900)
                                                  : Icon(
                                                      CupertinoIcons
                                                          .arrow_up_circle_fill,
                                                      size: 15,
                                                      color:
                                                          Colors.green.shade900,
                                                    ),
                                              SizedBox(
                                                width: 3,
                                              ),
                                              Text(
                                                "\₹ ${data['amount'].toString()}",
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .outline,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            data['date'],
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
