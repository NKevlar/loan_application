// lib/main.dart
import 'dart:convert';

import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loan_application/providers/config_provider.dart';
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
                  // Left Pane: Financing Options
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Financing Options',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16),
                          Text('What is your annual business revenue? * (Press Enter to submit)',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          SizedBox(height: 8),
                          TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onSubmitted: (value) {
                              setState(() {
                                _businessRevenue = double.tryParse(value) ?? 250000;
                                double revenueBasedMax = _businessRevenue / 3;
                                _maxLoanAmount = revenueBasedMax;
                                if (_minLoanAmount > _maxLoanAmount) {
                                  _minLoanAmount = 0;
                                }
                                _desiredLoanAmount = _desiredLoanAmount.clamp(_minLoanAmount, _maxLoanAmount);
                                _revenueSharePercentage = _calculate.evaluateExpression(
                                  _revenueSharePercentageParser,
                                  {
                                    'revenue_amount': _businessRevenue,
                                    'funding_amount': _desiredLoanAmount,
                                  },
                                );
                                _updateCalculations();
                              });
                            },
                            decoration: InputDecoration(
                              prefixText: '\$ ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Color(0xFFF5F6FA),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('What is your desired loan amount?',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                    SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('\$${_minLoanAmount.toStringAsFixed(0)}',
                                            style: TextStyle(
                                                fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)),
                                        Text('\$${(_businessRevenue / 3).toStringAsFixed(0)}',
                                            style: TextStyle(
                                                fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)),
                                      ],
                                    ),
                                    Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        Slider(
                                          value: _desiredLoanAmount,
                                          min: _minLoanAmount,
                                          max: _maxLoanAmount,
                                          divisions: 100,
                                          activeColor: Color(0xFF007BFF),
                                          inactiveColor: Color(0xFFDDDDDD),
                                          onChanged: (value) {
                                            setState(() {
                                              _desiredLoanAmount = value;
                                              _revenueSharePercentage = _calculate.evaluateExpression(
                                                _revenueSharePercentageParser,
                                                {
                                                  'revenue_amount': _businessRevenue,
                                                  'funding_amount': _desiredLoanAmount,
                                                },
                                              );
                                              _updateCalculations();
                                            });
                                          },
                                        ),
                                        Positioned(
                                          top: -20,
                                          child: Text(
                                            '\$${_desiredLoanAmount.toStringAsFixed(0)}',
                                            style: TextStyle(
                                                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  controller: TextEditingController(text: '\$${_desiredLoanAmount.toStringAsFixed(0)}'),
                                  readOnly: true,
                                  style: TextStyle(fontSize: 14, color: Colors.black),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    filled: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    hintText: 'Desired Loan Amount',
                                    hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Revenue Share Percentage:',
                                style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${(_revenueSharePercentage*100).toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Text('Revenue Shared Frequency',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              SizedBox(width: 16),
                              Row(
                                children: _revenueShareFrequencyOptions.map((frequency) {
                                  return Row(
                                    children: [
                                      Radio(
                                        value: frequency,
                                        groupValue: _revenueShareFrequency,
                                        activeColor: Color(0xFF007BFF),
                                        onChanged: (value) {
                                          setState(() {
                                            _revenueShareFrequency = value.toString();
                                            _updateCalculations();
                                          });
                                        },
                                      ),
                                      Text(frequency),
                                      SizedBox(width: 16),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Desired Repayment Delay',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              SizedBox(width: 16),
                              DropdownButton<String>(
                                value: _repaymentDelay,
                                items: _repaymentDelayOptions
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _repaymentDelay = value!;
                                    _updateCalculations();
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text('What will you use the funds for?',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  hint: Text('Select Category'),
                                  items: _categories
                                      .map((category) => DropdownMenuItem(
                                            value: category,
                                            child: Text(category),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCategory = value;
                                      _updateCalculations();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                flex: 4,
                                child: TextField(
                                  controller: _descriptionController,
                                  decoration: InputDecoration(
                                    hintText: 'Description',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Color(0xFFF5F6FA),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Amount',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Color(0xFFF5F6FA),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle, color: Color(0xFF007BFF)),
                                onPressed: _addFundsUsage,
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: _fundsUsage.length,
                            itemBuilder: (context, index) {
                              final usage = _fundsUsage[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(usage['category']!,
                                          style: TextStyle(fontSize: 14)),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      flex: 4,
                                      child: Text(usage['description']!,
                                          style: TextStyle(fontSize: 14)),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      flex: 2,
                                      child: Text('\$${usage['amount']}',
                                          style: TextStyle(fontSize: 14)),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removeFundsUsage(index),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 32),
                  // Right Pane: Results
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Results',
                            style: TextStyle(
                              fontSize: 24, // Adjusted to match the mockup
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Divider(
                            color: Colors.grey[300],
                            thickness: 1,
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Annual Business Revenue:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '\$${_businessRevenue.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Funding Amount:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '\$${_desiredLoanAmount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Fees (50%):',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '\$${_calculate.fees.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Divider(
                            color: Colors.grey[300],
                            thickness: 1,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Revenue Share:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '\$${_calculate.totalRevenueShare.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Expected Transfers:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${_calculate.expectedTransfers}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Expected Completion Date:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                _calculate.completionDate,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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