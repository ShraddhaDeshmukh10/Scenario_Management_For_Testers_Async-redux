import 'package:get_it/get_it.dart';
import 'package:scenario_management_tool_for_testers/Services/dataservice.dart';
import 'package:scenario_management_tool_for_testers/Services/imageservices.dart';

GetIt locator = GetIt.instance;

void setupServiceLocator() {
  try {
    locator.registerLazySingleton<DataService>(() => Services());
  } catch (e) {
    print("Error registering service locator: $e");
  }
}
