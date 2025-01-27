// lib/models/config_model.dart
class Config {
  final String name;
  final String value;
  final String label;
  final String placeholder;

  Config({
    required this.name,
    required this.value,
    required this.label,
    required this.placeholder,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      name: json['name'],
      value: json['value'],
      label: json['label'],
      placeholder: json['placeholder'],
    );
  }
}