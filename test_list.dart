class AppUser {
  AppUser(this.name);
  final String name;
}

class UserModel extends AppUser {
  UserModel(String name) : super(name);
}

void main() {
  List<UserModel> data = [UserModel('test')];
  
  // This is what AdminProvider does:
  List<AppUser> employees = List<AppUser>.from(data);
  
  print('employees runtime type: ${employees.runtimeType}');
  
  try {
    employees[0] = AppUser('test2');
    print('Success!');
  } catch (e) {
    print('Error: $e');
  }
}
