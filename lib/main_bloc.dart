// ignore_for_file: always_specify_types

import "dart:async";

import "package:base/base.dart";
import "package:cctv_sasat/constant/preference_key.dart";
import "package:cctv_sasat/helper/preferences.dart";
import "package:cctv_sasat/main_event.dart";
import "package:cctv_sasat/main_state.dart";

import "package:flutter_bloc/flutter_bloc.dart";

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(MainState(themeMode: AppColors.themeMode())) {
    on<MainThemeChanged>((event, emit) async {
      await Preferences.setInt(PreferenceKey.THEME_MODE, event.value);
      await doIt(emit);
    });
  }

  FutureOr<void> doIt(Emitter<MainState> emit) {
    emit(MainState(themeMode: AppColors.themeMode()));
  }
}
