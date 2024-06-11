import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MainChatWidget extends StatelessWidget {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('transactions').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final transactions = snapshot.data!.docs;
            final totalIncome = _calculateTotal(transactions, 'income');
            final totalExpense = _calculateTotal(transactions, 'expense');
            final totalAmount = totalIncome - totalExpense;
            return StatusScreen(
              totalIncome: totalIncome,
              totalExpense: totalExpense,
              totalAmount: totalAmount,
            );
          },
        ),
      ),
    );
  }

  double _calculateTotal(List<DocumentSnapshot> transactions, String type) {
    return transactions
        .where((transaction) => transaction['type'] == type)
        .map((transaction) => transaction['amount'] as double)
        .fold(0, (sum, amount) => sum + amount);
  }
}

class StatusScreen extends StatelessWidget {
  final double? totalIncome;
  final double? totalExpense;
  final double? totalAmount;

  const StatusScreen({
    Key? key,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          children: [
            const Text(
              "Status",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 120,),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ]
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                child: SfCircularChart(
                  series: _getChartData(),
                  legend: Legend(isVisible: true),

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieSeries<_ChartData, String>> _getChartData() {
    final List<_ChartData> chartData = [
      _ChartData('Income', totalIncome ?? 0,Color(0xff24565f)),
      _ChartData('Expense', totalExpense ?? 0,Color(0xff3a8890)),
      _ChartData('Balance', totalAmount ?? 0,Color(0xff00080d),),
    ];

    return <PieSeries<_ChartData, String>>[
      PieSeries<_ChartData, String>(
        radius: '120',
        strokeWidth: 5,
        strokeColor: Colors.white,

        pointColorMapper: (_ChartData data,_) => data.color,
        dataSource: chartData,
        xValueMapper: (_ChartData data, _) => data.category,
        yValueMapper: (_ChartData data, _) => data.value,
        dataLabelSettings: DataLabelSettings(isVisible: true,),
      )
    ];
  }
}

class _ChartData {
  _ChartData(this.category, this.value,this.color);
  final String category;
  final double value;
  final Color color;
}


