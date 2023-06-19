import 'package:flutter/material.dart';

import '../model/tambak.dart';

class TambakCard extends StatelessWidget {
  const TambakCard({Key? key, required this.tambak, required this.onDelete})
      : super(key: key);

  final Tambak tambak;
  final Function onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Navigator.of(context).pushNamed('/detail', arguments: tambak);
        onDelete();
      },
      child: Material(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(height: 10),
            Image.asset(
              'images/icond.jpg',
              height: 100,
              width: 100,
            ),
            SizedBox(height: 10),
            Text(
              tambak.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              (tambak.status ?? false) ? "Tidak Optimal" : "Optimal",
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 26),
            ),
          ]),
        ),
      ),
      // Card(
      //     elevation: 5,
      //     margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      //     child: Padding(
      //       padding: const EdgeInsets.all(30),
      //       child: Row(
      //         children: <Widget>[
      //           Container(
      //             margin: const EdgeInsets.only(right: 30),
      //             child: const Icon(Icons.adb),
      //           ),
      //           Flexible(
      //             child: Text(
      //               tambak.name,
      //               overflow: TextOverflow.ellipsis,
      //             ),
      //           ),
      //           Text(
      //             (tambak.status ?? false) ? "Tidak optimal" : "Optimal",
      //             textAlign: TextAlign.right,
      //           )
      //         ],
      //       ),
      //     )),
    );
  }
}
