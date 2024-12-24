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
// import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import './screens/leftDrawer.dart';

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
  bool showLayers = false;
  Color color = Colors.pink;
  late String gpsMethod;
  late double gpsUnitsDistance;
  late int gpsUnitsTime;
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
    gpsUnitsDistance = UserPreferences.getDistancePreferences();
    gpsUnitsTime = UserPreferences.getTimePreferences();
    // DisableBatteryOptimization.isBatteryOptimizationDisabled
    //     .then((isBatteryOptimizationDisabled) async {
    //   await handleBatteryOptimization(isBatteryOptimizationDisabled);
    // });
    setState(() {
      showLayers = true;
    });
    super.initState();
  }

  // Future<void> handleBatteryOptimization(
  //     bool? isBatteryOptimizationDisabled) async {
  //   isBatteryOptimizationDisabled ??= false;
  //   if (!isBatteryOptimizationDisabled) {
  //     await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
  //   }
  // }

  void toggleAppBar() {
    print('......................toggle appbar');
    // setState(() {
    //   fullScreen = !fullScreen;
    // });
  }

  void handleSettings(var settings) async {
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
          numSatelites, accuracy, speed, heading, provider, visible, color);
    }

    if (gpsMethod != gpsmethod ||
        gpsUnitsDistance != gpsunitsdistance ||
        gpsUnitsTime != gpsunitstime) {
      await UserPreferences.setGpsMethod(gpsmethod);
      if (gpsmethod == 'distance') {
        await UserPreferences.setDistancePreferences(gpsunitsdistance);
      } else {
        await UserPreferences.setTimePreferences(gpsunitstime);
      }

      double distanceFilter = 0;
      int interval = 1000;

      if (gpsMethod == 'distance') {
        distanceFilter = gpsunitsdistance;
      } else {
        interval = gpsunitstime * 1000;
      }

      _mainController.setGpsSettings!(
        gpsmethod,
        distanceFilter,
        interval,
      );
    }

    numSatelites = numSat;
    accuracy = Ac;
    speed = Sp;
    heading = He;
    provider = Pro;
    visible = vis;
    color = col;
    gpsMethod = gpsmethod;
    gpsUnitsDistance = gpsunitsdistance;
    gpsUnitsTime = gpsunitstime;

    _mainController.centerMap!(_mainController.getLastLocation!());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        endDrawerEnableOpenDragGesture: false,
        onEndDrawerChanged: (isOpen) {
          setState(() {});
        },
        drawerScrimColor: Colors.transparent,
        endDrawer: Drawer(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: SizedBox(
                width: 200,
                child: Container(
                    color: Theme.of(context).canvasColor,
                    child: LeffDrawer(controller: _mainController))),
          ),
        ),
        appBar: AppBar(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          title: Text(AppLocalizations.of(context)!.appTitle),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Builder(
                  builder: (context) => IconButton(
                    tooltip: AppLocalizations.of(context)!.baseLayer,
                    icon: Icon(Icons.layers_rounded),
                    color: Scaffold.of(context).isEndDrawerOpen
                        ? primaryColor
                        : Colors.white,
                    onPressed: () {
                      debugPrint('pressed');
                      setState(() {
                        Scaffold.of(context).openEndDrawer();
                      });
                    },
                  ),
                ),
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
                              gpsUnitsDistance: gpsUnitsDistance,
                              gpsUnitsTime: gpsUnitsTime),
                        ));
                    if (result != null) {
                      handleSettings(result);
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
