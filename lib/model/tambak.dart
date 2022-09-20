// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:projectta/model/kualitas_air.dart';
import 'package:projectta/model/kualitas_air_weekly.dart';
import 'package:projectta/model/log.dart';
import 'package:projectta/utils/constants.dart';
import 'package:projectta/utils/date_to_string.dart';

class Tambak {
  final int id;
  final String name;
  final String desc;
  final bool pH;
  final bool Suhu;
  final bool Salinitas;
  final bool Ketinggian;
  final bool Oksigen;
  final bool Kekeruhan;
  final bool? status;

  Tambak(
    this.id,
    this.name,
    this.desc,
    this.pH,
    this.Suhu,
    this.Salinitas,
    this.Ketinggian,
    this.Oksigen,
    this.Kekeruhan,
    this.status,
  );

  //Fetch all tambak from API
  static Future<List<Tambak>> getAll(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/tambak/user/$userId'));

    //Ambil array kualitas air dari field data
    final List dataArray = jsonDecode(response.body)['data'];

    //Ubah tiap elemen dari field data jadi class KualitasAir, hasilnya Iterable of KualitasAir
    final tambakArray = dataArray.map((data) => Tambak.fromMap(data));

    //Return List of KualitasAir
    return tambakArray.toList();
  }

  static Future<Tambak> get(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/tambak/$id'));

    final decodedBody = jsonDecode(response.body);

    //Return List of Tambak
    return Tambak.fromMap(decodedBody['data']);
  }

  // //Fetch latest kualitas air from API
  Future<KualitasAir?> getLatest() async {
    final response = await http.get(Uri.parse('$baseUrl/tambak/$id'));

    final decodedBody = jsonDecode(response.body);

    //Return List of Tambak
    try {
      return KualitasAir.fromMap(decodedBody['kualitasAir']);
    } catch (e) {
      return null;
    }
  }

  //Fetch kualitas air from API with certain date
  Future<KualitasAir?> getSingle(DateTime waktu) async {
    final waktuString = dateToString(waktu);
    final response =
        await http.get(Uri.parse('$baseUrl/tambak/$id?date=$waktuString'));

    try {
      final decodedBody = jsonDecode(response.body);

      //Return List of Tambak
      return KualitasAir.fromMap(decodedBody['kualitasAir']);
    } catch (_) {
      return null;
    }
  }

  //Fetch kualitas air from API with 2 between dates
  Future<List<KualitasAirWeekly>> getBetween(
      DateTime toDate, String columnName) async {
    final from = toDate.subtract(const Duration(days: 6));
    final to = toDate.add(const Duration(days: 1));
    // final to = widget.settings.toDate.add(const Duration(days: 1));
    final fromString = '${from.year}-${from.month}-${from.day}';
    final toString = '${to.year}-${to.month}-${to.day}';

    final url =
        '$baseUrl/tambak/between/$id?from=$fromString&to=$toString&column=$columnName';
    final response = await http.get(Uri.parse(url));
    final List dataArray = jsonDecode(response.body)['data'];

    return dataArray.map((data) {
      return KualitasAirWeekly(
          id: data['id'] as int,
          waktu: DateTime.parse(data['waktu'] as String),
          weeklyData: MapEntry(columnName, data[columnName] as num));
    }).toList();
  }

  Future<List<Log>> getLogs() async {
    final url = '$baseUrl/tambak/logs/$id';
    final response = await http.get(Uri.parse(url));
    final List dataArray = jsonDecode(response.body)['data'];

    return dataArray.map((data) => Log.fromMap(data)).toList();
  }

  static Future<void> createTambak(String name, String desc, int userId,
      Map<String, bool> preference) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/tambak'));

    final convertedPreference =
        preference.map((key, value) => MapEntry(key, value ? "1" : "0"));
    request.fields.addAll({
      'name': name,
      'desc': desc,
      'id_user': userId.toString(),
      ...convertedPreference
    });

    await request.send();
  }

  Future<void> updateTambak(
      String name, String desc, Map<String, bool> preference) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/tambak/$id'));

    final convertedPreference =
        preference.map((key, value) => MapEntry(key, value ? "1" : "0"));
    request.fields.addAll({'name': name, 'desc': desc, ...convertedPreference});

    await request.send();
  }

  Future<void> deleteTambak() async {
    await http.delete(Uri.parse('$baseUrl/tambak/$id'));
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'desc': desc,
      'pH': pH ? "1" : "0",
      'Suhu': Suhu ? "1" : "0",
      'Salinitas': Salinitas ? "1" : "0",
      'Ketinggian': Ketinggian ? "1" : "0",
      'Oksigen': Oksigen ? "1" : "0",
      'Kekeruhan': Kekeruhan ? "1" : "0",
    };
  }

  factory Tambak.fromMap(Map<String, dynamic> map) {
    return Tambak(
      map['id'] as int,
      map['name'] as String,
      map['desc'] as String,
      map['status'] as bool,
      (map['pH'] as int) == 1,
      (map['Suhu'] as int) == 1,
      (map['Salinitas'] as int) == 1,
      (map['Ketinggian'] as int) == 1,
      (map['Oksigen'] as int) == 1,
      (map['Kekeruhan'] as int) == 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory Tambak.fromJson(String source) =>
      Tambak.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Tambak(id: $id, name: $name, desc: $desc)';
}
