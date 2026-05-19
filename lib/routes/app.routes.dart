import 'package:artriapp/models/index.dart';
import 'package:artriapp/routes/index.dart';
import 'package:go_router/go_router.dart';

abstract class AppRoutes implements RoutesSession {
  static List<RouteBase> getGoRoutes() {
    return [
      ...NotLoggedRoutes.getGoRoutes(),
      ...LoggedRoutes.getGoRoutes(),
    ];
  }
}
