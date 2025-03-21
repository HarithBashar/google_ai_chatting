import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsClass extends  GetxController {
  GetStorage box = GetStorage();

  double backgroundImageOpacity = .02;

  void changeBackgroundImageOpacity(double opacity, {bool isBackgroundDisabled = false}){
    backgroundImageOpacity = opacity;
    update();
    box.write('isBackgroundDisabled', isBackgroundDisabled);
    if(!isBackgroundDisabled) {
      box.write('backgroundImageOpacity', opacity);
    }
  }





  void loadSettingsFromMemory() {
    backgroundImageOpacity = box.read('isBackgroundDisabled')??false ? 0 : box.read('backgroundImageOpacity') ?? .02;
  }
}