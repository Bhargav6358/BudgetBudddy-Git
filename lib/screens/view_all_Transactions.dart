import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewAllTransactions extends StatefulWidget {
  const ViewAllTransactions({super.key});

  @override
  State<ViewAllTransactions> createState() => _ViewAllTransactionsState();
}

class _ViewAllTransactionsState extends State<ViewAllTransactions> {
  String userId = FirebaseAuth.instance.currentUser!.uid;
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
    return Scaffold(
        appBar: AppBar(
          title: Text('All Transactions'),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('transactions')
                .snapshots(),
            builder: (_, snapshot) {
              if (snapshot.hasError) {
                return Text('Error = ${snapshot.error}');
              }
          
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
          
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
                                              stream: FirebaseFirestore
                                                  .instance
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
                                    ), //
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
          
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ));
  }
}
