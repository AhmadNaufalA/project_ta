import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:projectta/utils/get_token.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';

class EditUserPage extends StatefulWidget {
  const EditUserPage({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;
  late final TextEditingController namaController =
      TextEditingController(text: widget.user.nama);
  late final TextEditingController passwordController =
      TextEditingController(text: '');
  bool isPasswordVisible = false;

  @override
  void dispose() {
    namaController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleTogglePassword() => setState(() {
        isPasswordVisible = !isPasswordVisible;
      });

  Future<void> submitUserForm() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

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
    await widget.user
        .editUser(namaController.text, passwordController.text, token);

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diubah')));
    Navigator.of(context).pop(true);
  }

  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ubah Password"),
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
                    // TextFormField(
                    //   controller: namaController,
                    //   enabled: !isLoading,
                    //   decoration:
                    //       const InputDecoration(label: Text('Nama Pengguna')),
                    //   validator: ((value) => value == null
                    //       ? "Nama tidak boleh kosong"
                    //       : (value.isEmpty ? "Nama tidak boleh kosong" : null)),
                    // ),
                    TextFormField(
                      controller: passwordController,
                      enabled: !isLoading,
                      obscureText: !isPasswordVisible,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                          label: const Text('Password'),
                          suffixIcon: IconButton(
                              onPressed: handleTogglePassword,
                              icon: Icon(!isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off))),
                      validator: ((value) => value == null
                          ? "Password tidak boleh kosong"
                          : (value.isEmpty
                              ? "Password tidak boleh kosong"
                              : null)),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          MaterialButton(
            onPressed: isLoading ? null : submitUserForm,
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text('Submit'),
          )
        ],
      ),
    );
  }
}
