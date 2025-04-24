import "package:equatable/equatable.dart";

class SignUpState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignUpInitial extends SignUpState {}

class SignUpSubmitLoading extends SignUpState {}

class SignUpSubmitSuccess extends SignUpState {
  final String message;

  SignUpSubmitSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class SignUpSubmitError extends SignUpState {
  final String error;

  SignUpSubmitError({required this.error});

  @override
  List<Object?> get props => [error];
}

class SignUpSubmitFinished extends SignUpState {}
