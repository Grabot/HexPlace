import 'package:hex_place/hex_place.dart';
import 'package:hex_place/views/user_interface/ui_views/loading_box/loading_box_change_notifier.dart';
import 'package:flutter/material.dart';


class LoadingBox extends StatefulWidget {

  final HexPlace game;

  const LoadingBox({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  LoadingBoxState createState() => LoadingBoxState();
}

class LoadingBoxState extends State<LoadingBox> {

  final FocusNode _focusLoadingBox = FocusNode();
  bool showLoading = false;

  late LoadingBoxChangeNotifier loadingBoxChangeNotifier;

  @override
  void initState() {
    loadingBoxChangeNotifier = LoadingBoxChangeNotifier();
    loadingBoxChangeNotifier.addListener(loadingBoxChangeListener);

    _focusLoadingBox.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadingBoxChangeListener() {
    if (mounted) {
      if (!showLoading && loadingBoxChangeNotifier.getLoadingBoxVisible()) {
        setState(() {
          showLoading = true;
        });
      }
      if (showLoading && !loadingBoxChangeNotifier.getLoadingBoxVisible()) {
        setState(() {
          showLoading = false;
        });
      }
    }
  }

  void _onFocusChange() {
    widget.game.windowFocus(_focusLoadingBox.hasFocus);
  }

  Widget loadingBox(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: loadingBoxChangeNotifier.getWithBlackout()
          ? Colors.black.withValues(alpha: 0.7)
          : Colors.black.withValues(alpha: 0),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: showLoading ? loadingBox(context) : Container()
    );
  }
}
