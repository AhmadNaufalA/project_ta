import 'package:flutter/material.dart';
import 'package:projectta/model/log.dart';

import '../model/tambak.dart';

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
    final newLogs = await widget.tambak.getLogs();
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
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(logs[index].isi),
                              const SizedBox(height: 4),
                              Text(
                                logs[index].waktu,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      separatorBuilder: (_, __) => const SizedBox(
                        height: 4,
                      ),
                    ),
        ));
  }
}
