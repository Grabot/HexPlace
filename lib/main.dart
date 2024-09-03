import 'dart:async';

import 'package:hex_place/constants/route_paths.dart' as routes;
import 'package:hex_place/locator.dart';
import 'package:hex_place/services/settings.dart';
import 'package:hex_place/util/navigation_service.dart';
import 'package:hex_place/views/email_verification_page.dart';
import 'package:hex_place/views/user_interface/ui_views/change_avatar_box/change_avatar_box.dart';
import 'package:hex_place/views/user_interface/ui_views/change_guild_crest_box/change_guild_crest_box.dart';
import 'package:hex_place/views/user_interface/ui_views/guild_window/guild_window.dart';
import 'package:hex_place/views/user_interface/ui_views/login_view/login_window.dart';
import 'package:hex_place/views/user_interface/ui_views/map_coordinates/map_coordinates.dart';
import 'package:hex_place/views/user_interface/ui_views/map_coordintes_window/map_coordinates_window.dart';
import 'package:hex_place/views/user_interface/ui_views/social_interaction/social_interaction.dart';
import 'package:hex_place/views/user_interface/ui_views/zoom_widget/zoom_widget.dart';
import 'package:hex_place/views/world_access_page.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_strategy/url_strategy.dart';

import 'hex_place.dart';
import 'views/user_interface/ui_views/are_you_sure_box/are_you_sure_box.dart';
import 'views/user_interface/ui_views/chat_box/chat_box.dart';
import 'views/user_interface/ui_views/chat_window/chat_window.dart';
import 'views/user_interface/ui_views/friend_window/friend_window.dart';
import 'views/user_interface/ui_views/loading_box/loading_box.dart';
import 'views/user_interface/ui_views/profile_box/profile_box.dart';
import 'views/user_interface/ui_views/profile_overview/profile_overview.dart';
import 'views/user_interface/ui_views/tile_box/tile_box.dart';
import 'views/user_interface/ui_views/user_box/user_box.dart';


Future<void> main() async {
  setPathUrlStrategy();
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();

  // initialize the settings singleton
  Settings();
  Flame.images.loadAll(<String>[]);

  FocusNode gameFocus = FocusNode();

  final game = HexPlace(gameFocus);

  Widget gameWidget = Scaffold(
      body: GameWidget(
        focusNode: gameFocus,
        game: game,
        overlayBuilderMap: const {
          'mapCoordinates': _mapCoordinatesBoxBuilder,
          'zoomWidget': _zoomWidgetBoxBuilder,
          'chatBox': _chatBoxBuilder,
          'loginWindow': _loginWindowBuilder,
          'mapCoordinatesWindow': _mapCoordinatesWindowBuilder,
          'tileBox': _tileBoxBuilder,
          'profileBox': _profileBoxBuilder,
          'socialInteraction': _socialInteractionBuilder,
          'profileOverview': _profileOverviewBuilder,
          'changeAvatar': _changeAvatarBoxBuilder,
          'chatWindow': _chatWindowBuilder,
          'friendWindow': _friendWindowBuilder,
          'userBox': _userBoxBuilder,
          'guildWindow': _guildWindowBoxBuilder,
          'changeGuildCrest': _changeGuildCrestBoxBuilder,
          'areYouSureBox': _areYouSureBoxBuilder,
          'loadingBox': _loadingBoxBuilder,
        },
        initialActiveOverlays: const [
          'mapCoordinates',
          'zoomWidget',
          'chatBox',
          'loginWindow',
          'mapCoordinatesWindow',
          'tileBox',
          'profileBox',
          'socialInteraction',
          'profileOverview',
          'changeAvatar',
          'chatWindow',
          'friendWindow',
          'userBox',
          'guildWindow',
          'changeGuildCrest',
          'areYouSureBox',
          'loadingBox',
        ],
      )
  );

  Widget worldAccess = WorldAccess(key: UniqueKey(), game: game);
  Widget emailVerification = EmailVerification(key: UniqueKey(), game: game);

  runApp(
      OKToast(
        child: MaterialApp(
          title: "Hex Place",
          navigatorKey: locator<NavigationService>().navigatorKey,
          theme: ThemeData(
            // Define the default brightness and colors.
            brightness: Brightness.dark,
            primaryColor: Colors.lightBlue,
            // Define the default font family.
            fontFamily: 'Georgia',
          ),
          initialRoute: '/',
          routes: {
            routes.HomeRoute: (context) => gameWidget,
            routes.WorldAccessRoute: (context) => worldAccess,
            routes.EmailVerificationRoute: (context) => emailVerification
          },
          onGenerateRoute: (settings) {
            if (settings.name != null && settings.name!.startsWith(routes.WorldAccessRoute)) {
              return MaterialPageRoute(
                  builder: (context) {
                    return worldAccess;
                  }
              );
            } else if (settings.name!.startsWith(routes.EmailVerificationRoute)) {
              return MaterialPageRoute(
                  builder: (context) {
                    return emailVerification;
                  }
              );
            } else {
              return MaterialPageRoute(
                  builder: (context) {
                    return gameWidget;
                  }
              );
            }
          },
        ),
      )
  );
}

