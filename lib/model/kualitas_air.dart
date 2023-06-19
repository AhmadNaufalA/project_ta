// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
import 'dart:convert';

class KualitasAir {
  final int id;
  final int id_tambak;
  final DateTime waktu;
  final num pH;
  final num Suhu;
  final num TDS;
  // final num Ketinggian;
  final num Oksigen;
  final num Kekeruhan;

  KualitasAir(
      this.id,
      this.id_tambak,
      this.waktu,
      this.pH,
      this.Suhu,
      this.TDS,
      // this.Ketinggian,
      this.Oksigen,
      this.Kekeruhan);

  //Fetch all kualitas air from API
  // static Future<List<KualitasAir>> getAll() async {
  //   final response = await http.get(Uri.parse('$baseUrl/kualitas-air'));

  //   //Ambil array kualitas air dari field data
  //   final List dataArray = jsonDecode(response.body)['data'];

  //   //Ubah tiap elemen dari field data jadi class KualitasAir, hasilnya Iterable of KualitasAir
  //   final kualitasAirArray = dataArray.map((data) => KualitasAir.fromMap(data));

  //   //Return List of KualitasAir
  //   return kualitasAirArray.toList();
  // }

  //Fetch latest kualitas air from API
  // static Future<KualitasAir> getLatest() async {
  //   final response = await http.get(Uri.parse('$baseUrl/kualitas-air/single'));

  //   final decodedBody = jsonDecode(response.body);

  //   //Return List of KualitasAir
  //   return KualitasAir.fromMap(decodedBody['data']);
  // }

  // //Fetch kualitas air from API with certain date
  // static Future<KualitasAir?> getSingle(DateTime waktu) async {
  //   final waktuString = '${waktu.year}-${waktu.month}-${waktu.day}';
  //   final response = await http
  //       .get(Uri.parse('$baseUrl/kualitas-air/single?date=$waktuString'));

  //   try {
  //     final decodedBody = jsonDecode(response.body);

  //     //Return List of KualitasAir
  //     return KualitasAir.fromMap(decodedBody['data']);
  //   } catch (_) {
  //     return null;
  //   }
  // }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'id_tambak': id_tambak,
      'waktu': waktu.toString(),
      'pH': pH,
      'suhu': Suhu,
      'tds': TDS,
      // 'ketinggian': Ketinggian,
      'oksigen': Oksigen,
      'kekeruhan': Kekeruhan,
    };
  }

  factory KualitasAir.fromMap(Map<String, dynamic> map) {
    return KualitasAir(
      map['id'] as int,
      map['id_tambak'] as int,
      DateTime.parse(map['waktu']),
      map['pH'] as num,
      map['Suhu'] as num,
      map['TDS'] as num,
      // map['Ketinggian'] as num,
      map['Oksigen'] as num,
      map['Kekeruhan'] as num,
    );
  }

  String toJson() => json.encode(toMap());

  factory KualitasAir.fromJson(String source) =>
      KualitasAir.fromMap(json.decode(source) as Map<String, dynamic>);
}
