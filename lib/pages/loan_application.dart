// lib/main.dart
import 'dart:convert';

import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/right_pane.dart';
import '../components/left_pane.dart';
import '../providers/config_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/config_model.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../utilities/calculations.dart' as calc;

class LoanApplicationPage extends StatefulWidget {
  @override
  _LoanApplicationPageState createState() => _LoanApplicationPageState();
}

class _LoanApplicationPageState extends State<LoanApplicationPage> {
  late Future<void> _loadConfigsFuture;
  calc.LoanCalculator _calculate = calc.LoanCalculator();

  double _businessRevenue = 250000;
  double _desiredLoanAmount = 60000;
  double _minLoanAmount = 25000;
  double _maxLoanAmount = 750000;
  String _revenueShareFrequency = 'Monthly';
  String _repaymentDelay = '30 days';
  double _feePercentage = 0.6;
  String _revenueSharePercentageParser = '';
  double _revenueSharePercentage = 0;
  double _revenuePercentageMin = 4;
  double _revenuePercentageMax = 8;
  List<String> _repaymentDelayOptions = [];
  List<String> _revenueShareFrequencyOptions = [];
  List<String> _categories = [];

  final List<Map<String, dynamic>> _fundsUsage = [];
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadConfigsFuture = _initializeDefaults();
  }

  Future<void> _initializeDefaults() async {
    await Provider.of<ConfigProvider>(context, listen: false).fetchConfigs();
    final configs = Provider.of<ConfigProvider>(context, listen: false).configs;

    if (configs.isNotEmpty) {
      for (var config in configs) {
        switch (config.name) {
          case 'desired_fee_percentage':
            _feePercentage = double.tryParse(config.value) ?? 0.6;
            break;
          case 'desired_repayment_delay':
            _repaymentDelay = config.value.split('*').first;
            _repaymentDelayOptions.addAll(config.value.split('*'));
            break;
          case 'funding_amount':
            _desiredLoanAmount = _calculate.evaluateExpression(
              config.value,
              {
                'revenue_amount': _businessRevenue,
              },
            );
            break;
          case 'revenue_amount':
            _businessRevenue = double.tryParse(config.placeholder.replaceAll('\$', '').replaceAll(',', '')) ?? 250000;
            break;
          case 'revenue_percentage':
            _revenueSharePercentageParser = config.value;
            _revenueSharePercentage = _calculate.evaluateExpression(
              _revenueSharePercentageParser,
              {
                'revenue_amount': _businessRevenue,
                'funding_amount': _desiredLoanAmount,
              },
            );
            break;
          case 'revenue_shared_frequency':
            _revenueShareFrequency = config.value.split('*').first;
            _revenueShareFrequencyOptions.addAll(config.value.split('*'));
            break;
          case 'use_of_funds':
            _categories.addAll(config.value.split('*'));
            break;
          
          // Bonus section
          case 'funding_amount_max':
            _maxLoanAmount = min(double.tryParse(config.value) ?? 750000, _businessRevenue / 3);
            break;
          case 'funding_amount_min':
            _minLoanAmount = double.tryParse(config.value) ?? 25000;
            break;
          case 'revenue_percentage_min':
            _revenuePercentageMin = double.tryParse(config.value) ?? 4;
            break;
          case 'revenue_percentage_max':
            _revenuePercentageMax = double.tryParse(config.value) ?? 8;
            break;
        }
      }
      setState(() {
        _desiredLoanAmount = _desiredLoanAmount.clamp(_minLoanAmount, _maxLoanAmount);
        _revenueSharePercentage = _revenueSharePercentage.clamp(_revenuePercentageMin/100, _revenuePercentageMax/100);
        _updateCalculations();
      });
    }
  }

  void _addFundsUsage() {
    if (_selectedCategory != null &&
        _descriptionController.text.isNotEmpty &&
        _amountController.text.isNotEmpty) {
      setState(() {
        _fundsUsage.add({
          'category': _selectedCategory,
          'description': _descriptionController.text,
          'amount': _amountController.text,
        });
        _selectedCategory = null;
        _descriptionController.clear();
        _amountController.clear();
      });
    }
  }

  void _removeFundsUsage(int index) {
    setState(() {
      _fundsUsage.removeAt(index);
    });
  }

  void _updateCalculations() {
    _calculate.updateCalculations(
      desiredLoanAmount: _desiredLoanAmount,
      feePercentage: _feePercentage,
      businessRevenue: _businessRevenue,
      revenueSharePercentage: _revenueSharePercentage,
      revenueShareFrequency: _revenueShareFrequency,
      delayDays: int.parse(_repaymentDelay.split(' ')[0]),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'Ned Assessment - Loan Calculator',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder(
        future: _loadConfigsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: LeftPane(
                      calculate: _calculate,
                      businessRevenue: _businessRevenue,
                      desiredLoanAmount: _desiredLoanAmount,
                      minLoanAmount: _minLoanAmount,
                      maxLoanAmount: _maxLoanAmount,
                      revenueSharePercentage: _revenueSharePercentage,
                      revenueShareFrequency: _revenueShareFrequency,
                      repaymentDelay: _repaymentDelay,
                      revenueSharePercentageParser: _revenueSharePercentageParser,
                      repaymentDelayOptions: _repaymentDelayOptions,
                      revenueShareFrequencyOptions: _revenueShareFrequencyOptions,
                      categories: _categories,
                      fundsUsage: _fundsUsage,
                      onBusinessRevenueChanged: (value) {
                        setState(() {
                          _businessRevenue = value;
                          double revenueBasedMax = _businessRevenue / 3;
                          _maxLoanAmount = min(750000, revenueBasedMax);
                          _minLoanAmount = min(25000, _maxLoanAmount);
                          _desiredLoanAmount = _desiredLoanAmount.clamp(_minLoanAmount, _maxLoanAmount);
                          _updateCalculations();
                        });
                      },
                      onDesiredLoanAmountChanged: (value) {
                        setState(() {
                          _desiredLoanAmount = value;
                          _updateCalculations();
                        });
                      },
                      onRevenueShareFrequencyChanged: (value) {
                        setState(() {
                          _revenueShareFrequency = value;
                          _updateCalculations();
                        });
                      },
                      onRepaymentDelayChanged: (value) {
                        setState(() {
                          _repaymentDelay = value;
                          _updateCalculations();
                        });
                      },
                      onFundsUsageAdded: (usage) {
                        setState(() {
                          _fundsUsage.add(usage);
                        });
                      },
                      onFundsUsageRemoved: (index) {
                        setState(() {
                          _fundsUsage.removeAt(index);
                        });
                      },
                      onCategoryChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 32),
                  Expanded(
                    flex: 1,
                    child: RightPane(
                      businessRevenue: _businessRevenue,
                      desiredLoanAmount: _desiredLoanAmount,
                      calculate: _calculate,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}