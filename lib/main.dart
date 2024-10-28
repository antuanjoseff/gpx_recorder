import 'package:flutter/material.dart';
// import 'utils/user_simple_preferences.dart';
import './screens/settingsPage.dart';
import './screens/map.dart';
import './classes/trackSettings.dart';
import './classes/user_preferences.dart';
import './classes/vars.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  // await _checkPermission();
  WidgetsFlutterBinding.ensureInitialized();
  await UserPreferences.init();
  // await _checkPermission();
  runApp(const MyApp());
}

// Future<void> _checkPermission() async {
//   bool? hasPermission = false;
//   final gps = Gps();

//   bool enabled = await gps.checkService();
//   if (enabled) {
//     hasPermission = await gps.checkPermission();

//     if (hasPermission!) {
//       gps.listenOnBackground((loc) {
//         debugPrint('${loc.accuracy}');
//       });
//     }
//   }
//   return;
// }

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
  TrackSettings _trackSettings = TrackSettings();
  bool recording = false;
  bool showPauseButton = false;
  bool showResumeOrStopButtons = false;
  bool isPaused = false;
  bool isStopped = false;
  bool isResumed = false;
  bool mapCentered = true;
  int milliseconds = 300;

  bool fullScreen = false;
  late bool numSatelites;
  late bool accuracy;
  late bool speed;
  late bool heading;
  late bool provider;

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
          backgroundColor: mainColor,
          foregroundColor: Colors.white,
          title: Text(AppLocalizations.of(context)!.appTitle),
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
                              builder: (context) => SettingsPage(
                                speed: speed,
                                heading: heading,
                                numSatelites: numSatelites,
                                accuracy: accuracy,
                                provider: provider,
                              ),
                            ));
                        if (result != null) {
                          var (
                            bool numSat,
                            bool Ac,
                            bool Sp,
                            bool He,
                            bool Pro
                          ) = result;
                          numSatelites = numSat;
                          accuracy = Ac;
                          speed = Sp;
                          heading = He;
                          provider = Pro;
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
            MapWidget(trackSettings: _trackSettings, onlongpress: toggleAppBar),
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
                        _trackSettings.startRecording!();
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
                          _trackSettings.stopRecording!();
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
                          _trackSettings.resumeRecording!();
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
                          _trackSettings.finishRecording!();
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
