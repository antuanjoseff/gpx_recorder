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
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:double_tap_to_exit/double_tap_to_exit.dart';

void main() async {
  // await _checkPermission();
  WidgetsFlutterBinding.ensureInitialized();
  await UserPreferences.init();
  // await _checkPermission();
  runApp(const MyApp());
}

Future<void> _checkPermission() async {
  bool? hasPermission = false;
  final gps = Gps();

  bool enabled = await gps.checkService();
  if (enabled) {
    await gps.checkPermission();
  }
  return;
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

  bool fullScreen = false;
  late bool numSatelites;
  late bool accuracy;
  late bool speed;
  late bool heading;
  late bool provider;
  bool visible = true;
  Color color = Colors.pink;
  late String gpsMethod;
  late double distancePreferences;
  late int timePreferences;
  double gpsUnits = -1;

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
    gpsMethod = UserPreferences.getGpsMethod();
    distancePreferences = UserPreferences.getDistancePreferences();
    timePreferences = UserPreferences.getTimePreferences();
    DisableBatteryOptimization.isBatteryOptimizationDisabled
        .then((isBatteryOptimizationDisabled) async {
      await handleBatteryOptimization(isBatteryOptimizationDisabled);
    });
    super.initState();
  }

  Future<void> handleBatteryOptimization(
      bool? isBatteryOptimizationDisabled) async {
    isBatteryOptimizationDisabled ??= false;
    if (!isBatteryOptimizationDisabled) {
      await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    }
  }

  void toggleAppBar() {
    print('......................toggle appbar');
    // setState(() {
    //   fullScreen = !fullScreen;
    // });
  }

  // When user exists the settings tabs, some updates are required
  void updateSettings(var settings) async {
    var (
      bool Sp,
      bool He,
      bool numSat,
      bool Ac,
      bool Pro,
      bool vis,
      Color col,
      String gpsmethod,
      double gpsunitsdistance,
      int gpsunitstime
    ) = settings;

    bool gpxEdit = false;

    if (accuracy != Ac) {
      await UserPreferences.setAccuracy(Ac);
      gpxEdit = true;
    }

    if (speed != Sp) {
      await UserPreferences.setSpeed(Sp);
      gpxEdit = true;
    }

    if (heading != He) {
      await UserPreferences.setHeading(He);
      gpxEdit = true;
    }

    if (provider != Pro) {
      await UserPreferences.setProvider(Pro);
      gpxEdit = true;
    }

    if (visible != vis) {
      await UserPreferences.setTrackVisible(vis);
      gpxEdit = true;
    }

    if (color != col) {
      UserPreferences.setTrackColor(col);
      gpxEdit = true;
    }

    if (gpxEdit) {
      _mainController.setTrackPreferences!(
          numSatelites, accuracy, speed, heading, provider, vis, col);
    }

    await UserPreferences.setGpsMethod(gpsmethod);
    await UserPreferences.setDistancePreferences(gpsunitsdistance);
    await UserPreferences.setTimePreferences(gpsunitstime);

    double distanceFilter = 0;
    int interval = 1;

    if (gpsmethod == 'distance') {
      distanceFilter = gpsunitsdistance;
      interval = 0;
    } else {
      distanceFilter = 0;
      interval = gpsunitstime;
    }

    _mainController.setGpsSettings!(
      gpsmethod,
      distanceFilter,
      interval,
    );

    numSatelites = numSat;
    accuracy = Ac;
    speed = Sp;
    heading = He;
    provider = Pro;
    visible = vis;
    color = col;
    gpsMethod = gpsmethod;
    distancePreferences = gpsunitsdistance;
    timePreferences = gpsunitstime;

    _mainController.centerMap!(_mainController.getLastLocation!());
  }

  @override
  Widget build(BuildContext context) {
    return DoubleTapToExit(
      snackBar: SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: primaryColor,
        margin: const EdgeInsets.only(left: 50, right: 50, bottom: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),

        //this will add margin to all side
        behavior: SnackBarBehavior.floating,
        content: Text(AppLocalizations.of(context)!.tapAgainToExit,
            textAlign: TextAlign.center),
      ),
      child: Scaffold(
          appBar: AppBar(
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
                                color: color,
                                gpsMethod: gpsMethod,
                                gpsUnitsDistance: distancePreferences,
                                gpsUnitsTime: timePreferences),
                          ));

                      if (result != null) {
                        updateSettings(result);
                      }
                    },
                  )
                ],
              )
            ],
          ),
          body: MapWidget(mainController: _mainController)),
    );
  }
}
