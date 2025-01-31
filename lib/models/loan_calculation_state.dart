class LoanCalculationState {
  final double desiredLoanAmount;
  final double businessRevenue;
  final double feePercentage;
  final double revenueSharePercentage;
  final String revenueShareFrequency;
  late final double totalRevenueShare;
  late final int expectedTransfers;

  LoanCalculationState({
    required this.desiredLoanAmount,
    required this.businessRevenue,
    required this.feePercentage,
    required this.revenueSharePercentage,
    required this.revenueShareFrequency,
  }) {
    // Calculate derived values once during initialization
    totalRevenueShare = desiredLoanAmount * (1 + feePercentage);
    
    double frequencyMultiplier = (revenueShareFrequency.toLowerCase() == 'weekly') ? 52 : 12;
    expectedTransfers = (totalRevenueShare * frequencyMultiplier / 
                        (businessRevenue * revenueSharePercentage)).ceil();
  }

  String calculateCompletionDate(int delayDays) {
    DateTime currentDate = DateTime.now();
    DateTime completionDate;
    
    if (revenueShareFrequency.toLowerCase() == 'weekly') {
      completionDate = currentDate.add(Duration(days: expectedTransfers * 7 + delayDays));
    } else {
      completionDate = DateTime(currentDate.year, currentDate.month + expectedTransfers, 
                              currentDate.day + delayDays);
    }
    return DateFormat('MMMM d, yyyy').format(completionDate);
  }
} 