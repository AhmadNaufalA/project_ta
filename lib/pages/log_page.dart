import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:projectta/model/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/tambak.dart';
import '../utils/get_token.dart';

class LogPage extends StatefulWidget {
  const LogPage({Key? key, required this.tambak}) : super(key: key);

  final Tambak tambak;

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  List<Log> logs = [];
  bool isLoading = true;

  Future<void> getLogs() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = await getToken();

    if (token == null) {
      await FirebaseMessaging.instance.deleteToken();

      prefs.remove('user');

      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }
    final newLogs = await widget.tambak.getLogs(token);
    setState(() {
      logs = newLogs;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Log"),
          centerTitle: true,
          backgroundColor: Colors.greenAccent[700],
          elevation: 0.0,
        ),
        body: RefreshIndicator(
          onRefresh: getLogs,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : logs.isEmpty
                  ? const Center(
                      child: Text("Belum ada log"),
                    )
                  : ListView.separated(
                      itemCount: logs.length,
                      itemBuilder: (_, index) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                logs[index].isi,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                logs[index].waktu,
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                      separatorBuilder: (_, __) => const SizedBox(
                        height: 14,
                      ),
                    ),
        ));
  }
}
