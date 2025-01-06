import 'package:hex_place/hex_place.dart';
import 'package:hex_place/locator.dart';
import 'package:hex_place/services/auth_service_login.dart';
import 'package:hex_place/util/navigation_service.dart';
import 'package:hex_place/views/user_interface/ui_views/login_view/login_window_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hex_place/constants/route_paths.dart' as routes;


class WorldAccess extends StatefulWidget {

  final HexPlace game;

  const WorldAccess({
    super.key,
    required this.game
  });

  @override
  State<WorldAccess> createState() => _WorldAccessState();
}

class _WorldAccessState extends State<WorldAccess> {

  final NavigationService _navigationService = locator<NavigationService>();

  @override
  void initState() {
    super.initState();
    String? accessToken = Uri.base.queryParameters["access_token"];
    String? refreshToken = Uri.base.queryParameters["refresh_token"];

    print("WorldAccess: accessToken: $accessToken");
    print("WorldAccess: refreshToken: $refreshToken");

    // Use the tokens to immediately refresh the access token
    if (accessToken != null && refreshToken != null) {
      AuthServiceLogin authService = AuthServiceLogin();
      authService.getRefresh(accessToken, refreshToken).then((loginResponse) {
        if (loginResponse.getResult()) {
          setState(() {
            LoginWindowChangeNotifier().setLoginWindowVisible(false);
          });
        }
        Future.delayed(const Duration(milliseconds: 500), () {
          _navigationService.navigateTo(routes.HomeRoute);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
        ),
      ),
    );
  }
}
