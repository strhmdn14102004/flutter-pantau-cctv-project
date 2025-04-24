// ignore_for_file: always_specify_types, empty_constructor_bodies

import "package:cctv_sasat/module/account/account_event.dart";
import "package:cctv_sasat/module/account/account_state.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc() : super(AccountInitial()) {}
}
