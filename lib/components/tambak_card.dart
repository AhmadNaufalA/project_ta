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
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: ListTile(
            leading: Icon(Icons.adb),
            title: Text(tambak.name),
            trailing: Text(
              (tambak.status ?? false) ? "Tidak optimal" : "Optimal",
              textAlign: TextAlign.right,
            ),
          ),
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
