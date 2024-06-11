import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({Key? key}) : super(key: key);

  @override
  _AddExpenseState createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  late DateTime _selectedDate;
  TextEditingController AmountController = TextEditingController();
  TextEditingController DescriptionController = TextEditingController();
  TextEditingController CategoryController = TextEditingController();
  TextEditingController NewCategoryController = TextEditingController();
  bool _isExpense = true;
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
    _selectedDate = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addCategory() {
    showDialog(
      context: context,
      builder: (cxt) {
        String categoryName = '';

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              content: Form(
                key: _formKey1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Create a Category",
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: NewCategoryController,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Description';
                        }
                      },
                      onChanged: (value) {
                        categoryName = value;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Name",
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey1.currentState!.validate()) {
                          String userId =
                              FirebaseAuth.instance.currentUser!.uid;
                          setState(() {
                            CollectionReference collRef = FirebaseFirestore
                                .instance
                                .collection('users')
                                .doc(userId)
                                .collection('category');
                            collRef.add({
                              'name': NewCategoryController.text.toString(),
                            });
                            CategoryController.text = categoryName;
                            ScaffoldMessenger.of(context).showSnackBar(

                              SnackBar(

                                content: Text('Category added successfully'),
                              ),
                            );
                          });
                          NewCategoryController.clear();
                          Navigator.pop(context);
                        } // Close the dialog
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

  }

  void _showPredefinedCategories() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('category')
              .snapshots(),
          builder: (_, snapshot) {
            if (snapshot.hasError) return Text('Error = ${snapshot.error}');

            if (snapshot.hasData) {
              final docs = snapshot.data!.docs;
              final existingCategories = Set<String>.from(
                  docs.map((doc) => doc.data()['name'] as String));

              return ListView.builder(
                itemCount: existingCategories.length,
                itemBuilder: (_, i) {
                  final category = existingCategories.elementAt(i);
                  return ListTile(
                    title: Text(category),
                    onTap: () {
                      setState(() {
                        CategoryController.text = category;
                      });
                      Navigator.pop(context); // Close the bottom sheet
                    },
                  );
                },
              );
            }

            return Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }

  void _addTransaction() {
    if (_formKey.currentState!.validate()) {
      String description = DescriptionController.text.trim();
      double amount = double.parse(AmountController.text.trim());
      String category = CategoryController.text.trim();
      String type = _isExpense ? 'expense' : 'income';
      String userId = FirebaseAuth.instance.currentUser!.uid;


      CollectionReference transactions = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions');
      String formattedDate = DateFormat('dd MMM yyyy').format(_selectedDate);
      // Add a new transaction to Firestore
      transactions.add({
        'amount': amount,
        'description': description,
        'category': category,
        'type': type,
        'date': formattedDate,
      }).then((value) {
        // Success message or any other action
        print('Transaction added successfully');
      }).catchError((error) {
        // Error handling
        print('Failed to add transaction: $error');
      });

      // Clear the text fields after adding the transaction
      DescriptionController.clear();
      AmountController.clear();
      CategoryController.clear();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Add Transaction",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    TextFormField(
                      controller: AmountController,
                      decoration: InputDecoration(
                        labelText: "Amount",
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ), // amount
                    SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: DescriptionController,
                      decoration: InputDecoration(
                        labelText: "Description",
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Description';
                        }
                        return null;
                      },
                    ), // Description
                    SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: CategoryController,
                      readOnly: true,
                      onTap: () {
                        _showPredefinedCategories();
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: _addCategory,
                          icon: FaIcon(FontAwesomeIcons.plus),
                          iconSize: 20,
                        ),
                        labelText: "Category",
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Category';
                        }
                        return null;
                      },
                    ), // Category
                    SizedBox(height: 20),
                    TextFormField(
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        labelText: "Date",
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: Icon(
                          FontAwesomeIcons.calendar,
                          size: 20,
                        ),
                      ),
                      controller: TextEditingController(
                        text:
                            '${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Date';
                        }
                        return null;
                      },
                    ), // Date
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio(
                          value: true,
                          groupValue: _isExpense,
                          onChanged: (bool? value) {
                            setState(() {
                              _isExpense = value!;
                            });
                          },
                        ),
                        Text('Expense'),
                        Radio(
                          value: false,
                          groupValue: _isExpense,
                          onChanged: (bool? value) {
                            setState(() {
                              _isExpense = value!;
                            });
                          },
                        ),
                        Text('Income'),
                      ],
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          _addTransaction();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Save",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.background),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
