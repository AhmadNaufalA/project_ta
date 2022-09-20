import 'package:flutter/material.dart';
import 'package:projectta/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode usernameFocus = FocusNode();
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
    setState(() {
      isLoading = false;
    });

    if (result.key) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.value)));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', result.value);

    Navigator.of(context).pushReplacementNamed('/homepage');
  }

  void handleGoToRegister() async {
    await Navigator.of(context).pushNamed('/register');
    usernameFocus.requestFocus();
  }

  void handleGoToForget() =>
      Navigator.of(context).pushNamed('/lupa_password/1');
  void handleTogglePassword() => setState(() {
        isPasswordVisible = !isPasswordVisible;
      });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: Center(
          child: Card(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: usernameController,
                enabled: !isLoading,
                focusNode: usernameFocus,
                decoration: const InputDecoration(label: Text('Username')),
                validator: ((value) => value == null
                    ? "Username tidak boleh kosong"
                    : (value.isEmpty ? "Username tidak boleh kosong" : null)),
              ),
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
                    : (value.isEmpty ? "Password tidak boleh kosong" : null)),
              ),
              MaterialButton(
                onPressed: isLoading ? null : handleLogin,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
              TextButton(
                onPressed: isLoading ? null : handleGoToRegister,
                child: const Text('Register'),
              ),
              TextButton(
                onPressed: isLoading ? null : handleGoToForget,
                child: const Text('Lupa Password'),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
