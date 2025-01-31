import 'dart:math';
import 'package:expressions/expressions.dart';
import 'package:intl/intl.dart';

class LoanCalculator {

  double _totalRevenueShare = 0;
  int _expectedTransfers = 0;
  String _completionDate = '';
  double _fees = 0;

  double get totalRevenueShare => _totalRevenueShare;
  int get expectedTransfers => _expectedTransfers;
  String get completionDate => _completionDate;
  double get fees => _fees;

  double evaluateExpression(String expression, Map<String, double> variables) {
    final evaluator = ExpressionEvaluator();
    final parsedExpression = Expression.parse(expression);
    return evaluator.eval(parsedExpression, variables) as double;
  }


  void updateCalculations({
    required double desiredLoanAmount,
    required double feePercentage,
    required double businessRevenue,
    required double revenueSharePercentage,
    required String revenueShareFrequency,
    required int delayDays,
  }) {

    _fees = desiredLoanAmount * feePercentage;
    _totalRevenueShare = desiredLoanAmount * (1 + feePercentage);


    double frequencyMultiplier = (revenueShareFrequency.toLowerCase() == 'weekly') ? 52 : 12;
    _expectedTransfers = (_totalRevenueShare * frequencyMultiplier / 
                        (businessRevenue * revenueSharePercentage)).ceil();

    DateTime currentDate = DateTime.now();
    DateTime completionDate;
    
    if (revenueShareFrequency.toLowerCase() == 'weekly') {
      completionDate = currentDate.add(Duration(days: _expectedTransfers * 7 + delayDays));
    } else {
      completionDate = DateTime(
        currentDate.year, 
        currentDate.month + _expectedTransfers, 
        currentDate.day + delayDays
      );
    }
    _completionDate = DateFormat('MMMM d, yyyy').format(completionDate);
  }
}