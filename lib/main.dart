import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:scenario_management_tool_for_testers/Resources/route.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';
import 'package:scenario_management_tool_for_testers/view/screens/change_page/change_history_connector.dart';
import 'package:scenario_management_tool_for_testers/view/screens/dashboard_page/dashboard_connector.dart';
import 'package:scenario_management_tool_for_testers/view/screens/scenario_page/scenario_connector.dart';
import 'package:scenario_management_tool_for_testers/constants/locator.dart';
import 'package:scenario_management_tool_for_testers/view/screens/login.dart';
import 'package:scenario_management_tool_for_testers/view/screens/register_screen.dart';
import 'package:scenario_management_tool_for_testers/view/screens/splash.dart';
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
                return MaterialPageRoute(builder: (_) => const LoginPage());
              case Routes.register:
                return MaterialPageRoute(builder: (_) => const RegisterPage());
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
                return MaterialPageRoute(builder: (_) => const LoginPage());
            }
          }),
    );
  }
}
