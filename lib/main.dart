import 'package:apod_lockscreen_app/objects/worker_class.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'APOD LockScreen'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSwitched = false;
  String middleString = "non ";

  late BuildContext stateContext;

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
      _toggleSwitch(isSwitched);
    });
  }

  Future<void> _toggleSwitch(value) async {
    // mandare segnale solo quando cambia lo stato
    if (value != isSwitched) {
      WorkerClass.receiveState(value, context);
    }

    // store
    isSwitched = value;
    if (isSwitched) {
      middleString = "";
    } else {
      middleString = "non ";
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("switch", isSwitched);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    stateContext = context;

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
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
                    _toggleSwitch(value);
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
