import 'package:flutter/material.dart';
import 'package:projectta/model/user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController questionController = TextEditingController();
  final TextEditingController answerController = TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false;

  Future<void> handleRegister() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });
    final result = await User.register(
      username: usernameController.text,
      nama: namaController.text,
      password: passwordController.text,
      question: questionController.text,
      answer: answerController.text,
    );
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    Navigator.of(context).pop();
  }

  void handleGoToLogin() => Navigator.of(context).pop();
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
                decoration: const InputDecoration(label: Text('Username')),
                validator: ((value) => value == null
                    ? "Username tidak boleh kosong"
                    : (value.isEmpty ? "Username tidak boleh kosong" : null)),
              ),
              TextFormField(
                controller: namaController,
                enabled: !isLoading,
                decoration: const InputDecoration(label: Text('Nama Lengkap')),
                validator: ((value) => value == null
                    ? "Nama tidak boleh kosong"
                    : (value.isEmpty ? "Nama tidak boleh kosong" : null)),
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
              TextFormField(
                controller: questionController,
                enabled: !isLoading,
                decoration:
                    const InputDecoration(label: Text('Secret Question')),
                validator: ((value) => value == null
                    ? "Secret question tidak boleh kosong"
                    : (value.isEmpty
                        ? "Secret question tidak boleh kosong"
                        : null)),
              ),
              TextFormField(
                controller: answerController,
                enabled: !isLoading,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(label: Text('Secret Answer (nomor)')),
                validator: ((value) => value == null
                    ? "Secret answer tidak boleh kosong"
                    : (value.isEmpty
                        ? "Secret answer tidak boleh kosong"
                        : null)),
              ),
              MaterialButton(
                onPressed: isLoading ? null : handleRegister,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Register'),
              ),
              TextButton(
                onPressed: isLoading ? null : handleGoToLogin,
                child: const Text('Login'),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
