import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/app_exception.dart';
import '../models/post.dart';
import '../models/user.dart';

/// Fuente de datos remota: consume la API publica JSONPlaceholder con `http`.
///
/// Cada fallo se traduce a una [AppException]; esta clase nunca deja escapar
/// un error sin controlar.
class ApiService {
  ApiService({
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  final http.Client _client;
  final Duration timeout;

  /// GET https://jsonplaceholder.typicode.com/users
  Future<List<User>> fetchUsers() async {
    final body = await _get(Uri.parse('$baseUrl/users'));
    return _parseList(body, User.fromJson);
  }

  /// GET https://jsonplaceholder.typicode.com/posts?userId={id}
  Future<List<Post>> fetchPostsByUser(int userId) async {
    final uri = Uri.parse('$baseUrl/posts')
        .replace(queryParameters: {'userId': '$userId'});
    final body = await _get(uri);
    return _parseList(body, Post.fromJson);
  }

  /// Hace la peticion y devuelve el cuerpo, o lanza una [AppException].
  Future<String> _get(Uri uri) async {
    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(timeout);
    } on SocketException {
      throw const NoInternetException();
    } on TimeoutException {
      throw const TimeoutAppException();
    } on http.ClientException {
      // Fallo de red de bajo nivel (host no encontrado, conexion rechazada...).
      throw const NoInternetException();
    } catch (_) {
      throw const UnknownException();
    }

    if (response.statusCode != 200) {
      throw ServerException(response.statusCode);
    }
    // bodyBytes + utf8 evita problemas de acentos si falta el charset.
    return utf8.decode(response.bodyBytes, allowMalformed: true);
  }

  /// Convierte el JSON (una lista) en objetos; si el formato no es el
  /// esperado lanza [DataException].
  List<T> _parseList<T>(
    String body,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! List) throw const DataException();
      return decoded
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const DataException();
    }
  }

  void close() => _client.close();
}
