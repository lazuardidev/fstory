import 'package:flutter/material.dart';
import 'package:{{appName.snakeCase()}}/core/routes/router_delegate.dart';
import 'package:{{appName.snakeCase()}}/presentation/providers/auth_notifier.dart';
import 'package:{{appName.snakeCase()}}/presentation/providers/story_notifier.dart';
import 'package:provider/provider.dart';
import 'package:{{appName.snakeCase()}}/injection.dart' as di;
import 'injection.dart';
import 'core/shared_preferences/user_shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await UserSharedPreferences.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MyRouterDelegate myRouterDelegate;
  String? selectedStory;

  @override
  void initState() {
    super.initState();
    myRouterDelegate = MyRouterDelegate();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<StoryNotifier>(
            create: (ctx) => StoryNotifier(repository: locator())),
        ChangeNotifierProvider<AuthNotifier>(
            create: (ctx) => AuthNotifier(repository: locator()))
      ],
      child: MaterialApp(
          title: 'FStory',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
            useMaterial3: true,
          ),
          home: Router(
            routerDelegate: myRouterDelegate,
            backButtonDispatcher: RootBackButtonDispatcher(),
          )),
    );
  }
}
