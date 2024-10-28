import 'package:flutter/material.dart';
import '../classes/vars.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:accordion/accordion.dart';
import 'gpxSettings.dart';

class SettingsPage extends StatefulWidget {
  final bool numSatelites;
  final bool accuracy;
  final bool speed;
  final bool heading;
  final bool provider;

  SettingsPage(
      {super.key,
      required this.numSatelites,
      required this.accuracy,
      required this.speed,
      required this.heading,
      required this.provider});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const headerStyle = TextStyle(
      color: Color(0xffffffff), fontSize: 18, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mainColor,
          foregroundColor: Colors.white,
          title: Text(AppLocalizations.of(context)!.settings),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Accordion(
                  headerBorderColor: Colors.blueGrey,
                  headerBorderColorOpened: Colors.transparent,
                  // headerBorderWidth: 1,
                  headerBackgroundColorOpened: Colors.green,
                  contentBackgroundColor: Colors.white,
                  contentBorderColor: Colors.green,
                  contentBorderWidth: 3,
                  contentHorizontalPadding: 20,
                  scaleWhenAnimating: true,
                  openAndCloseAnimation: true,
                  headerPadding:
                      const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
                  // sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
                  // sectionClosingHapticFeedback: SectionHapticFeedback.light,
                  children: [
                    AccordionSection(
                      isOpen: false,
                      contentVerticalPadding: 20,
                      headerBackgroundColor: Colors.orange[600],
                      contentBorderColor: Colors.orange[600],
                      leftIcon: const Icon(Icons.insert_drive_file_outlined,
                          color: Colors.white),
                      header: const Text('GPX properties', style: headerStyle),
                      content: Settings(
                        numSatelites: widget.numSatelites,
                        accuracy: widget.accuracy,
                        speed: widget.speed,
                        heading: widget.heading,
                        provider: widget.provider,
                      ),
                    ),
                    AccordionSection(
                      isOpen: false,
                      contentVerticalPadding: 20,
                      headerBackgroundColor: Colors.orange[600],
                      contentBorderColor: Colors.orange[600],
                      leftIcon:
                          const Icon(Icons.satellite_alt, color: Colors.white),
                      header: const Text('GPS properties', style: headerStyle),
                      content: Settings(
                        numSatelites: widget.numSatelites,
                        accuracy: widget.accuracy,
                        speed: widget.speed,
                        heading: widget.heading,
                        provider: widget.provider,
                      ),
                    ),
                    AccordionSection(
                      isOpen: false,
                      contentVerticalPadding: 20,
                      headerBackgroundColor: Colors.orange[600],
                      contentBorderColor: Colors.orange[600],
                      leftIcon:
                          const Icon(Icons.remove_red_eye, color: Colors.white),
                      header:
                          const Text('Track properties', style: headerStyle),
                      content: Settings(
                        numSatelites: widget.numSatelites,
                        accuracy: widget.accuracy,
                        speed: widget.speed,
                        heading: widget.heading,
                        provider: widget.provider,
                      ),
                    ),
                  ])
            ],
          ),
        ));
  }
}
