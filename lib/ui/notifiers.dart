import 'package:flutter/widgets.dart';

class AppLocaleNotifier extends ValueNotifier<Locale>{
  AppLocaleNotifier(Locale locale): super(locale);

  setLocale(Locale locale){
    value = locale;
    notifyListeners();
  }
}

class ProgressIndicatorController extends ValueNotifier<bool> {
  ProgressIndicatorController() : super(false);

  void show() {
    value = true;
    notifyListeners();
  }

  void hide() {
    value = false;
    notifyListeners();
  }
}

class PopupController extends ValueNotifier<List<Widget>> {
  PopupController() : super([]);

  addItem(Widget widget) {
    value.add(widget);
    notifyListeners();
  }

  addItemFor(Widget widget, Duration duration) async {
    addItem(widget);
    await Future.delayed(duration, () => removeItem(widget));
  }

  removeItem(Widget widget) {
    value.remove(widget);
    notifyListeners();
  }

  clear() {
    value.clear();
    notifyListeners();
  }
}