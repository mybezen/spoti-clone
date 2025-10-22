import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // definisi variabel dan fungsi
  bool? selected = false;

  void onTextFieldChanged(String value) {
    setState(() {
      print(value);
    });
  }

  void onCheckboxChanged(bool? value) {
    setState(() {
      selected = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Demo Checkbox'),
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                enabled: !(selected ?? false),
                onChanged: (String value) {
                  onTextFieldChanged(value);
                },
                decoration: const InputDecoration(
                    hintText: "Ketik teks di sini.",
                    hintStyle: TextStyle(fontStyle: FontStyle.italic)),
              ),
              Row(
                children: <Widget>[
                  Checkbox(value: selected, onChanged: (bool? value) {
                    onCheckboxChanged(value);
                  }),
                  const Text("Disable input box.")
                ],
              )
            ],
          ),
        ));
  }
}
