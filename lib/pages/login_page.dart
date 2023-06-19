import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:projectta/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/tambak.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // final FocusNode usernameFocus = FocusNode();
  bool isPasswordVisible = false;
  bool isLoading = false;

  Future<void> handleLogin() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });
    final result = await User.login(
      username: usernameController.text,
      password: passwordController.text,
    );
    log('result : $result');

    if (result.key) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.value ?? "Gagal Login")));
      return;
    }
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user', jsonEncode(result.value));
    // String? deviceToken = await FirebaseMessaging.instance.getToken();
    // log('dev token: $deviceToken');
    // final user = User.fromJson(prefs.getString('user')!);
    // final tokenResult = await User.saveToken(
    //   deviceToken: deviceToken.toString(),
    //   token: user.token.toString(),
    // );

    if (prefs.containsKey('user')) {
      final user = User.fromJson(prefs.getString('user')!);

      final ids = await Tambak.getAllId(user.id.toString(), user.token!);

      await Future.wait(ids.map((e) {
        return FirebaseMessaging.instance.subscribeToTopic(e.toString());
      }));
      // await FirebaseMessaging.instance.subscribeToTopic('a-topic');

      Navigator.of(context).pushReplacementNamed('/homepage');
      return;
    }

    setState(() {
      isLoading = false;
    });

    Navigator.of(context).pushReplacementNamed('/detail');
  }

  void handleGoToRegister() async {
    await Navigator.of(context).pushNamed('/register');
    // usernameFocus.requestFocus();
  }

  void handleGoToForget() =>
      Navigator.of(context).pushNamed('/lupa_password/1');
  void handleTogglePassword() => setState(() {
        isPasswordVisible = !isPasswordVisible;
      });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        shrinkWrap: true,
        children: [
          Form(
            key: formKey,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Image.asset(
                      'images/icond.jpg',
                      height: 200,
                      width: 200,
                    ),
                    SizedBox(height: 10),
                    const Text(
                      'Selamat Datang di Simon App',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextFormField(
                            controller: usernameController,
                            enabled: !isLoading,
                            // focusNode: usernameFocus,
                            textInputAction: TextInputAction.next,
                            decoration:
                                const InputDecoration(label: Text('Username')),
                            validator: ((value) => value == null
                                ? "Username tidak boleh kosong"
                                : (value.isEmpty
                                    ? "Username tidak boleh kosong"
                                    : null)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: passwordController,
                            enabled: !isLoading,
                            obscureText: !isPasswordVisible,
                            keyboardType: TextInputType.visiblePassword,
                            onFieldSubmitted: (_) => handleLogin(),
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                      ),
                      child: MaterialButton(
                        onPressed: isLoading ? null : handleLogin,
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    // TextButton(
                    //   onPressed: isLoading ? null : handleGoToRegister,
                    //   child: const Text('Register'),
                    // ),
                    TextButton(
                      onPressed: isLoading ? null : handleGoToForget,
                      child: const Text('Lupa Password'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
