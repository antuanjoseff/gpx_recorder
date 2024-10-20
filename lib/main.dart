import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:location/location.dart';
import '../classes/gps.dart';
import 'utils/user_simple_preferences.dart';
import 'package:location/location.dart';
import './screens/settings.dart';

void main() async {
  // await _checkPermission();
  WidgetsFlutterBinding.ensureInitialized();
  await UserSimplePreferences.init();
  await _checkPermission();
  runApp(const MyApp());
}

Future<void> _checkPermission() async {
  bool hasPermission = false;
  final gps = new Gps();

  bool enabled = await gps.checkService();
  if (enabled) {
    hasPermission = await gps.checkPermission();
  }
  await UserSimplePreferences.setGpsEnabled(enabled);
  await UserSimplePreferences.setHasPermission(hasPermission);
  return;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool recording = false;
  bool showPauseButton = false;
  bool showResumeOrStopButtons = false;

  bool isPaused = false;
  bool isStopped = false;
  bool isResumed = false;
  bool mapCentered = true;

  int milliseconds = 300;

  late MapLibreMapController mapController;
  Location location = new Location();
  MyLocationRenderMode _myLocationRenderMode = MyLocationRenderMode.compass;
  MyLocationTrackingMode _myLocationTrackingMode =
      MyLocationTrackingMode.trackingGps;

  ButtonStyle customStyleButton = ElevatedButton.styleFrom(
    minimumSize: Size.zero, // Set this
    padding: EdgeInsets.all(15), // and this
  );

  @override
  void initState() {
    super.initState();
    location.enableBackgroundMode(enable: true);
    location.changeNotificationOptions(
      title: 'Geolocation',
      subtitle: 'Geolocation detection',
    );
  }

  void _onMapCreated(MapLibreMapController controller) async {
    mapController = controller;
    bool gpsEnabled = UserSimplePreferences.getGpsEnabled() ?? false;
    bool gpsPermission = UserSimplePreferences.getHasPermission() ?? false;

    print(
        '                                  GPS HAS PERMISSION ${gpsPermission}');
    if (gpsPermission) {
      location.onLocationChanged.listen((LocationData currentLocation) {
        manageNewPosition(currentLocation);
      });
    }
  }

  void manageNewPosition(LocationData loc) {
    print('...............${loc.latitude}...........${loc.longitude}');
    centerMap(LatLng(loc.latitude!, loc.longitude!));
  }

  void centerMap(LatLng location) {
    mapController!.animateCamera(
      CameraUpdate.newLatLng(location),
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Gpx Recorder'),
          actions: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () async {
                        var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Settings(),
                            ));
                        if (result != null) {
                          // var (Color? trColor, double? trWidth) = result;
                          // trackColor = trColor!;
                          // trackWidth = trWidth!;
                        }
                      },
                    )
                  ],
                ),
              ],
            )
          ],
        ),
        body: Stack(
          children: [
            MapLibreMap(
              myLocationEnabled: true,
              myLocationTrackingMode: _myLocationTrackingMode,
              myLocationRenderMode: _myLocationRenderMode,
              onMapCreated: _onMapCreated,
              styleString:
                  'https://geoserveis.icgc.cat/contextmaps/icgc_orto_hibrida.json',
              initialCameraPosition:
                  const CameraPosition(target: LatLng(0.0, 0.0)),
              trackCameraPosition: true,
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: milliseconds),
              onEnd: () {
                setState(() {
                  showPauseButton = true;
                });
              },
              left: (!recording && !showPauseButton) ? 10 : -75,
              bottom: 30,
              child: SizedBox(
                width: 75,
                child: Row(
                  children: [
                    ElevatedButton(
                      style: customStyleButton,
                      onPressed: () {
                        setState(() {
                          recording = true;
                        });
                      },
                      child: const Icon(
                        Icons.circle,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: milliseconds),
              left: (showPauseButton) ? 10 : -80,
              onEnd: () {
                setState(() {
                  if (!showPauseButton) {
                    showResumeOrStopButtons = true;
                  }
                });
              },
              bottom: 30,
              child: Container(
                color: Colors.transparent,
                child: SizedBox(
                  width: 80,
                  child: Row(
                    children: [
                      ElevatedButton(
                        style: customStyleButton,
                        onPressed: () {
                          setState(() {
                            showPauseButton = false;
                            isPaused = true;
                          });
                        },
                        child: const Icon(
                          Icons.pause,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: milliseconds),
              left: showResumeOrStopButtons ? 10 : -160,
              onEnd: () {
                setState(() {
                  if (isResumed && !isPaused) {
                    showPauseButton = true;
                  }
                });
              },
              bottom: 30,
              child: Container(
                color: Colors.transparent,
                child: SizedBox(
                  width: 160,
                  child: Row(
                    children: [
                      ElevatedButton(
                        style: customStyleButton,
                        onPressed: () {
                          setState(() {
                            showResumeOrStopButtons = false;
                            isResumed = true;
                            isPaused = false;
                          });
                        },
                        child: const Icon(
                          Icons.circle,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isStopped = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: Size.zero, // Set this
                          padding: EdgeInsets.all(15), // and this
                        ),
                        child: const Icon(Icons.stop, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
