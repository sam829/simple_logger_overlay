part of 'users_bloc.dart';

@immutable
abstract class UsersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UsersState {}

class UserLoading extends UsersState {}

class UserLoaded extends UsersState {
  final List<User> users;
  UserLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UserError extends UsersState {
  final String message;
  UserError(this.message);

  @override
  List<Object?> get props => [message];
}
