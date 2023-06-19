import 'package:flutter/material.dart';
import 'package:projectta/model/user.dart';

class LupaPassword1Page extends StatefulWidget {
  const LupaPassword1Page({Key? key}) : super(key: key);

  @override
  State<LupaPassword1Page> createState() => _LupaPassword1PageState();
}

class _LupaPassword1PageState extends State<LupaPassword1Page> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  bool isLoading = false;

  Future<void> handleSubmit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });
    final result = await User.getByUsername(usernameController.text);
    setState(() {
      isLoading = false;
    });

    if (result == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("User tidak ditemukan")));
      return;
    }

    Navigator.of(context).pushNamed('/lupa_password/2',
        arguments: [result.id, result.secretQuestion]);
  }

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
              Text("Silakan Masukkan Username",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  )),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      controller: usernameController,
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                ),
                child: MaterialButton(
                  onPressed: isLoading ? null : handleSubmit,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Lanjut',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
