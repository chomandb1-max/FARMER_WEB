class AdminCodeModel {
  final String code;
  final bool isUsed;
  final String? name;
  final String? phone;
  final String? jobTitle;

  AdminCodeModel({
    required this.code,
    required this.isUsed,
    this.name,
    this.phone,
    this.jobTitle,
  });
}