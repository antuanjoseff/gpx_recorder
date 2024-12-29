import 'package:flutter/material.dart';
// import 'utils/user_simple_preferences.dart';
import './screens/settingsPage.dart';
import './screens/map.dart';
import './screens/tabSettings.dart';
import 'controllers/map.dart';
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
  MapController _mainController = MapController();
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
  late Color color;
  late int width;
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
    color = UserPreferences.getTrackColor();
    width = UserPreferences.getTrackWidth();
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
      bool newSpeed,
      bool newHeading,
      bool newNumSat,
      bool newAccuracy,
      bool newProvider,
      bool newVisibility,
      Color newColor,
      int newWidth,
      String newGpsMethod,
      double newGpsUnitsDistance,
      int newGpsUnitsTime
    ) = settings;

    bool gpxEdit = false;

    if (accuracy != newAccuracy) {
      await UserPreferences.setAccuracy(newAccuracy);
      gpxEdit = true;
    }

    if (speed != newSpeed) {
      await UserPreferences.setSpeed(newSpeed);
      gpxEdit = true;
    }

    if (heading != newHeading) {
      await UserPreferences.setHeading(newHeading);
      gpxEdit = true;
    }

    if (provider != newProvider) {
      await UserPreferences.setProvider(newProvider);
      gpxEdit = true;
    }

    if (visible != newVisibility) {
      await UserPreferences.setTrackVisible(newVisibility);
      gpxEdit = true;
    }

    if (color != newColor) {
      UserPreferences.setTrackColor(newColor);
      gpxEdit = true;
    }

    if (width != newWidth) {
      UserPreferences.setTrackWidth(newWidth);
      gpxEdit = true;
    }

    if (gpxEdit) {
      _mainController.setTrackPreferences!(numSatelites, accuracy, speed,
          heading, provider, visible, newColor, newWidth);
    }

    // if (gpsMethod != newGpsMethod ||
    //     gpsUnitsDistance != newGpsUnitsDistance ||
    //     gpsUnitsTime != newGpsUnitsTime) {
    //   await UserPreferences.setGpsMethod(newGpsMethod);
    //   if (newGpsMethod == 'distance') {
    //     await UserPreferences.setDistancePreferences(newGpsUnitsDistance);
    //   } else {
    //     await UserPreferences.setTimePreferences(newGpsUnitsTime);
    //   }

    //   double distanceFilter = 0;
    //   int interval = 1;

    //   if (gpsMethod == 'distance') {
    //     distanceFilter = newGpsUnitsDistance;
    //   } else {
    //     interval = newGpsUnitsTime;
    //   }

    //   _mainController.setGpsSettings!(
    //     newGpsMethod,
    //     distanceFilter,
    //     interval,
    //   );
    // }

    numSatelites = newNumSat;
    accuracy = newAccuracy;
    speed = newSpeed;
    heading = newHeading;
    provider = newProvider;
    visible = newVisibility;
    color = newColor;
    width = newWidth;
    gpsMethod = newGpsMethod;
    gpsUnitsDistance = newGpsUnitsDistance;
    gpsUnitsTime = newGpsUnitsTime;

    _mainController.centerMap!(_mainController.getLastLocation!());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawerEnableOpenDragGesture: false,
        onDrawerChanged: (isOpen) {
          setState(() {});
        },
        drawerScrimColor: Colors.transparent,
        drawer: Drawer(
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
          automaticallyImplyLeading:
              false, // this will hide Drawer hamburger icon
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          title: Text(AppLocalizations.of(context)!.appTitle),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Builder(
                  builder: (context) => CircleAvatar(
                    radius: 27,
                    backgroundColor: primaryColor,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Scaffold.of(context).isDrawerOpen
                          ? primaryColor
                          : Colors.white,
                      child: IconButton(
                        tooltip: AppLocalizations.of(context)!.baseLayer,
                        icon: Icon(Icons.layers_rounded),
                        color: Scaffold.of(context).isDrawerOpen
                            ? Colors.white
                            : primaryColor,
                        onPressed: () {
                          setState(() {
                            Scaffold.of(context).openDrawer();
                          });
                        },
                      ),
                    ),
                  ),
                ),
                CircleAvatar(
                    radius: 27,
                    backgroundColor: primaryColor,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: primaryColor,
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
                                    width: width,
                                    gpsMethod: gpsMethod,
                                    gpsUnitsDistance: gpsUnitsDistance,
                                    gpsUnitsTime: gpsUnitsTime,
                                    mapController: _mainController),
                              ));
                          if (result != null) {
                            handleSettings(result);
                          }
                        },
                      ),
                    ))
              ],
            )
          ],
        ),
        body: MapWidget(mainController: _mainController));
  }
}
