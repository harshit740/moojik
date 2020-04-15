
import 'package:moojik/src/services/AudioFun.dart';
import 'package:moojik/src/services/BaseService.dart';
import 'package:get_it/get_it.dart';


GetIt locator = GetIt.instance;

setupServiceLocator() {
    locator.registerSingleton<BaseService>(AudioFun());
}