import "package:cctv_sasat/api/endpoint/sign_in/sign_in_response.dart";
import "package:equatable/equatable.dart";

abstract class SignInState extends Equatable {
  @override
  List<Object> get props => [];
}

class SignInInitial extends SignInState {}

class SignInSubmitLoading extends SignInState {}

class SignInSubmitSuccess extends SignInState {
  final SignInResponse data;

  SignInSubmitSuccess({required this.data});

  @override
  List<Object> get props => [data];
}

class SignInSubmitFailed extends SignInState {
  final String errorMessage;

  SignInSubmitFailed({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

class SignInSubmitFinished extends SignInState {}
