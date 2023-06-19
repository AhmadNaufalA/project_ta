import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:projectta/model/tambak.dart';
import 'package:projectta/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('user')) {
      final user = User.fromJson(prefs.getString('user')!);

      if (user.token == null) {
        prefs.remove('user');

        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final ids = await Tambak.getAllId(user.id.toString(), user.token!);

      await Future.wait(ids.map((e) {
        return FirebaseMessaging.instance.subscribeToTopic(e.toString());
      }));
      // await FirebaseMessaging.instance.subscribeToTopic('a-topic');

      Navigator.of(context).pushReplacementNamed('/homepage');
      return;
    }

    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(
              height: 60,
            ),
            Text('Loading, mohon tunggu sebentar')
          ],
        )),
      ),
    );
  }
}
