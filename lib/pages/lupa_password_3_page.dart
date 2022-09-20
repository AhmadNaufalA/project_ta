import 'package:flutter/material.dart';
import 'package:projectta/model/user.dart';

class LupaPassword3Page extends StatefulWidget {
  const LupaPassword3Page({Key? key, required this.id}) : super(key: key);

  final int id;

  @override
  State<LupaPassword3Page> createState() => _LupaPassword3PageState();
}

class _LupaPassword3PageState extends State<LupaPassword3Page> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false;

  Future<void> handleSubmit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });
    final result = await User.resetPassword(widget.id, passwordController.text);
    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password berhasil diubah, silahkan login")));
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

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
                controller: passwordController,
                enabled: !isLoading,
                obscureText: !isPasswordVisible,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                    label: const Text('Password Baru'),
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
                onPressed: isLoading ? null : handleSubmit,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit'),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
