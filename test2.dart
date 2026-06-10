class AppUser {
  AppUser();
}

class UserModel extends AppUser {
  UserModel();
}

void main() {
  List<AppUser> employees = <AppUser>[];
  
  List<UserModel> data = [UserModel()];
  // If success: (data) => _employees = data as List<AppUser>;
  
  void simulate(void Function(List<AppUser>) success) {
    success(data); // data is List<UserModel>
  }
  
  simulate((data) {
    employees = List<AppUser>.from(data);
  });
  
  print('employees type: ${employees.runtimeType}');
  employees[0] = AppUser();
  print('Ok');
}
