import "package:cctv_sasat/api/endpoint/sign_in/sign_in_request.dart";
import "package:equatable/equatable.dart";

abstract class SignInEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SignInSubmit extends SignInEvent {
  final SignInRequest signInRequest;

  SignInSubmit({required this.signInRequest});

  @override
  List<Object> get props => [signInRequest];
}
