import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:projectta/components/tambak_card.dart';
import 'package:projectta/model/tambak.dart';
import 'package:projectta/model/user.dart';
import 'package:projectta/utils/get_token.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  List<Tambak> tambaks = [];

  Future<void> getTambaks() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('user')) {
      return;
    }

    final user = User.fromJson(prefs.getString('user')!);

    final token = await getToken();

    if (token == null) {
      await FirebaseMessaging.instance.deleteToken();

      prefs.remove('user');

      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    final newTambaks = await Tambak.getAll(user.id.toString(), token);
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
            content: const Text("Yakin ingin keluar?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  "Ya",
                  style: TextStyle(color: Colors.green),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Batal",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        });

    if (result == null) return;

    final prefs = await SharedPreferences.getInstance();

    await FirebaseMessaging.instance.deleteToken();

    prefs.remove('user');

    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void initState() {
    getTambaks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.grey.shade300,
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: Colors.green,
        //   onPressed: () async {
        //     await Navigator.of(context).pushNamed('/create_tambak');
        //     getTambaks();
        //   },
        //   child: const Icon(Icons.add),
        // ),
        appBar: AppBar(
          title: const Text('Kualitas Air Tambak Udang'),
          centerTitle: false,
          backgroundColor: Colors.greenAccent[700],
          elevation: 0.0,
          actions: [
            IconButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final savedUser = prefs.getString('user');

                  if (savedUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Tidak bisa akses user, silahkan login ulang')));
                    return;
                  }
                  final user = User.fromJson(savedUser);
                  await Navigator.of(context)
                      .pushNamed('/edit_user', arguments: user);
                },
                icon: const Icon(Icons.account_circle_rounded)),
            IconButton(
              onPressed: handleLogout,
              icon: const Icon(Icons.exit_to_app),
              color: Colors.white,
            )
          ],
        ),
        body: Container(
            margin: const EdgeInsets.fromLTRB(18, 20, 18, 20),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : tambaks.isEmpty
                    ? const Center(
                        child: Text('Belum ada tambak, silahkan tambah tambak'))
                    : RefreshIndicator(
                        onRefresh: getTambaks,
                        child: ListView.separated(
                          itemCount: tambaks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 15),
                          itemBuilder: (_, index) {
                            final tambak = tambaks[index];

                            if (index == 0) {
                              TambakCard(
                                tambak: tambak,
                                onDelete: getTambaks,
                              );
                            }

                            return TambakCard(
                              tambak: tambak,
                              onDelete: getTambaks,
                            );
                          },
                        ),
                      )),
      );
}
