import 'package:flutter/material.dart';
// import 'utils/user_simple_preferences.dart';
import './screens/settingsPage.dart';
import './screens/map.dart';
import './screens/tabSettings.dart';
import 'controllers/main.dart';
import './classes/user_preferences.dart';
import './classes/vars.dart';
import './classes/gps.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  // await _checkPermission();
  WidgetsFlutterBinding.ensureInitialized();
  await UserPreferences.init();
  // await _checkPermission();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ca'), // catalan
        Locale('es'), // Spanish
        Locale('en'), // English
      ],
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MainController _mainController = MainController();
  bool recording = false;
  int milliseconds = 300;
  bool showPauseButton = false;
  bool showResumeOrStopButtons = false;
  bool isPaused = false;
  bool isStopped = false;
  bool isResumed = false;
  bool mapCentered = true;

  bool fullScreen = false;
  late bool numSatelites;
  late bool accuracy;
  late bool speed;
  late bool heading;
  late bool provider;
  bool visible = true;
  Color color = Colors.pink;

  ButtonStyle customStyleButton = ElevatedButton.styleFrom(
      minimumSize: Size.zero, // Set this
      padding: EdgeInsets.all(15), // and this
      backgroundColor: lightColor);

  @override
  void initState() {
    numSatelites = UserPreferences.getNumSatelites();
    accuracy = UserPreferences.getAccuracy();
    speed = UserPreferences.getSpeed();
    heading = UserPreferences.getHeading();
    provider = UserPreferences.getProvider();
    super.initState();
  }

  void toggleAppBar() {
    print('......................toggle appbar');
    // setState(() {
    //   fullScreen = !fullScreen;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // toolbarHeight: !fullScreen ? 40 : 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          title: Text(AppLocalizations.of(context)!.appTitle),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: thirthColor,
                  ),
                  onPressed: () async {
                    var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TabSettings(
                              speed: speed,
                              heading: heading,
                              numSatelites: numSatelites,
                              accuracy: accuracy,
                              provider: provider,
                              visible: visible,
                              color: color),
                        ));
                    if (result != null) {
                      var (
                        bool Sp,
                        bool He,
                        bool numSat,
                        bool Ac,
                        bool Pro,
                        bool vis,
                        Color col
                      ) = result;
                      numSatelites = numSat;
                      accuracy = Ac;
                      speed = Sp;
                      heading = He;
                      provider = Pro;
                      visible = vis;
                      color = col;
                      _mainController.setTrackPreferences!(numSatelites,
                          accuracy, speed, heading, provider, visible, color);
                    }
                  },
                )
              ],
            )
          ],
        ),
        body: MapWidget(mainController: _mainController));
  }
}
