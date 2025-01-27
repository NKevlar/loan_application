import 'dart:math';
import 'package:expressions/expressions.dart';
import 'package:intl/intl.dart';

class LoanCalculator {
  double evaluateExpression(String expression, Map<String, double> variables) {
    final evaluator = ExpressionEvaluator();
    final parsedExpression = Expression.parse(expression);
    return evaluator.eval(parsedExpression, variables) as double;
  }

  double calculateFees(double desiredLoanAmount, double feePercentage) {
    return desiredLoanAmount * feePercentage;
  }

  double calculateTotalRevenueShare(double desiredLoanAmount, double feePercentage) {
    return desiredLoanAmount + calculateFees(desiredLoanAmount, feePercentage);
  }

  int calculateExpectedTransfers(double totalRevenueShare, double businessRevenue, double revenueSharePercentage, String frequency) {
    double revenueShareDecimal = revenueSharePercentage / 100;
    if (frequency == 'weekly') {
      return (totalRevenueShare * 52 / (businessRevenue * revenueShareDecimal)).ceil();
    } else {
      return (totalRevenueShare * 12 / (businessRevenue * revenueShareDecimal)).ceil();
    }
  }

  String calculateExpectedCompletionDate(int transfers, int delayDays, String frequency) {
    DateTime currentDate = DateTime.now();
    DateTime completionDate;
    if (frequency == 'weekly') {
      completionDate = currentDate.add(Duration(days: transfers * 7 + delayDays));
    } else {
      completionDate = DateTime(currentDate.year, currentDate.month + transfers, currentDate.day + delayDays);
    }
    return DateFormat('MMMM d, yyyy').format(completionDate);
  }
}

// Function to evaluate expressions
double evaluateExpression(String expression, Map<String, double> variables) {
  final evaluator = ExpressionEvaluator();
  final parsedExpression = Expression.parse(expression);
  return evaluator.eval(parsedExpression, variables) as double;
}