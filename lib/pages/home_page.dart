import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:projectta/components/tambak_card.dart';
import 'package:projectta/model/tambak.dart';
import 'package:projectta/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _key1 = GlobalKey();

  bool isLoading = true;
  List<Tambak> tambaks = [];

  Future<void> getTambaks() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('user')) {
      return;
    }

    final user = User.fromJson(prefs.getString('user')!);
    final newTambaks = await Tambak.getAll(user.id.toString());
    setState(() {
      tambaks = newTambaks;
      isLoading = false;
    });
  }

  void handleLogout() async {
    final result = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Log out"),
            content: Text("Yakin ingin keluar?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  "Ya",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Batal",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          );
        });

    if (result == null) return;

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
    await FirebaseMessaging.instance.unsubscribeFromTopic('a-topic');
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void initState() {
    getTambaks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => ShowCaseWidget.of(context).startShowCase([
              _key1,
            ]));
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed('/create_tambak');
          getTambaks();
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Kualitas Air Tambak Udang'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent[700],
        elevation: 0.0,
        actions: [
          IconButton(
            onPressed: handleLogout,
            icon: Icon(Icons.exit_to_app),
            color: Colors.red,
          )
        ],
      ),
      body: Container(
          margin: const EdgeInsets.all(20),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : tambaks.isEmpty
                  ? const Center(
                      child: Text('Belum ada tambak, silahkan tambah tambak'))
                  : RefreshIndicator(
                      onRefresh: getTambaks,
                      child: ListView.separated(
                        itemCount: tambaks.length,
                        separatorBuilder: (_, __) => SizedBox(height: 15),
                        itemBuilder: (_, index) {
                          final tambak = tambaks[index];

                          if (index == 0) {
                            return Showcase(
                                key: _key1,
                                description:
                                    'Tekan ini untuk melihat hasil pemantauan',
                                shapeBorder: const CircleBorder(),
                                showcaseBackgroundColor: Colors.indigo,
                                descTextStyle: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                overlayPadding: const EdgeInsets.all(8.0),
                                contentPadding: const EdgeInsets.all(16.0),
                                child: TambakCard(
                                  tambak: tambak,
                                  onDelete: getTambaks,
                                ));
                          }

                          return TambakCard(
                            tambak: tambak,
                            onDelete: getTambaks,
                          );
                        },
                        // children: <Widget>[
                        //   Showcase(
                        //       key: _key1,
                        //       description: 'Tekan ini untuk melihat hasil pemantauan',
                        //       shapeBorder: const CircleBorder(),
                        //       showcaseBackgroundColor: Colors.indigo,
                        //       descTextStyle: const TextStyle(
                        //         fontWeight: FontWeight.w500,
                        //         color: Colors.white,
                        //         fontSize: 16,
                        //       ),
                        //       overlayPadding: const EdgeInsets.all(8.0),
                        //       contentPadding: const EdgeInsets.all(16.0),
                        //       child: TambakCard(text: "Tambak 1")),
                        //   TambakCard(text: "Tambak 2"),
                        //   TambakCard(text: "Tambak 3"),
                        //   TambakCard(text: "Tambak 4"),
                        // ],
                      ),
                    )),
    );
  }
}
