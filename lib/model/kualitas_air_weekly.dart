// ignore_for_file: public_member_api_docs, sort_constructors_first
class KualitasAirWeekly {
  final int id;
  final DateTime waktu;
  final MapEntry<String, num> weeklyData;
  KualitasAirWeekly({
    required this.id,
    required this.waktu,
    required this.weeklyData,
  });

  // final num pH;
  // final num Suhu;
  // final num Salinitas;
  // final num Ketinggian;
  // final num Oksigen;
  // final num Kekeruhan;
}
