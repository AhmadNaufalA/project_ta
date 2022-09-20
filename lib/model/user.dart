// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:projectta/utils/constants.dart';

class User {
  final int id;
  final String username;
  final String nama;
  final String secretQuestion;
  final int secretAnswer;

  User(this.id, this.username, this.nama, this.secretQuestion,
      this.secretAnswer);

  static Future<String> register({
    required String username,
    required String nama,
    required String password,
    required String question,
    required String answer,
  }) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/user/register'));
    request.fields.addAll({
      'username': username,
      'nama': nama,
      'password': password,
      'secretQuestion': question,
      'secretAnswer': answer
    });

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      return "User berhasil dibuat, silahkan login";
    } else {
      return jsonDecode(await response.stream.bytesToString())['message'];
    }
  }

  static Future<MapEntry<bool, String>> login({
    required String username,
    required String password,
  }) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/user/login'));
    request.fields.addAll({
      'username': username,
      'password': password,
    });

    http.StreamedResponse response = await request.send();
    final responseJson = jsonDecode(await response.stream.bytesToString());

    if (response.statusCode == 200) {
      return MapEntry(false, jsonEncode(responseJson['user']));
    } else {
      return MapEntry(true, responseJson['message']);
    }
  }

  static Future<User?> getByUsername(String username) async {
    final response =
        await http.get(Uri.parse('$baseUrl/user/username/$username'));

    final decodedBody = jsonDecode(response.body);

    try {
      return User.fromMap(decodedBody['data']);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> checkAnswer(int userId, String answer) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/user/check/$userId'));
    request.fields.addAll({
      'secretAnswer': answer,
    });

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<void> resetPassword(int userId, String newPassword) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/user/reset/$userId'));
    request.fields.addAll({
      'password': newPassword,
    });

    await request.send();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'nama': nama,
      'secret_question': secretQuestion,
      'secret_answer': secretAnswer,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      map['id'] as int,
      map['username'] as String,
      map['nama'] as String,
      map['secret_question'] as String,
      map['secret_answer'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
