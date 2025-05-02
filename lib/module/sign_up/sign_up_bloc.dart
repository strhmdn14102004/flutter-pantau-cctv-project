import "package:bloc/bloc.dart";
import "package:cctv_sasat/api/api_manager.dart";
import "package:cctv_sasat/api/endpoint/sign_up/sign_up_request.dart";
import "package:cctv_sasat/module/sign_up/sign_up_event.dart";
import "package:cctv_sasat/module/sign_up/sign_up_state.dart";
import "package:easy_localization/easy_localization.dart";

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
            username: event.username,
          ),
        );

        if (response.statusCode == 200) {
          emit(SignUpSubmitSuccess(message: "register_success".tr()));
        } else {
          emit(
            SignUpSubmitError(
              error: "terjadi_kesalahan_ketika_mendaftar".tr(),
            ),
          );
        }
      } catch (e) {
        emit(SignUpSubmitError(error: e.toString()));
      }
    });
  }
}
