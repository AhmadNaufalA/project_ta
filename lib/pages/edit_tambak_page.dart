// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:projectta/model/tambak.dart';

class EditTambakPage extends StatefulWidget {
  const EditTambakPage({Key? key, required this.tambak}) : super(key: key);

  final Tambak tambak;

  @override
  State<EditTambakPage> createState() => _EditTambakPageState();
}

class _EditTambakPageState extends State<EditTambakPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;
  late final TextEditingController nameController =
      TextEditingController(text: widget.tambak.name);
  late final TextEditingController descController =
      TextEditingController(text: widget.tambak.desc);
  late Map<String, bool> preference = {
    "pH": widget.tambak.pH,
    "Suhu": widget.tambak.Suhu,
    "Salinitas": widget.tambak.Salinitas,
    "Ketinggian": widget.tambak.Ketinggian,
    "Oksigen": widget.tambak.Oksigen,
    "Kekeruhan": widget.tambak.Kekeruhan,
  };

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) {
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

    await widget.tambak
        .updateTambak(nameController.text, descController.text, preference);

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Tambak berhasil diubah')));
    Navigator.of(context).pop(true);
  }

  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ubah Data Tambak"),
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
                      controller: nameController,
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
