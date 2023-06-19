// ignore_for_file: use_build_context_synchronously

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:projectta/model/tambak.dart';
import 'package:projectta/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/get_token.dart';

class CreateTambakPage extends StatefulWidget {
  const CreateTambakPage({Key? key}) : super(key: key);

  @override
  State<CreateTambakPage> createState() => _CreateTambakPageState();
}

class _CreateTambakPageState extends State<CreateTambakPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  bool isLoading = false;
  Map<String, bool> preference = {
    "pH": false,
    "Suhu": false,
    "TDS": false,
    // "Ketinggian": false,
    "Oksigen": false,
    "Kekeruhan": false,
  };

  @override
  void dispose() {
    namaController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (!formKey.currentState!.validate()) {
      return;
    }

    if (userString == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('User tidak ditemukan, mohon login ulang')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    final isPreferenceInvalid = preference.entries
        .map((e) => e.value == false)
        .reduce((a, b) => a && b);

    if (isPreferenceInvalid) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon pilih salah satu sensor')));
      setState(() {
        isLoading = false;
      });
      return;
    }

    final token = await getToken();

    if (token == null) {
      await FirebaseMessaging.instance.deleteToken();

      prefs.remove('user');

      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    final idTambak = await Tambak.createTambak(namaController.text,
        descController.text, User.fromJson(userString).id, preference, token);

    await FirebaseMessaging.instance.subscribeToTopic(idTambak.toString());

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Tambak berhasil dibuat, silahkan kembali ke menu sebelumnya')));
    Navigator.of(context).pop();
  }

  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Tambak Baru"),
        centerTitle: true,
        backgroundColor: Colors.greenAccent[700],
        elevation: 0.0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: formKey,
                  child: Column(children: [
                    TextFormField(
                      controller: namaController,
                      enabled: !isLoading,
                      decoration:
                          const InputDecoration(label: Text('Nama Tambak')),
                      validator: ((value) => value == null
                          ? "Nama tidak boleh kosong"
                          : (value.isEmpty ? "Nama tidak boleh kosong" : null)),
                    ),
                    TextFormField(
                      controller: descController,
                      minLines: 3,
                      maxLines: 5,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        // label: Text('Deskripsi Tambak'),
                        labelText: 'Deskripsi Tambak',
                        alignLabelWithHint: true,
                      ),
                      validator: ((value) => value == null
                          ? "Deskripsi tidak boleh kosong"
                          : (value.isEmpty
                              ? "Deskripsi tidak boleh kosong"
                              : null)),
                    ),
                    CheckboxListTile(
                      value: preference.entries
                          .map((e) => e.value)
                          .reduce((a, b) => a && b),
                      onChanged: (newValue) {
                        final currentValue = preference.entries
                            .map((e) => e.value)
                            .reduce((a, b) => a && b);
                        setState(() {
                          preference.updateAll((key, value) => !currentValue);
                        });
                      },
                      title: const Text("Toggle All"),
                    ),
                    ...preference.entries.map((entry) {
                      return CheckboxListTile(
                        value: entry.value,
                        onChanged: (newValue) {
                          setState(() {
                            preference[entry.key] = newValue ?? false;
                          });
                        },
                        title: Text(entry.key),
                      );
                    }),
                  ]),
                ),
              ),
            ),
          ),
          MaterialButton(
            onPressed: isLoading ? null : submitForm,
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text('Submit'),
          )
        ],
      ),
    );
  }
}
