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
    ThemeData darkTheme = ThemeData(
      primaryColor: Colors.amber,
      textTheme: const TextTheme(
        bodyText1: TextStyle(),
        bodyText2: TextStyle(),
      ).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      buttonTheme: const ButtonThemeData(
          buttonColor: Colors.amber, disabledColor: Colors.black),
      snackBarTheme: const SnackBarThemeData(
        actionTextColor: Colors.black,
        backgroundColor: Colors.amber,
      ),
      appBarTheme: const AppBarTheme(
        foregroundColor: Colors.black,
      ),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber).copyWith(
        secondary: Colors.red,
        brightness: Brightness.dark,
      ),
    );

    ThemeData lightTheme = ThemeData(
      primaryColor: Colors.pink,
      textTheme: const TextTheme(
        bodyText1: TextStyle(),
        bodyText2: TextStyle(),
      ).apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        foregroundColor: Colors.black,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: Colors.blue.shade700,
        brightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'APOD LockScreen',
      theme: lightTheme,
      darkTheme: darkTheme,
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
  String middleString = "not ";

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

    middleString = (isSwitched) ? "" : "not ";

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("switch", isSwitched);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: SizedBox(
          width: double.infinity,
          height: 180,
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1!.color!,
                    fontSize: 22,
                  ),
                  children: [
                    const TextSpan(
                      text: "Wallpaper setting is ",
                    ),
                    TextSpan(
                      text: middleString,
                    ),
                    const TextSpan(
                      text: "active",
                    ),
                  ],
                ),
              ),
              Switch(
                value: isSwitched,
                activeColor: Theme.of(context).colorScheme.secondary,
                onChanged: (value) {
                  setState(() {
                    _toggleSwitch(value, mounted);
                  });
                },
              ),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () {
                  WorkerClass.changeLockScreenWallpaper();
                },
                child: Text("Force"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
