import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //definisi variabel
  final List<String> bahasa = ['Statistika', 'Informatika', 'Kedokteran', 'Akuntan', 'Manajemen'];
  bool? pilih1 = false;
  bool? pilih2 = false;
  bool? pilih3 = false;
  bool? pilih4 = false;
  bool? pilih5 = false;
  List<int> list = [];

  //definisi logika pemilihan
  void onChanged1(bool? value) {
    setState(() {
      this.pilih1 = value;
    });
    if (value == true)
      list.add(0);
    else
      list.remove(0);
    print(list);
  }

  void onChanged2(bool? value) {
    setState(() {
      this.pilih2 = value;
    });
    if (value == true)
      list.add(1);
    else
      list.remove(1);
    print(list);
  }

  void onChanged3(bool? value) {
    setState(() {
      this.pilih3 = value;
    });
    if (value == true)
      list.add(2);
    else
      list.remove(2);
    print(list);
  }

  void onChanged4(bool? value) {
    setState(() {
      this.pilih4 = value;
    });
    if (value == true)
      list.add(3);
    else
      list.remove(3);
    print(list);
  }

  void onChanged5(bool? value) {
    setState(() {
      this.pilih5 = value;
    });
    if (value == true)
      list.add(4);
    else
      list.remove(4);
    print(list);
  }

  @override
  Widget build(BuildContext context) {
    //tampilan ui
    return Scaffold(
      appBar: AppBar(
        title: Text('Demo Checkbox'),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Text('Prodi Yang kamu pilih : '),
            //Checkbox 1
            Row(
              children: <Widget>[
                Checkbox(
                  value: this.pilih1,
                  onChanged: (bool? value) {
                    onChanged1(value);
                  },
                ),
                Container(width:8.0,),
                Text(this.bahasa[0]),
              ],
            ),

            //Checkbox 2
            Row(
              children: <Widget>[
                Checkbox(
                  value: this.pilih2,
                  onChanged: (bool? value) {
                    onChanged2(value);
                  },
                ),
                Container(width:8.0,),
                Text(this.bahasa[1]),
              ],
            ),

             //Checkbox 3
            Row(
              children: <Widget>[
                Checkbox(
                  value: this.pilih3,
                  onChanged: (bool? value) {
                    onChanged3(value);
                  },
                ),
                Container(width:8.0,),
                Text(this.bahasa[2]),
              ],
            ),

            //Checkbox 4
            Row(
              children: <Widget>[
                Checkbox(
                  value: this.pilih4,
                  onChanged: (bool? value) {
                    onChanged4(value);
                  },
                ),
                Container(width:8.0,),
                Text(this.bahasa[3]),
              ],
            ),

            //Checkbox 5
            Row(
              children: <Widget>[
                Checkbox(
                  value: this.pilih5,
                  onChanged: (bool? value) {
                    onChanged5(value);
                  },
                ),
                Container(width:8.0,),
                Text(this.bahasa[4]),
              ],
            ),

          ],
        ),
      ),
    );
  }
}