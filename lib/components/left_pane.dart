import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utilities/calculations.dart';

class LeftPane extends StatefulWidget {
  final LoanCalculator calculate;
  final double businessRevenue;
  final double desiredLoanAmount;
  final double minLoanAmount;
  final double maxLoanAmount;
  final double revenueSharePercentage;
  final String revenueShareFrequency;
  final String repaymentDelay;
  final String revenueSharePercentageParser;
  final List<String> repaymentDelayOptions;
  final List<String> revenueShareFrequencyOptions;
  final List<String> categories;
  final List<Map<String, dynamic>> fundsUsage;
  final Function(double) onBusinessRevenueChanged;
  final Function(double) onDesiredLoanAmountChanged;
  final Function(String) onRevenueShareFrequencyChanged;
  final Function(String) onRepaymentDelayChanged;
  final Function(Map<String, dynamic>) onFundsUsageAdded;
  final Function(int) onFundsUsageRemoved;
  final Function(String?) onCategoryChanged;

  const LeftPane({
    Key? key,
    required this.calculate,
    required this.businessRevenue,
    required this.desiredLoanAmount,
    required this.minLoanAmount,
    required this.maxLoanAmount,
    required this.revenueSharePercentage,
    required this.revenueShareFrequency,
    required this.repaymentDelay,
    required this.revenueSharePercentageParser,
    required this.repaymentDelayOptions,
    required this.revenueShareFrequencyOptions,
    required this.categories,
    required this.fundsUsage,
    required this.onBusinessRevenueChanged,
    required this.onDesiredLoanAmountChanged,
    required this.onRevenueShareFrequencyChanged,
    required this.onRepaymentDelayChanged,
    required this.onFundsUsageAdded,
    required this.onFundsUsageRemoved,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  _LeftPaneState createState() => _LeftPaneState();
}

class _LeftPaneState extends State<LeftPane> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String? _selectedCategory;

  void _addFundsUsage() {
    if (_selectedCategory != null &&
        _descriptionController.text.isNotEmpty &&
        _amountController.text.isNotEmpty) {
      widget.onFundsUsageAdded({
        'category': _selectedCategory,
        'description': _descriptionController.text,
        'amount': _amountController.text,
      });
      setState(() {
        _selectedCategory = null;
        _descriptionController.clear();
        _amountController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text(
              'What is your annual business revenue? * (Press Enter to submit)',
              style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (value) {
              final newRevenue = double.tryParse(value) ?? 250000;
              widget.onBusinessRevenueChanged(newRevenue);
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
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$${widget.minLoanAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black)),
                        Text(
                            '\$${(widget.businessRevenue / 3).toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black)),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Slider(
                          value: widget.desiredLoanAmount,
                          min: widget.minLoanAmount,
                          max: widget.maxLoanAmount,
                          divisions: 100,
                          activeColor: Color(0xFF007BFF),
                          inactiveColor: Color(0xFFDDDDDD),
                          onChanged: widget.onDesiredLoanAmountChanged,
                        ),
                        Positioned(
                          top: -20,
                          child: Text(
                            '\$${widget.desiredLoanAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
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
                  controller: TextEditingController(
                      text:
                          '\$${widget.desiredLoanAmount.toStringAsFixed(0)}'),
                  readOnly: true,
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    hintText: 'Desired Loan Amount',
                    hintStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey),
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
                '${(widget.revenueSharePercentage * 100).toStringAsFixed(2)}%',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: widget.revenueShareFrequencyOptions.map((frequency) {
              return Row(
                children: [
                  Radio(
                    value: frequency,
                    groupValue: widget.revenueShareFrequency,
                    activeColor: Color(0xFF007BFF),
                    onChanged: (value) => widget.onRevenueShareFrequencyChanged(value.toString()),
                  ),
                  Text(frequency),
                  SizedBox(width: 16),
                ],
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Desired Repayment Delay',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              SizedBox(width: 16),
              DropdownButton<String>(
                value: widget.repaymentDelay,
                items: widget.repaymentDelayOptions.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                )).toList(),
                onChanged: (value) => widget.onRepaymentDelayChanged(value!),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text('What will you use the funds for?',
              style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: Text('Select Category'),
                  items: widget.categories.map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  )).toList(),
                  onChanged: widget.onCategoryChanged,
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
            itemCount: widget.fundsUsage.length,
            itemBuilder: (context, index) {
              final usage = widget.fundsUsage[index];
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
                      onPressed: () => widget.onFundsUsageRemoved(index),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
