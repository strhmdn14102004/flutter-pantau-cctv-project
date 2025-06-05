import "dart:convert";

import "package:cctv_sasat/api/api_manager.dart";
import "package:cctv_sasat/api/endpoint/sign_in/sign_in_response.dart";
import "package:cctv_sasat/module/sign_in/sign_in_event.dart";
import "package:cctv_sasat/module/sign_in/sign_in_state.dart";
import "package:dio/dio.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:shared_preferences/shared_preferences.dart";

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc() : super(SignInInitial()) {
    on<SignInSubmit>(_onSignInSubmit);
  }

  Future<void> _onSignInSubmit(
  SignInSubmit event,
  Emitter<SignInState> emit,
) async {
  emit(SignInSubmitLoading());

  try {
    final response = await ApiManager.signIn(signInRequest: event.signInRequest);

    if (response.statusCode == 200) {
      final parsed = response.data;
      final signInResponse = SignInResponse.fromJson(parsed);

      await _saveUserSession(signInResponse);
      emit(SignInSubmitSuccess(data: signInResponse));
    } else {
      emit(
        SignInSubmitFailed(
          errorMessage:
              "login_failed.please_check_your_username_and_password".tr(),
        ),
      );
    }
  } on DioException catch (e) {
    String errorMessage = "login_failed".tr();

    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data.containsKey("message")) {
        errorMessage = data["message"].toString();
      }
    }

    emit(SignInSubmitFailed(errorMessage: errorMessage));
  } catch (e) {
    emit(SignInSubmitFailed(errorMessage: "login_failed.Please_try_again".tr()));
  } finally {
    emit(SignInSubmitFinished());
  }
}

  Future<void> _saveUserSession(SignInResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", response.data.token);

    final userData = {
      "id": response.data.user.id,
      "name": response.data.user.name,
      "email": response.data.user.email,
    };
    await prefs.setString("user_data", jsonEncode(userData));
  }
}
