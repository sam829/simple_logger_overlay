import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../repository/user_repository.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UserRepository repository;

  UsersBloc(this.repository) : super(UserInitial()) {
    on<FetchUsers>((event, emit) async {
      emit(UserLoading());
      final result = await repository.getUsers();
      result.fold(
        (failure) => emit(UserError(failure.message)),
        (users) => emit(UserLoaded(users)),
      );
    });
  }
}
