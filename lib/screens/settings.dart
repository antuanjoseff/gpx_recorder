import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool accuracyIsSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 50,
              ),
              Switch(
                  value: accuracyIsSwitched,
                  onChanged: (value) {
                    setState(() {
                      accuracyIsSwitched = value;
                    });
                  }),
              const SizedBox(
                width: 5,
              ),
              const Text('Accuracy')
            ],
          )
        ],
      ),
    );
  }
}
