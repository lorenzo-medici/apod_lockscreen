import 'package:apod_lockscreen_app/objects/worker_class.dart';
import 'package:apod_lockscreen_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  Utils.initializeNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APOD LockScreen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'APOD LockScreen'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSwitched = false;
  String middleString = "non ";

  @override
  void initState() {
    super.initState();
    _loadSwitch();
  }

  Future<void> _loadSwitch() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isSwitched = prefs.getBool("switch")!;

      // updates string
      _toggleSwitch(isSwitched, mounted);
    });
  }

  Future<void> _toggleSwitch(value, mounted) async {
    // mandare segnale solo quando cambia lo stato
    if (value != isSwitched) {
      WorkerClass.receiveState(value, context, mounted);
    }

    // store
    isSwitched = value;

    middleString = (isSwitched) ? "" : "non ";

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("switch", isSwitched);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SizedBox(
          width: double.infinity,
          height: 90,
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                  ),
                  children: [
                    const TextSpan(
                      text: "Il servizio ",
                    ),
                    TextSpan(
                      text: middleString,
                    ),
                    const TextSpan(
                      text: "è attivo",
                    ),
                  ],
                ),
              ),
              Switch(
                value: isSwitched,
                onChanged: (value) {
                  setState(() {
                    _toggleSwitch(value, mounted);
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
