import "package:equatable/equatable.dart";

class SignUpEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignUpSubmit extends SignUpEvent {
  final String email;
  final String name;
  final String password;
  final String username;

  SignUpSubmit({
    required this.email,
    required this.password,
    required this.name,
    required this.username,
  });

  @override
  List<Object?> get props => [email, password, name];
}
