import 'dart:convert';
import 'dart:typed_data';
import 'package:hex_place/views/user_interface/ui_util/crop/controller.dart';
import 'package:hex_place/views/user_interface/ui_util/crop/crop.dart';
import 'package:image/image.dart' as image;
import 'package:hex_place/hex_place.dart';
import 'package:hex_place/services/auth_service_setting.dart';
import 'package:hex_place/services/settings.dart';
import 'package:hex_place/util/render_objects.dart';
import 'package:hex_place/util/util.dart';
import 'package:hex_place/views/user_interface/ui_views/change_avatar_box/change_avatar_change_notifier.dart';
import 'package:hex_place/views/user_interface/ui_views/loading_box/loading_box_change_notifier.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';


class ChangeAvatarBox extends StatefulWidget {

  final HexPlace game;

  const ChangeAvatarBox({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  ChangeAvatarBoxState createState() => ChangeAvatarBoxState();
}

class ChangeAvatarBoxState extends State<ChangeAvatarBox> with TickerProviderStateMixin {

  late ChangeAvatarChangeNotifier changeAvatarChangeNotifier;

  bool showChangeAvatar = false;

  bool isDefault = true;

  CropController cropController = CropController();

  Uint8List imageMain = Uint8List.fromList([]);
  Uint8List imageCrop = Uint8List.fromList([]);

  @override
  void initState() {
    changeAvatarChangeNotifier = ChangeAvatarChangeNotifier();
    changeAvatarChangeNotifier.addListener(changeAvatarChangeListener);
    super.initState();
  }

  changeAvatarChangeListener() {
    if (mounted) {
      if (!showChangeAvatar && changeAvatarChangeNotifier.getChangeAvatarVisible()) {
        // set the correct image
        setState(() {
          showChangeAvatar = true;
          imageMain = Settings().getAvatar()!;
          imageCrop = Settings().getAvatar()!;
        });
        // And check if it's the default avatar
        AuthServiceSetting().getIsAvatarDefault().then((result) {
          if (result != isDefault) {
            setState(() {
              isDefault = result;
            });
          }
        });
      }
      if (showChangeAvatar && !changeAvatarChangeNotifier.getChangeAvatarVisible()) {
        setState(() {
          showChangeAvatar = false;
        });
      }
    }
  }


  imageLoaded() async {
    LoadingBoxChangeNotifier loadingBoxChangeNotifier = LoadingBoxChangeNotifier();
    // Set the loading screen. It will be removed when cropping status is done
    loadingBoxChangeNotifier.setWithBlackout(true);
    loadingBoxChangeNotifier.setLoadingBoxVisible(true);
    FilePickerResult? picked = await FilePicker.platform.pickFiles(withData: true);

    if (picked != null) {
      String? extension = picked.files.first.extension;
      if (extension != "png" && extension != "jpg" && extension != "jpeg") {
        showToastMessage("Please pick a png or jpeg file");
        setState(() {
          loadingBoxChangeNotifier.setLoadingBoxVisible(false);
        });
      } else {
        setState(() {
          imageCrop = picked.files.first.bytes!;
          imageMain = picked.files.first.bytes!;
          cropController.image = imageMain;
        });
      }
    } else {
      setState(() {
        loadingBoxChangeNotifier.setLoadingBoxVisible(false);
      });
    }
  }

  goBack() {
    setState(() {
      changeAvatarChangeNotifier.setChangeAvatarVisible(false);
    });
  }

  saveNewAvatar() {
    setState(() {
      LoadingBoxChangeNotifier loadingBoxChangeNotifier = LoadingBoxChangeNotifier();
      loadingBoxChangeNotifier.setWithBlackout(true);
      loadingBoxChangeNotifier.setLoadingBoxVisible(true);
    });
    // Again a very slight delay, too get the loading screen visible.
    Future.delayed(const Duration(milliseconds: 50), () {
      // first downsize to 512 x 512
      // and create another even more downsized small variant.
      // This cropped version should be a perfect square
      image.Image regular = image.decodePng(imageCrop)!;
      int width = regular.width;
      if (width > 512) {
        regular = image.copyResize(regular, width: 512);
      }
      image.Image small = image.copyResize(regular, width: 64);
      Uint8List regularImage = image.encodePng(regular);
      Uint8List smallImage = image.encodePng(small);
      String newAvatarRegular = base64Encode(regularImage);
      String newAvatarSmall = base64Encode(smallImage);
      AuthServiceSetting().changeAvatar(newAvatarRegular, newAvatarSmall).then((response) {
        Uint8List changedAvatar = base64Decode(newAvatarRegular);
        LoadingBoxChangeNotifier().setLoadingBoxVisible(false);
        if (response.getResult()) {
          Settings settings = Settings();
          if (settings.getUser() != null) {
            settings.setAvatar(changedAvatar);
            settings.notify();
            goBack();
          }
        } else {
          showToastMessage(response.getMessage());
        }
      });
    });
  }

  resetDefaultImage() {
    setState(() {
      LoadingBoxChangeNotifier loadingBoxChangeNotifier = LoadingBoxChangeNotifier();
      loadingBoxChangeNotifier.setWithBlackout(true);
      loadingBoxChangeNotifier.setLoadingBoxVisible(true);
    });
    // Again a very slight delay, too get the loading screen visible.
    Future.delayed(const Duration(milliseconds: 50), () {
      // String newAvatar = base64Encode(imageCrop);
      AuthServiceSetting().resetAvatar().then((response) {
        LoadingBoxChangeNotifier().setLoadingBoxVisible(false);
        if (response.getResult()) {
          setState(() {
            Settings settings = Settings();
            settings.setAvatar(base64Decode(response.getMessage().replaceAll("\n", "")));
            settings.notify();
            goBack();
          });
        } else {
          showToastMessage(response.getMessage());
        }
      });
    });
  }

  Widget changeAvatarNormal(double width, double fontSize) {
    double sidePadding = 20;
    double headerWidth = width - 2 * sidePadding;
    double cropWidth = (width - 2 * sidePadding) / 2;
    double buttonWidth = cropWidth - 50;
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(left: sidePadding, right: sidePadding),
        width: width,
        child: Column(
          children: [
            changeAvatarHeader(headerWidth, 50, fontSize),
            Row(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 20),
                    cropWidget(cropWidth),
                    const SizedBox(height: 20),
                    uploadNewImageButton(buttonWidth, 50, fontSize),
                    const SizedBox(height: 20),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 20,
                      child: Text(
                        "Result:",
                        style: TextStyle(
                            fontSize: fontSize,
                            color: Colors.white
                        ),
                      )
                    ),
                    avatarBox(
                        cropWidth,
                        cropWidth,
                        imageCrop
                    ),
                    const SizedBox(height: 20),
                    saveImageButton(buttonWidth, 50, fontSize),
                    const SizedBox(height: 20),
                    resetDefaultImageButton(buttonWidth, 50, fontSize),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget cropWidget(double cropHeight) {
    return SizedBox(
      width: cropHeight,
      height: cropHeight,
      child: Crop(
        image: imageMain,
        controller: cropController,
        hexCrop: true,
        onStatusChanged: (status) {
          if (status == CropStatus.cropping || status == CropStatus.loading) {
            LoadingBoxChangeNotifier loadingBoxChangeNotifier = LoadingBoxChangeNotifier();
            loadingBoxChangeNotifier.setWithBlackout(true);
            loadingBoxChangeNotifier.setLoadingBoxVisible(true);
          } else if (status == CropStatus.ready) {
            LoadingBoxChangeNotifier().setLoadingBoxVisible(false);
          }
        },
        onResize: (imageData) {
          showToastMessage("Image too large, resizing...");
          setState(() {
            imageCrop = imageData;
            imageMain = imageData;
            cropController.image = imageData;
          });
        },
        onCropped: (image) {
          setState(() {
            imageCrop = image;
          });
        },
      ),
    );
  }

  Widget uploadNewImageButton(double buttonWidth, double buttonHeight, double fontSize) {
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        style: buttonStyle(false, Colors.blue),
        child: Container(
            alignment: Alignment.center,
            child: Text(
                'Upload a new image',
                style: simpleTextStyle(fontSize)
            )
        ),
        onPressed: () async {
          imageLoaded();
        },
      ),
    );
  }

  Widget resetDefaultImageButton(double buttonWidth, double buttonHeight, double fontSize) {
    return isDefault == false ? SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          resetDefaultImage();
        },
        style: buttonStyle(false, Colors.blueGrey),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            'reset default image',
            style: simpleTextStyle(fontSize),
          ),
        ),
      ),
    ) : Container();
  }

  Widget saveImageButton(double buttonWidth, double buttonHeight, double fontSize) {
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          saveNewAvatar();
        },
        style: buttonStyle(false, Colors.blue),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            'Save new avatar',
            style: simpleTextStyle(fontSize),
          ),
        ),
      ),
    );
  }

  Widget changeAvatarMobile(double width, double height, double fontSize) {
    double sidePadding = 20;
    double headerHeight = height / 9;
    double buttonWidth = (width - 2 * sidePadding) / 2;
    double cropResultWidth = width/2;
    double avatarHeight = cropResultWidth * 1.125;
    double totalButtonHeight = avatarHeight;
    double buttonHeight = totalButtonHeight / 4;

    return Container(
      margin: EdgeInsets.only(left: sidePadding, right: sidePadding),
      child: Column(
          children: [
            changeAvatarHeader(width, headerHeight, fontSize),
            cropWidget(cropResultWidth),
            SizedBox(
                width: width,
                height: 40,
                child: const Text("Result:")
            ),
            avatarBox(
                cropResultWidth,
                cropResultWidth,
                imageCrop
            ),
            SizedBox(height: buttonHeight/3),
            uploadNewImageButton(buttonWidth, buttonHeight, 16),
            SizedBox(height: buttonHeight/3),
            saveImageButton(buttonWidth, buttonHeight, 16),
            SizedBox(height: buttonHeight/3),
            resetDefaultImageButton(buttonWidth, buttonHeight, 16),
        ]
      ),
    );
  }

  Widget changeAvatarHeader(double headerWidth, double headerHeight, double fontSize) {
    return SizedBox(
      width: headerWidth,
      height: headerHeight,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Text(
                "Change avatar",
                style: simpleTextStyle(fontSize),
              ),
            ),
            IconButton(
                icon: const Icon(Icons.close),
                color: Colors.orangeAccent.shade200,
                tooltip: 'cancel',
                onPressed: () {
                  goBack();
                }
            ),
          ]
      ),
    );
  }

  Widget changeAvatarBox() {
    // normal mode is for desktop, mobile mode is for mobile.
    bool normalMode = true;
    double fontSize = 16;
    double width = 800;
    double height = (MediaQuery.of(context).size.height / 10) * 9;
    // When the width is smaller than this we assume it's mobile.
    if (MediaQuery.of(context).size.width <= 800) {
      width = MediaQuery.of(context).size.width - 50;
      fontSize = 10;
      normalMode = false;
    }

    return Container(
        width: width,
        height: height,
        color: Colors.cyan,
        child: SingleChildScrollView(
        child: normalMode
            ? changeAvatarNormal(width, fontSize)
            : changeAvatarMobile(width, height, fontSize),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: showChangeAvatar ? changeAvatarBox() : Container()
    );
  }
}
