# Loan Application
 
 The app dynamically adjusts its calculations and UI based on the provided configuration through json file and the user input.

## Getting Started

### Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Dart SDK: Included with Flutter

### Installation

1. **Clone the Repository**

   ```bash
   git clone https://github.com/NKevlar/loan_application.git
   cd loan_application
   ```

2. **Install Dependencies**

   Run the following command to install the necessary packages:

   ```bash
   flutter pub get
   ```

3. **Run the Application**

   Use the following command to run the app on your desired device:

   ```bash
   flutter run
   ```

## Configuration

The application uses a JSON configuration file to set various parameters. The configuration includes:

- **Funding Amount**: Calculated as `revenue_amount / 3`.
- **Revenue Percentage**: Calculated using the formula `(0.156 / 6.2055 / revenue_amount) * (funding_amount * 10)`.
- **Repayment Delay Options**: Configurable options for repayment delay.
- **Revenue Share Frequency**: Options for weekly or monthly revenue sharing.

## Code Structure

```
lib/
├── main.dart                    # Application entry point
├── utilities/
│   └── calculations.dart        # Calculation utilities.
├── models/
│   └── config_model.dart        # Data models for configuration
├── providers/
│   └── config_provider.dart     # State management for configurations
├── pages/
│   └── loan_application_page.dart # Main loan application UI.
└── services/
    └── api_service.dart         # API communication handling
```

### File Descriptions

- **pages/**
  - **loan_application_page.dart**: Main UI for the loan application form. This page contains the whole UI page comprising user input changes, configurations and the interactive "Results" elements which respond to user actions instantly
- **utilities/**
  - **calculations.dart**: Contains the logic for all the calculations such as fees, total revenue share, expected transfers and expected completion date, etc. Also includes expression evaluator for evaluating the expressions in the JSON configuration.
- **services/**
  - **api_service.dart**: The API service class which fetches the configuration from the JSON file.
