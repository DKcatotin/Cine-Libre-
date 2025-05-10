class AuthService {
  // Usuario simulado
  final String _user = "cineuser";
  final String _password = "1234";

  bool login(String username, String password) {
    return username == _user && password == _password;
  }
}
