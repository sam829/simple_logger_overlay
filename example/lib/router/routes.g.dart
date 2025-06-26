// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$dashboardRoute, $blocUserListRoute];

RouteBase get $dashboardRoute =>
    GoRouteData.$route(path: '/', factory: _$DashboardRoute._fromState);

mixin _$DashboardRoute on GoRouteData {
  static DashboardRoute _fromState(GoRouterState state) => DashboardRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $blocUserListRoute => GoRouteData.$route(
  path: '/bloc-example',

  factory: _$BlocUserListRoute._fromState,
);

mixin _$BlocUserListRoute on GoRouteData {
  static BlocUserListRoute _fromState(GoRouterState state) =>
      BlocUserListRoute();

  @override
  String get location => GoRouteData.$location('/bloc-example');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
