import 'package:flutter/material.dart';


class ZoomWidgetChangeNotifier extends ChangeNotifier {

  bool showZoomWidget = false;
  double zoomValue = 1;

  static final ZoomWidgetChangeNotifier _instance = ZoomWidgetChangeNotifier._internal();

  ZoomWidgetChangeNotifier._internal();

  factory ZoomWidgetChangeNotifier() {
    return _instance;
  }

  setZoomWidgetVisible(bool visible) {
    showZoomWidget = visible;
    notifyListeners();
  }

  getZoomWidgetVisible() {
    return showZoomWidget;
  }

  setZoomValue(double newValue) {
    zoomValue = newValue;
  }

  getZoomValue() {
    return zoomValue;
  }

  notify() {
    notifyListeners();
  }
}
