// ignore_for_file: use_build_context_synchronously

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:projectta/model/kualitas_air.dart';
import 'package:projectta/model/tambak.dart';
import 'package:projectta/model/weekly_settings.dart';
import 'package:projectta/utils/date_to_string.dart';
import 'package:projectta/utils/get_token.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.initialTambak}) : super(key: key);

  final Tambak initialTambak;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Tambak tambak = widget.initialTambak;
  KualitasAir? currentKualitas;
  DateTime? dateTime;
  bool isLoading = true;
  bool isLogOpen = false;

  List<Color> colorList = [
    const Color.fromARGB(255, 102, 255, 85),
  ];
  getTambakData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await getToken();

    if (token == null) {
      await FirebaseMessaging.instance.deleteToken();

      prefs.remove('user');

      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }
    final newKualitas = await widget.initialTambak.getLatest(token);

    if (newKualitas == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      currentKualitas = newKualitas;
      dateTime = newKualitas.waktu;
      isLoading = false;
    });
  }

  @override
  void initState() {
    getTambakData();
    super.initState();
  }

  void handleTapDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      locale: const Locale('id'),
      initialDate: dateTime ?? DateTime.now(),
      firstDate: (dateTime ?? DateTime.now()).subtract(
        const Duration(days: 120),
      ),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = await getToken();

    if (token == null) {
      await FirebaseMessaging.instance.deleteToken();

      prefs.remove('user');

      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }
    final newKualitasAir =
        await widget.initialTambak.getSingle(pickedDate, token);

    setState(() {
      dateTime = pickedDate;
      currentKualitas = newKualitasAir;
    });
  }

  void Function() navigateToWeekly(String columnName) {
    if (dateTime == null) return () {};

    return () {
      Navigator.of(context).pushNamed('/weekly', arguments: [
        WeeklySettings(toDate: dateTime!, columnName: columnName),
        widget.initialTambak
      ]);
    };
  }

  void showInfo() async {
    final result = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Deskripsi Tambak"),
            content: Text(tambak.desc),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              // TextButton(
              //   onPressed: () async {
              //     final updateResult = await Navigator.of(context)
              //         .pushNamed('/edit_tambak', arguments: tambak);
              //     // await widget.tambak.deleteTambak();
              //     Navigator.of(context).pop(updateResult);
              //   },
              //   child: const Text(
              //     "Ubah Tambak",
              //     style: TextStyle(color: Colors.blue),
              //   ),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     final prefs = await SharedPreferences.getInstance();
              //     final token = await getToken();

              //     if (token == null) {
              //       await FirebaseMessaging.instance.deleteToken();

              //       prefs.remove('user');

              //       Navigator.of(context).pushReplacementNamed('/login');
              //       return;
              //     }
              //     await widget.initialTambak.deleteTambak(token);
              //     Navigator.of(context).popUntil((route) => route.isFirst);
              //   },
              //   child: const Text(
              //     "Hapus Tambak",
              //     style: TextStyle(color: Colors.red),
              //   ),
              // ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  "Tutup",
                ),
              ),
            ],
          );
        });

    if (result == null) return;

    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = await getToken();

    if (token == null) {
      await FirebaseMessaging.instance.deleteToken();

      prefs.remove('user');

      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }
    final newTambak = await Tambak.get(tambak.id, token);
    setState(() {
      tambak = newTambak;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
          title: Text(tambak.name),
          centerTitle: true,
          backgroundColor: Colors.greenAccent[700],
          elevation: 0.0,
          actions: [
            IconButton(onPressed: showInfo, icon: const Icon(Icons.info))
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // if (currentKualitas != null)
                  GestureDetector(
                    onTap: handleTapDate,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        dateToString(dateTime ?? DateTime.now()),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: MaterialButton(
                              color: Colors.white,
                              onPressed: () => Navigator.of(context).pushNamed(
                                  '/log',
                                  arguments: widget.initialTambak),
                              child: const Text("Log"),
                            ),
                          ),
                          if (currentKualitas == null)
                            const Center(
                              child: Text(
                                  'Tidak ada pemantauan pada tanggal yang dipilih'),
                            )
                          else
                            GridView.count(
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: <Widget>[
                                if (tambak.pH)
                                  InkWell(
                                    onTap: navigateToWeekly('pH'),
                                    child: Card(
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:
                                              SfRadialGauge(axes: <RadialAxis>[
                                            RadialAxis(
                                                minimum: 2,
                                                maximum: 14,
                                                ranges: <GaugeRange>[
                                                  GaugeRange(
                                                      startValue: 2,
                                                      endValue: 6.5,
                                                      color: Colors.yellow),
                                                  GaugeRange(
                                                      startValue: 6.5,
                                                      endValue: 9.5,
                                                      color: Colors.lightGreen),
                                                  GaugeRange(
                                                      startValue: 9.5,
                                                      endValue: 14,
                                                      color: Colors.red)
                                                ],
                                                pointers: <GaugePointer>[
                                                  NeedlePointer(
                                                      value: currentKualitas!.pH
                                                          .toDouble())
                                                ],
                                                annotations: <GaugeAnnotation>[
                                                  GaugeAnnotation(
                                                      verticalAlignment:
                                                          GaugeAlignment.near,
                                                      widget: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .black)),
                                                              child: Text(
                                                                  '${currentKualitas!.pH}',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold))),
                                                          SizedBox(height: 3),
                                                          const Text('pH',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ],
                                                      ),
                                                      angle: 90,
                                                      positionFactor: 0.7)
                                                ])
                                          ])),
                                    ),
                                  ),
                                if (tambak.TDS)
                                  InkWell(
                                    onTap: navigateToWeekly('TDS'),
                                    child: Card(
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:
                                              SfRadialGauge(axes: <RadialAxis>[
                                            RadialAxis(
                                                minimum: 0,
                                                maximum: 4000,
                                                ranges: <GaugeRange>[
                                                  GaugeRange(
                                                      startValue: 0,
                                                      endValue: 1000,
                                                      color: Colors.yellow),
                                                  GaugeRange(
                                                      startValue: 1000,
                                                      endValue: 3000,
                                                      color: Colors.lightGreen),
                                                  GaugeRange(
                                                      startValue: 3000,
                                                      endValue: 4000,
                                                      color: Colors.red)
                                                ],
                                                pointers: <GaugePointer>[
                                                  NeedlePointer(
                                                    value: currentKualitas!.TDS
                                                        .toDouble(),
                                                  )
                                                ],
                                                annotations: <GaugeAnnotation>[
                                                  GaugeAnnotation(
                                                      verticalAlignment:
                                                          GaugeAlignment.near,
                                                      widget: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .black)),
                                                              child: Text(
                                                                  '${currentKualitas!.TDS} ppm',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold))),
                                                          SizedBox(height: 3),
                                                          const Text('TDS',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ],
                                                      ),
                                                      angle: 90,
                                                      positionFactor: 0.7)
                                                ])
                                          ])),
                                    ),
                                  ),
                                if (tambak.Oksigen)
                                  InkWell(
                                    onTap: navigateToWeekly('Oksigen'),
                                    child: Card(
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:
                                              SfRadialGauge(axes: <RadialAxis>[
                                            RadialAxis(
                                                minimum: 0,
                                                maximum: 12,
                                                ranges: <GaugeRange>[
                                                  GaugeRange(
                                                      startValue: 0,
                                                      endValue: 4,
                                                      color: Colors.yellow),
                                                  GaugeRange(
                                                      startValue: 4,
                                                      endValue: 8.5,
                                                      color: Colors.lightGreen),
                                                  GaugeRange(
                                                      startValue: 8.5,
                                                      endValue: 12,
                                                      color: Colors.red)
                                                ],
                                                pointers: <GaugePointer>[
                                                  NeedlePointer(
                                                    value: currentKualitas!
                                                        .Oksigen
                                                        .toDouble(),
                                                  )
                                                ],
                                                annotations: <GaugeAnnotation>[
                                                  GaugeAnnotation(
                                                      verticalAlignment:
                                                          GaugeAlignment.near,
                                                      widget: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .black)),
                                                              child: Text(
                                                                  '${currentKualitas!.Oksigen} ppm',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold))),
                                                          SizedBox(height: 3),
                                                          const Text('Oksigen',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ],
                                                      ),
                                                      angle: 90,
                                                      positionFactor: 0.7)
                                                ])
                                          ])),
                                    ),
                                  ),
                                if (tambak.Suhu)
                                  InkWell(
                                    onTap: navigateToWeekly('Suhu'),
                                    child: Card(
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:
                                              SfRadialGauge(axes: <RadialAxis>[
                                            RadialAxis(
                                                minimum: 23,
                                                maximum: 38.5,
                                                ranges: <GaugeRange>[
                                                  GaugeRange(
                                                      startValue: 23,
                                                      endValue: 28,
                                                      color: Colors.yellow),
                                                  GaugeRange(
                                                      startValue: 28,
                                                      endValue: 33,
                                                      color: Colors.lightGreen),
                                                  GaugeRange(
                                                      startValue: 33,
                                                      endValue: 38,
                                                      color: Colors.red)
                                                ],
                                                pointers: <GaugePointer>[
                                                  NeedlePointer(
                                                    value: currentKualitas!.Suhu
                                                        .toDouble(),
                                                  )
                                                ],
                                                annotations: <GaugeAnnotation>[
                                                  GaugeAnnotation(
                                                      verticalAlignment:
                                                          GaugeAlignment.near,
                                                      widget: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .black)),
                                                              child: Text(
                                                                  '${currentKualitas!.Suhu}'
                                                                  " °C",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold))),
                                                          SizedBox(height: 3),
                                                          const Text('Suhu',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ],
                                                      ),
                                                      angle: 90,
                                                      positionFactor: 0.7)
                                                ])
                                          ])),
                                    ),
                                  ),
                                // if (tambak.Ketinggian)
                                //   InkWell(
                                //     onTap: navigateToWeekly('Ketinggian'),
                                //     child: Card(
                                //       child: Padding(
                                //           padding: const EdgeInsets.all(8.0),
                                //           child:
                                //               SfRadialGauge(axes: <RadialAxis>[
                                //             RadialAxis(
                                //                 minimum: 0,
                                //                 maximum: 65,
                                //                 ranges: <GaugeRange>[
                                //                   GaugeRange(
                                //                       startValue: 0,
                                //                       endValue: 25,
                                //                       color: Colors.yellow),
                                //                   GaugeRange(
                                //                       startValue: 25,
                                //                       endValue: 40,
                                //                       color: Colors.lightGreen),
                                //                   GaugeRange(
                                //                       startValue: 40,
                                //                       endValue: 65,
                                //                       color: Colors.red)
                                //                 ],
                                //                 pointers: <GaugePointer>[
                                //                   NeedlePointer(
                                //                     value: currentKualitas!
                                //                         .Ketinggian
                                //                         .toDouble(),
                                //                   )
                                //                 ],
                                //                 annotations: <GaugeAnnotation>[
                                //                   GaugeAnnotation(
                                //                       verticalAlignment:
                                //                           GaugeAlignment.near,
                                //                       widget: Column(
                                //                         mainAxisSize:
                                //                             MainAxisSize.min,
                                //                         mainAxisAlignment:
                                //                             MainAxisAlignment
                                //                                 .start,
                                //                         children: [
                                //                           Container(
                                //                               padding:
                                //                                   const EdgeInsets
                                //                                       .all(4.0),
                                //                               decoration: BoxDecoration(
                                //                                   border: Border.all(
                                //                                       color: Colors
                                //                                           .black)),
                                //                               child: Text(
                                //                                   '${currentKualitas!.Ketinggian}'
                                //                                   " CM",
                                //                                   style: const TextStyle(
                                //                                       fontSize:
                                //                                           18,
                                //                                       fontWeight:
                                //                                           FontWeight
                                //                                               .bold))),
                                //                           const Text(
                                //                               'Ketinggian',
                                //                               textAlign:
                                //                                   TextAlign
                                //                                       .center,
                                //                               style: TextStyle(
                                //                                   fontSize: 18,
                                //                                   fontWeight:
                                //                                       FontWeight
                                //                                           .bold)),
                                //                         ],
                                //                       ),
                                //                       angle: 90,
                                //                       positionFactor: 0.7)
                                //                 ])
                                //           ])),
                                //     ),
                                //   ),
                                if (tambak.Kekeruhan)
                                  InkWell(
                                    onTap: navigateToWeekly('Kekeruhan'),
                                    child: Card(
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:
                                              SfRadialGauge(axes: <RadialAxis>[
                                            RadialAxis(
                                                minimum: 0,
                                                maximum: 60,
                                                ranges: <GaugeRange>[
                                                  GaugeRange(
                                                      startValue: 0,
                                                      endValue: 0,
                                                      color: Colors.yellow),
                                                  GaugeRange(
                                                      startValue: 0,
                                                      endValue: 30,
                                                      color: Colors.lightGreen),
                                                  GaugeRange(
                                                      startValue: 30,
                                                      endValue: 60,
                                                      color: Colors.red)
                                                ],
                                                pointers: <GaugePointer>[
                                                  NeedlePointer(
                                                    value: currentKualitas!
                                                        .Kekeruhan
                                                        .toDouble(),
                                                  )
                                                ],
                                                annotations: <GaugeAnnotation>[
                                                  GaugeAnnotation(
                                                      verticalAlignment:
                                                          GaugeAlignment.near,
                                                      widget: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .black)),
                                                              child: Text(
                                                                  '${currentKualitas!.Kekeruhan} NTU',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold))),
                                                          SizedBox(height: 3),
                                                          const Text(
                                                              'Kekeruhan',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ],
                                                      ),
                                                      angle: 90,
                                                      positionFactor: 0.7)
                                                ])
                                          ])),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ));
  }
}
