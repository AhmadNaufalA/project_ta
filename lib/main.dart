// ignore_for_file: avoid_print

import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:projectta/firebase_options.dart';
import 'package:projectta/model/tambak.dart';
import 'package:projectta/model/weekly_settings.dart';
import 'package:projectta/pages/create_tambak_page.dart';
import 'package:projectta/pages/detail_page.dart';
import 'package:projectta/pages/edit_tambak_page.dart';
import 'package:projectta/pages/edit_user_page.dart';
import 'package:projectta/pages/loading_page.dart';
import 'package:projectta/pages/log_page.dart';
import 'package:projectta/pages/login_page.dart';
import 'package:projectta/pages/lupa_password_1_page.dart';
import 'package:projectta/pages/lupa_password_2_page.dart';
import 'package:projectta/pages/lupa_password_3_page.dart';
import 'package:projectta/pages/register_page.dart';
import 'package:projectta/pages/weekly_page.dart';

// import 'package:showcaseview/showcaseview.dart';

import './pages/home_page.dart';
import './pages/splash_page.dart';
import 'model/user.dart';

Future<void> notificationHandler(RemoteMessage message) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: Random().nextInt(1024),
      channelKey: 'notifikasi',
      title: message.data['title'],
      body: message.data['body'],
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelKey: 'notifikasi',
        channelName: 'Notifikasi',
        channelDescription:
            'notifikasi ketika ada parameter yang tidak optimal',
        playSound: true,
        importance: NotificationImportance.Max)
  ]);
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print(fcmToken);
  FirebaseMessaging.onMessage.listen(notificationHandler);
  FirebaseMessaging.onBackgroundMessage(notificationHandler);

  Intl.defaultLocale = "id";
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
      supportedLocales: const [Locale('id')],

      // initialRoute: '/loading',
      // routes: {
      //   '/homepage': (context) => const HomePage(),
      //   '/detail': (context) => DetailPage(),
      //   '/splash': (context) => const SplashPage(),
      //   '/weekly': (context) => const WeeklyPage(),
      // },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          // case '/loading':
          //   return MaterialPageRoute(builder: (context) => const LoadingPage());
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginPage());
          case '/register':
            return MaterialPageRoute(
                builder: (context) => const RegisterPage());
          case '/lupa_password/1':
            return MaterialPageRoute(
                builder: (context) => const LupaPassword1Page());
          case '/lupa_password/2':
            return MaterialPageRoute(
                builder: (context) => LupaPassword2Page(
                      id: (settings.arguments as List)[0],
                      question: (settings.arguments as List)[1],
                    ));
          case '/lupa_password/3':
            return MaterialPageRoute(
                builder: (context) => LupaPassword3Page(
                      id: settings.arguments as int,
                    ));
          case '/homepage':
            return MaterialPageRoute(builder: (context) => const HomePage());
          case '/detail':
            return MaterialPageRoute(
                builder: (context) => DetailPage(
                      initialTambak: settings.arguments as Tambak,
                    ));
          case '/splash':
            return MaterialPageRoute(builder: (context) => const SplashPage());
          case '/weekly':
            return MaterialPageRoute(
                builder: (context) => WeeklyPage(
                      settings:
                          (settings.arguments as List)[0] as WeeklySettings,
                      tambak: (settings.arguments as List)[1] as Tambak,
                    ));
          case '/create_tambak':
            return MaterialPageRoute(
                builder: (context) => const CreateTambakPage());
          case '/edit_tambak':
            return MaterialPageRoute(
                builder: (context) => EditTambakPage(
                      tambak: settings.arguments as Tambak,
                    ));
          case '/edit_user':
            return MaterialPageRoute(
                builder: (context) => EditUserPage(
                      user: settings.arguments as User,
                    ));
          case '/log':
            return MaterialPageRoute(
                builder: (context) => LogPage(
                      tambak: settings.arguments as Tambak,
                    ));
          default:
            return MaterialPageRoute(builder: (context) => const LoadingPage());
        }
      },
    );
  }
}
