import 'dart:math';
import 'package:hex_place/constants/global.dart';


List<int> getTileFromPos(double mouseX, double mouseY, int rotation) {
  double qDetailed = 0;
  double rDetailed = 0;
  double sDetailed = 0;

  if (rotation == 0) {
    mouseY = mouseY * -1;
  }
  if (rotation == 1) {
    double mouseXTemp = mouseX;
    mouseX = mouseY;
    mouseY = -mouseXTemp;
    mouseY = mouseY * -1;
  } else if (rotation == 2) {
    mouseX = mouseX * -1;
    // Also mouseY should be inverted, but than it should be inverted again.
  } else if (rotation == 3) {
    double mouseXTemp = mouseX;
    mouseX = mouseY;
    mouseY = mouseXTemp;
  }

  double xTranslate = (2 / 3 * mouseX);
  qDetailed = xTranslate / xSize;
  double yTranslate1 = (-1 / 3 * mouseX);
  // We need to adjust by 1 so minus the ySize
  double yTranslate2 = (sqrt(3) / 3 * mouseY);
  rDetailed = (yTranslate1 / xSize) + (yTranslate2 / ySize);
  sDetailed = -qDetailed - rDetailed;

  int q = qDetailed.round();
  int r = rDetailed.round();
  int s = sDetailed.round();

  double qDiff = (q - qDetailed).abs();
  double rDiff = (r - rDetailed).abs();
  double sDiff = (s - sDetailed).abs();

  if (qDiff > rDiff && qDiff > sDiff) {
    q = -r - s;
  } else if (rDiff > sDiff) {
    r = -q - s;
  } else {
    s = -q - r;
  }

  return [q, r];
}