Widget _chatBoxBuilder(BuildContext buildContext, HexPlace game) {
  return ChatBox(key: UniqueKey(), game: game);
}

Widget _loginWindowBuilder(BuildContext buildContext, HexPlace game) {
  return LoginWindow(key: UniqueKey(), game: game);
}

Widget _tileBoxBuilder(BuildContext buildContext, HexPlace game) {
  return TileBox(key: UniqueKey(), game: game);
}

Widget _profileBoxBuilder(BuildContext buildContext, HexPlace game) {
  return ProfileBox(key: UniqueKey(), game: game);
}

Widget _profileOverviewBuilder(BuildContext buildContext, HexPlace game) {
  return ProfileOverview(key: UniqueKey(), game: game);
}

Widget _socialInteractionBuilder(BuildContext buildContext, HexPlace game) {
  return SocialInteraction(key: UniqueKey(), game: game);
}

Widget _userBoxBuilder(BuildContext buildContext, HexPlace game) {
  return UserBox(key: UniqueKey(), game: game);
}

Widget _changeAvatarBoxBuilder(BuildContext buildContext, HexPlace game) {
  return ChangeAvatarBox(key: UniqueKey(), game: game);
}

Widget _loadingBoxBuilder(BuildContext buildContext, HexPlace game) {
  return LoadingBox(key: UniqueKey(), game: game);
}

Widget _areYouSureBoxBuilder(BuildContext buildContext, HexPlace game) {
  return AreYouSureBox(key: UniqueKey(), game: game);
}

Widget _mapCoordinatesBoxBuilder(BuildContext buildContext, HexPlace game) {
  return MapCoordinates(key: UniqueKey(), game: game);
}

Widget _zoomWidgetBoxBuilder(BuildContext buildContext, HexPlace game) {
  return ZoomWidget(key: UniqueKey(), game: game);
}

Widget _mapCoordinatesWindowBuilder(BuildContext buildContext, HexPlace game) {
  return MapCoordinatesWindow(key: UniqueKey(), game: game);
}

Widget _chatWindowBuilder(BuildContext buildContext, HexPlace game) {
  return ChatWindow(key: UniqueKey(), game: game);
}

Widget _friendWindowBuilder(BuildContext buildContext, HexPlace game) {
  return FriendWindow(key: UniqueKey(), game: game);
}

Widget _guildWindowBoxBuilder(BuildContext buildContext, HexPlace game) {
  return GuildWindow(key: UniqueKey(), game: game);
}

Widget _changeGuildCrestBoxBuilder(BuildContext buildContext, HexPlace game) {
  return ChangeGuildCrestBox(key: UniqueKey(), game: game);
}
