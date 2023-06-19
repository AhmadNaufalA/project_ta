import 'package:flutter/material.dart';
import 'package:projectta/model/user.dart';

class LupaPassword2Page extends StatefulWidget {
  const LupaPassword2Page({Key? key, required this.question, required this.id})
      : super(key: key);

  final String question;
  final int id;

  @override
  State<LupaPassword2Page> createState() => _LupaPassword2PageState();
}

class _LupaPassword2PageState extends State<LupaPassword2Page> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController answerController = TextEditingController();
  bool isLoading = false;

  Future<void> handleSubmit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });
    final result = await User.checkAnswer(widget.id, answerController.text);
    setState(() {
      isLoading = false;
    });

    if (!result) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Jawaban Salah")));
      return;
    }

    Navigator.of(context).pushNamed('/lupa_password/3', arguments: widget.id);
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
              Text(
                "Secret Question : ${widget.question}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
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
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: answerController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(label: Text('Secret answer')),
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
