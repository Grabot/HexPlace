import 'package:hex_place/hex_place.dart';
import 'package:hex_place/services/settings.dart';
import 'package:hex_place/services/socket_services.dart';
import 'package:hex_place/util/countdown.dart';
import 'package:hex_place/util/navigation_service.dart';
import 'package:hex_place/util/render_objects.dart';
import 'package:hex_place/util/util.dart';
import 'package:hex_place/views/user_interface/ui_util/clear_ui.dart';
import 'package:hex_place/views/user_interface/ui_util/selected_tile_info.dart';
import 'package:hex_place/locator.dart';
import 'package:hex_place/views/user_interface/ui_views/chat_box/chat_box_change_notifier.dart';
import 'package:hex_place/views/user_interface/ui_views/chat_window/chat_window_change_notifier.dart';
import 'package:hex_place/views/user_interface/ui_views/friend_window/friend_window_change_notifier.dart';
import 'package:hex_place/views/user_interface/ui_views/profile_box/profile_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';


class ProfileOverview extends StatefulWidget {

  final HexPlace game;

  const ProfileOverview({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  ProfileOverviewState createState() => ProfileOverviewState();
}

class ProfileOverviewState extends State<ProfileOverview> with TickerProviderStateMixin {

  late SelectedTileInfo selectedTileInfo;
  late ProfileChangeNotifier profileChangeNotifier;
  SocketServices socket = SocketServices();
  Settings settings = Settings();

  late AnimationController _controller;
  int levelClock = 0;
  bool canChangeTiles = true;

  int friendOverviewState = 0;
  int messageOverviewState = 0;

  bool unansweredFriendRequests = false;
  bool unreadMessages = false;

  final NavigationService _navigationService = locator<NavigationService>();

  @override
  void initState() {
    BackButtonInterceptor.add(myInterceptor);
    super.initState();
    selectedTileInfo = SelectedTileInfo();
    selectedTileInfo.addListener(selectedTileListener);

    profileChangeNotifier = ProfileChangeNotifier();
    profileChangeNotifier.addListener(profileChangeListener);
    settings.addListener(profileChangeListener);

    socket.addListener(socketListener);

    _controller = AnimationController(
        vsync: this,
        duration: Duration(
            seconds:
            levelClock)
    );
    _controller.forward();
    updateTimeLock();
  }

  @override
  void dispose() {
    _controller.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    ClearUI clearUI = ClearUI();
    if (clearUI.isUiElementVisible()) {
      clearUI.clearUserInterfaces();
      return true;
    } else {
      // Ask to logout?
      showAlertDialog(context);
      return false;
    }
  }

  // Only show logout dialog when user presses back button
  showAlertDialog(BuildContext context) {  // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: const Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
      child: const Text("Logout"),
      onPressed:  () {
        Navigator.pop(context);
        logoutUser(Settings(), _navigationService);
      },
    );  // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Leave?"),
      content: const Text("Do you want to logout of Hex Place?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  socketListener() {
    if (mounted) {
      updateTimeLock();
      friendOverviewState = 0;
      messageOverviewState = 0;
      setState(() {});
    }
  }

  updateTimeLock() {
    if (settings.getUser() != null) {
      DateTime timeLock = settings.getUser()!.getTileLock();
      if (timeLock.isAfter(DateTime.now())) {
        levelClock = timeLock.difference(DateTime.now()).inSeconds;
        _controller = AnimationController(
            vsync: this,
            duration: Duration(
                seconds:
                levelClock)
        );
        _controller.forward();
        _controller.addStatusListener((status) {
          if(status == AnimationStatus.completed) {
            setState(() {
              canChangeTiles = true;
            });
          }
        });
        canChangeTiles = false;
      }
    }
  }

  profileChangeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  selectedTileListener() {
    if (mounted) {
      setState(() {});
    }
  }

  goToProfile() {
    if (!profileChangeNotifier.getProfileVisible()) {
      profileChangeNotifier.setProfileVisible(true);
    } else if (profileChangeNotifier.getProfileVisible()) {
      profileChangeNotifier.setProfileVisible(false);
    }
  }

  openFriendWindow() {
    FriendWindowChangeNotifier().setFriendWindowVisible(true);
  }

  Color overviewColour(int state) {
    if (state == 0) {
      return Colors.orange;
    } else if (state == 1) {
      return Colors.orangeAccent;
    } else {
      return Colors.orange.shade800;
    }
  }

  Widget tileTimeInformation() {
    if (canChangeTiles) {
      return Container();
    } else {
      return Countdown(
        key: UniqueKey(),
        animation: StepTween(
          begin: levelClock,
          end: 0,
        ).animate(_controller),
      );
    }
  }

  Widget getAvatar(double avatarSize) {
    return Container(
      child: settings.getAvatar() != null ? avatarBox(avatarSize, avatarSize, settings.getAvatar()!)
          : Image.asset(
        "assets/images/default_avatar.png",
        width: avatarSize,
        height: avatarSize,
      )
    );
  }

  Widget profileWidget(double profileOverviewWidth, double profileOverviewHeight) {
    return Row(
      children: [
        Container(
          width: profileOverviewWidth,
          height: profileOverviewHeight,
          color: Colors.black38,
          child: GestureDetector(
            onTap: () {
              goToProfile();
            },
            child: Row(
              children: [
                getAvatar(profileOverviewHeight),
                SizedBox(
                  width: profileOverviewWidth - profileOverviewHeight,
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: settings.getUser() != null ? settings.getUser()!.getUserName() : "",
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]
    );
  }

  showChatWindow() {
    ChatBoxChangeNotifier().setChatBoxVisible(false);
    ChatWindowChangeNotifier().setChatWindowVisible(true);
  }

  Widget profileOverviewNormal(double profileOverviewWidth, double profileOverviewHeight, double fontSize) {
    double profileAvatarHeight = 100;
    return SizedBox(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).viewPadding.top),
          profileWidget(profileOverviewWidth, profileAvatarHeight),
        ]
      ),
    );
  }

  Widget profileOverviewMobile(double profileOverviewWidth, double profileOverviewHeight, double fontSize) {
    double statusBarPadding = MediaQuery.of(context).viewPadding.top;
    return Container(
      child: Column(
        children: [
          SizedBox(height: statusBarPadding),
          Row(
            children: [
              Column(
                children: [
                  profileWidget(profileOverviewWidth, profileOverviewHeight),
                ],
              ),
              const SizedBox(width: 5),
            ]
          ),
        ]
      ),
    );
  }

  bool normalMode = true;
  Widget tileBoxWidget() {
    double profileOverviewWidth = 350;
    double fontSize = 16;
    // We use the total height to hide the chatbox below
    // In NormalMode the height has the 2 buttons and some padding added.
    double statusBarPadding = MediaQuery.of(context).viewPadding.top;
    double profileOverviewHeight = 100;
    normalMode = true;
    if (MediaQuery.of(context).size.width <= 800) {
      profileOverviewWidth = MediaQuery.of(context).size.width/2;
      profileOverviewWidth += 5;
      profileOverviewHeight = 50;
      normalMode = false;
    }

    return SingleChildScrollView(
      child: SizedBox(
        width: profileOverviewWidth,
        height: profileOverviewHeight + statusBarPadding,
        child: Align(
          alignment: FractionalOffset.topLeft,
          child: normalMode
              ? profileOverviewNormal(profileOverviewWidth, profileOverviewHeight, fontSize)
              : profileOverviewMobile(profileOverviewWidth-5, profileOverviewHeight, fontSize)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return tileBoxWidget();
  }
}

