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
import '../controllers/gpx.dart';
import '../controllers/track.dart';
import '../controllers/gps.dart';

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
  late GpxController gpxController;
  late TrackController trackController;
  late GpsController gpsController;

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
  late double unitsDistance;
  late int unitsTime;
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

    gpxController = GpxController(
        numSatelites: numSatelites,
        accuracy: accuracy,
        speed: speed,
        heading: heading,
        provider: provider);

    gpsMethod = UserPreferences.getGpsMethod();
    unitsDistance = UserPreferences.getDistancePreferences();
    unitsTime = UserPreferences.getTimePreferences();

    gpsController = GpsController(
      method: gpsMethod,
      unitsDistance: unitsDistance,
      unitsTime: unitsTime,
    );

    visible = UserPreferences.getTrackVisible();
    color = UserPreferences.getTrackColor();
    width = UserPreferences.getTrackWidth();

    trackController =
        TrackController(visible: visible, color: color, width: width);

    setState(() {
      showLayers = true;
    });
    super.initState();
  }

  void toggleAppBar() {
    print('......................toggle appbar');
    // setState(() {
    //   fullScreen = !fullScreen;
    // });
  }

  void handleSettings(var settings) async {
    var (gpxController, trackController, gpsController) = settings;

    bool gpxEdit = false;

    if (accuracy != gpxController.accuracy) {
      await UserPreferences.setAccuracy(gpxController.accuracy);
      gpxEdit = true;
    }

    if (speed != gpxController.speed) {
      await UserPreferences.setSpeed(gpxController.speed);
      gpxEdit = true;
    }

    if (heading != gpxController.heading) {
      await UserPreferences.setHeading(gpxController.heading);
      gpxEdit = true;
    }

    if (provider != gpxController.provider) {
      await UserPreferences.setProvider(gpxController.provider);
      gpxEdit = true;
    }

    if (visible != trackController.visible) {
      await UserPreferences.setTrackVisible(trackController.visible);
      gpxEdit = true;
    }

    if (color != trackController.color) {
      UserPreferences.setTrackColor(trackController.color);
      gpxEdit = true;
    }

    if (width != trackController.width) {
      UserPreferences.setTrackWidth(trackController.width);
      gpxEdit = true;
    }

    numSatelites = gpxController.numSatelites;
    accuracy = gpxController.accuracy;
    speed = gpxController.speed;
    heading = gpxController.heading;
    provider = gpxController.provider;
    visible = trackController.visible;
    color = trackController.color;
    width = trackController.width;
    gpsMethod = gpsController.method;
    unitsDistance = gpsController.unitsDistance;
    unitsTime = gpsController.unitsTime;

    if (gpxEdit) {
      _mainController.setTrackPreferences!(numSatelites, accuracy, speed,
          heading, provider, visible, color, width);
    }

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
                                  gpxController: gpxController,
                                  trackController: trackController,
                                  gpsController: gpsController,
                                  mapController: _mainController,
                                ),
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
