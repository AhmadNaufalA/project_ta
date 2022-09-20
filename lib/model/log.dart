class Log {
  final String isi;
  final String waktu;

  Log(this.isi, this.waktu);

  factory Log.fromMap(Map<String, dynamic> map) {
    return Log(
      map['isi'] as String,
      map['waktu'] as String,
    );
  }
}
