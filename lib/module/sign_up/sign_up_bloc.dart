import "package:bloc/bloc.dart";
import "package:cctv_sasat/api/api_manager.dart";
import "package:cctv_sasat/api/endpoint/sign_up/sign_up_request.dart";
import "package:cctv_sasat/module/sign_up/sign_up_event.dart";
import "package:cctv_sasat/module/sign_up/sign_up_state.dart";

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc() : super(SignUpInitial()) {
    on<SignUpSubmit>((event, emit) async {
      emit(SignUpSubmitLoading());

      try {
        final response = await ApiManager.signUp(
          signUpRequest: SignUpRequest(
            email: event.email,
            password: event.password,
            name: event.name,
            username: event.email,
          ),
        );

        if (response.statusCode == 200) {
          emit(SignUpSubmitSuccess(message: "Berhasil mendaftar!"));
        } else {
          emit(SignUpSubmitError(error: "Terjadi kesalahan saat mendaftar"));
        }
      } catch (e) {
        emit(SignUpSubmitError(error: e.toString()));
      }
    });
  }
}
