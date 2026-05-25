class RegistrationRequest {
  const RegistrationRequest({
    required this.nik,
    required this.name,
    required this.password,
    required this.department,
    required this.position,
    this.phone,
  });

  final String nik;
  final String name;
  final String password;
  final String department;
  final String position;
  final String? phone;
}
