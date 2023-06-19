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
  final FocusNode questionNode = FocusNode();
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result ?? "Gagal membuat akun")));
    Navigator.of(context).pop();
  }

  void handleGoToLogin() => Navigator.of(context).pop();
  void handleTogglePassword() => setState(() {
        isPasswordVisible = !isPasswordVisible;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: [
          Form(
            key: formKey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  const Text(
                    'Silakan Isi Form Pendaftaran',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: usernameController,
                          textInputAction: TextInputAction.next,
                          enabled: !isLoading,
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
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: namaController,
                          textInputAction: TextInputAction.next,
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                              label: Text('Nama Lengkap')),
                          validator: ((value) => value == null
                              ? "Nama tidak boleh kosong"
                              : (value.isEmpty
                                  ? "Nama tidak boleh kosong"
                                  : null)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
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
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => questionNode.requestFocus(),
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
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: questionController,
                          focusNode: questionNode,
                          textInputAction: TextInputAction.next,
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                              label: Text('Pertanyaan Rahasia')),
                          validator: ((value) => value == null
                              ? "Secret question tidak boleh kosong"
                              : (value.isEmpty
                                  ? "Secret question tidak boleh kosong"
                                  : null)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: answerController,
                          textInputAction: TextInputAction.next,
                          enabled: !isLoading,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              label: Text('Jawaban (Angka)')),
                          validator: ((value) => value == null
                              ? "Secret answer tidak boleh kosong"
                              : (value.isEmpty
                                  ? "Secret answer tidak boleh kosong"
                                  : null)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                    ),
                    child: MaterialButton(
                      onPressed: isLoading ? null : handleRegister,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Register',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : handleGoToLogin,
                    child: const Text('Kembali ke halaman Login'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
