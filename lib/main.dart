import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:scenario_management_tool_for_testers/Resources/route.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';
import 'package:scenario_management_tool_for_testers/constants/enum_role.dart';
import 'package:scenario_management_tool_for_testers/screens/change_screen/change_history_connector.dart';
import 'package:scenario_management_tool_for_testers/screens/dashboard_screen/dashboard_connector.dart';
import 'package:scenario_management_tool_for_testers/screens/login_screen/login_connector.dart';
import 'package:scenario_management_tool_for_testers/screens/register_screen/register_connector.dart';
import 'package:scenario_management_tool_for_testers/screens/scenario_screen/scenario_connector.dart';
import 'package:scenario_management_tool_for_testers/constants/locator.dart';
import 'package:scenario_management_tool_for_testers/screens/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase/firebase_options.dart';

final store = Store<AppState>(initialState: AppState.initialState());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupServiceLocator();
  final appState = store.state;
  runApp(MyApp(appState: appState));
}

class MyApp extends StatelessWidget {
  final AppState appState;

  const MyApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    String? userRole = appState.designation;
    Role currentRole = Role.fromString(userRole ?? 'undefined');

    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: currentRole.roleColor,
          ),
          primaryColor: currentRole.roleColor,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.splash,
        onGenerateRoute: (settings) {
          final args = (settings.arguments ?? <String, dynamic>{})
              as Map<String, dynamic>;
          switch (settings.name) {
            case Routes.splash:
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            case Routes.login:
              return MaterialPageRoute(builder: (_) => const LoginConnector());
            case Routes.register:
              return MaterialPageRoute(
                  builder: (_) => const RegisterConnector());
            case Routes.dashboard:
              return MaterialPageRoute(
                builder: (_) => const DashboardConnector(),
              );
            case Routes.editpagedetail:
              return MaterialPageRoute(
                builder: (_) => ChangeHistoryConnector(
                  scenarioId: args['scenarioId'],
                  roleColor: args['roleColor'],
                  designation: args['designation'],
                ),
              );
            case Routes.scenariodetailconnector:
              return MaterialPageRoute(
                builder: (_) => ScenarioDetailConnector(
                  scenario: args['scenario'],
                  roleColor: args['roleColor'],
                  designation: args['designation'] ?? '',
                ),
              );

            default:
              return MaterialPageRoute(builder: (_) => const LoginConnector());
          }
        },
      ),
    );
  }
}
