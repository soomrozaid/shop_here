import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shop_here/firebase_options.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  initFirebaseMessaging();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessaging);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("Notification onMessage: ${message.notification.toString()}");
    }
  });
  runApp(const MyApp());
}

Future _firebaseBackgroundMessaging(RemoteMessage message) async {
  if (message.notification != null) {
    print("You got message: ${message.notification}");
  }
}

Future<void> initFirebaseMessaging() async {
  FirebaseMessaging instance = FirebaseMessaging.instance;
  // NotificationSettings firebaseSetttings =
  //     await instance.requestPermission(provisional: true);

  NotificationSettings settings = await instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  String? apnsToken = await instance.getAPNSToken();
  String? token = await instance.getToken();

  print('User granted permission: ${settings.authorizationStatus}');

  print(apnsToken);
  print(token);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

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
  int _counter = 0;
  String positionInfo = "No Position information";

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Future<void> getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    while (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      Geolocator.openAppSettings();
    }

    Position position = await Geolocator.getCurrentPosition();
    // LocationAccuracyStatus location = await Geolocator.getLocationAccuracy();

    double distanceToWalmart = Geolocator.distanceBetween(position.latitude,
        position.longitude, 52.15292066644239, -106.62147190964006) / 1000;

    setState(() => positionInfo = distanceToWalmart.toString());
    // if (permission == LocationPermission.denied) {
    //   // permission = await Geolocator.requestPermission();
    //   // Geolocator.openLocationSettings();
    //   final opened = await Geolocator.openAppSettings();

    //   permission = await Geolocator.requestPermission();

    //   if (permission == LocationPermission.denied) {
    //     print("permission");
    //     print(permission);
    //   }

    //   print(opened);
    // } else {
    //   Geolocator.getCurrentPosition();
    // }

    // print(permission);
    // return "";
  }

  Future<void> sendNotification() async {
    // http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"), headers: {
    //   "Authorization":
    //       "Bearer AAAAr7jOjek:APA91bFd_wP6S7ANGKNNZlzsZYVa65ZYApVPKv3NmcUQCryUDPkYVrvb1XnaNQ7CvII_KyPGqKRxS_bHYtdma666GdNfGW7bdo1qijo1cAE3HuLyUMnnLuDFkS3aw3oTU3_rVvqPqEQL"
    // }, body: {
    //   "to":
    //       "dYLSCM9i6kuAun3vq-wfy1:APA91bGVa-FrJ67FlHiiFjVrLKtjIMXLNR-7EOnHb8bInWa0raFl6x9pHjZ4bKsD1vQL9ultWBSU5cYzntsJpDco3FX9BFL-N4u2xdL8SE6E1eZHZgYMJzXw3wJsUpUsMuPmSN9KEgtd",
    //   "notification": {
    //     "title": "Hello from the APIs",
    //     "body": "I must have called a thousand times.",
    //     "sound": "default"
    //   }
    // });
    String url = 'https://fcm.googleapis.com/fcm/send';
    String token =
        "AAAAr7jOjek:APA91bFd_wP6S7ANGKNNZlzsZYVa65ZYApVPKv3NmcUQCryUDPkYVrvb1XnaNQ7CvII_KyPGqKRxS_bHYtdma666GdNfGW7bdo1qijo1cAE3HuLyUMnnLuDFkS3aw3oTU3_rVvqPqEQL";
    final response = await http.post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "to":
              "dYLSCM9i6kuAun3vq-wfy1:APA91bGVa-FrJ67FlHiiFjVrLKtjIMXLNR-7EOnHb8bInWa0raFl6x9pHjZ4bKsD1vQL9ultWBSU5cYzntsJpDco3FX9BFL-N4u2xdL8SE6E1eZHZgYMJzXw3wJsUpUsMuPmSN9KEgtd",
          "notification": {
            "title": "Hello from the APIs",
            "body": "I must have called a thousand times.",
            "sound": "default"
          }
        }));
    print('Token : ${token}');
    print(response);

    if (response.statusCode == 200) {
      Map formattedResponse = jsonDecode(response.body);
      print(formattedResponse);
      // return themes;
    } else {
      throw Exception('Failed to load themes');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // FutureBuilder(
            //     future: getUserLocation(),
            //     builder: (BuildContext context, snapshot) {
            //       print(snapshot);
            //       return Text(snapshot.toString());
            //     }),
            StreamBuilder(
              stream: FirebaseMessaging.onMessage,
              builder: (BuildContext context,
                  AsyncSnapshot<RemoteMessage> snapshot) {
                if (snapshot.hasData && snapshot.data?.notification != null) {
                  return ColoredBox(
                    color: Colors.blueGrey,
                    child: Column(
                      children: [
                        Text(
                          snapshot.data!.notification?.title ??
                              "No title provided",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 24),
                        ),
                        Text(
                          snapshot.data!.notification?.body ??
                              "no body provided",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }
                return const ColoredBox(
                  color: Colors.redAccent,
                  child: Text(
                    "No New Notifications",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
            Text(positionInfo),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton.icon(
                onPressed: getUserLocation,
                icon: const Icon(Icons.location_searching),
                label: const Text("Get Location")),
            ElevatedButton.icon(
                onPressed: sendNotification,
                icon: const Icon(Icons.notifications),
                label: const Text("Send Notification")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
