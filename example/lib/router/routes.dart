import 'package:example/core/network/api_client.dart';
import 'package:example/repository/user_repository.dart';
import 'package:example/screens/dashboard_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc_example/user_list_screen.dart';
import '../bloc_example/users_bloc.dart';

part 'routes.g.dart';

final router = GoRouter(routes: $appRoutes, debugLogDiagnostics: true);

@TypedGoRoute<DashboardRoute>(path: '/')
@immutable
class DashboardRoute extends GoRouteData with _$DashboardRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DashboardScreen();
  }
}

@TypedGoRoute<BlocUserListRoute>(path: '/bloc-example')
@immutable
class BlocUserListRoute extends GoRouteData with _$BlocUserListRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    final userRepository = UserRepository(ApiClient());

    return BlocProvider<UsersBloc>(
      create: (context) => UsersBloc(userRepository)..add(FetchUsers()),
      child: const BlocUserListScreen(),
    );
  }
}
