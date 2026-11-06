// Pruebas de la capa de datos remota: modelos y ApiService.
// Usan MockClient (incluido en el paquete http), no necesitan Internet.
//
// Ejecutar con:  flutter test

import 'dart:convert';
import 'dart:io';

import 'package:directorio_app/core/app_exception.dart';
import 'package:directorio_app/data/models/user.dart';
import 'package:directorio_app/data/remote/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _userJson = {
  'id': 1,
  'name': 'Leanne Graham',
  'username': 'Bret',
  'email': 'Sincere@april.biz',
  'address': {
    'street': 'Kulas Light',
    'suite': 'Apt. 556',
    'city': 'Gwenborough',
    'zipcode': '92998-3874',
    'geo': {'lat': '-37.3159', 'lng': '81.1496'},
  },
  'phone': '1-770-736-8031 x56442',
  'website': 'hildegard.org',
  'company': {
    'name': 'Romaguera-Crona',
    'catchPhrase': 'Multi-layered client-server neural-net',
    'bs': 'harness real-time e-markets',
  },
};

const _postJson = {
  'userId': 1,
  'id': 1,
  'title': 'sunt aut facere',
  'body': 'quia et suscipit',
};

ApiService _serviceWith(MockClientHandler handler,
        {Duration timeout = const Duration(seconds: 10)}) =>
    ApiService(client: MockClient(handler), timeout: timeout);

void main() {
  group('User', () {
    test('lee nombre, correo y company.name desde el JSON', () {
      final user = User.fromJson(_userJson);
      expect(user.id, 1);
      expect(user.name, 'Leanne Graham');
      expect(user.email, 'Sincere@april.biz');
      expect(user.companyName, 'Romaguera-Crona');
      expect(user.initials, 'LG');
    });

    test('toJson -> fromJson conserva los datos (persistencia)', () {
      final original = User.fromJson(_userJson);
      final copy = User.fromJson(
        jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
      );
      expect(copy.id, original.id);
      expect(copy.name, original.name);
      expect(copy.email, original.email);
      expect(copy.companyName, original.companyName);
      expect(copy.city, original.city);
    });
  });

  group('ApiService', () {
    test('fetchUsers devuelve la lista cuando la respuesta es 200', () async {
      final api = _serviceWith((request) async {
        expect(request.url.toString(),
            'https://jsonplaceholder.typicode.com/users');
        return http.Response(jsonEncode([_userJson]), 200);
      });
      final users = await api.fetchUsers();
      expect(users, hasLength(1));
      expect(users.first.companyName, 'Romaguera-Crona');
    });

    test('fetchPostsByUser usa /posts?userId={id}', () async {
      final api = _serviceWith((request) async {
        expect(request.url.path, '/posts');
        expect(request.url.queryParameters['userId'], '1');
        return http.Response(jsonEncode([_postJson]), 200);
      });
      final posts = await api.fetchPostsByUser(1);
      expect(posts.single.title, 'sunt aut facere');
    });

    test('sin Internet lanza NoInternetException', () async {
      final api = _serviceWith(
        (_) async => throw const SocketException('Failed host lookup'),
      );
      await expectLater(api.fetchUsers(), throwsA(isA<NoInternetException>()));
    });

    test('ClientException tambien se trata como sin Internet', () async {
      final api = _serviceWith(
        (_) async => throw http.ClientException('Connection refused'),
      );
      await expectLater(api.fetchUsers(), throwsA(isA<NoInternetException>()));
    });

    test('codigo distinto de 200 lanza ServerException', () async {
      final api = _serviceWith((_) async => http.Response('error', 500));
      await expectLater(
        api.fetchUsers(),
        throwsA(isA<ServerException>()
            .having((e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('JSON invalido lanza DataException', () async {
      final api = _serviceWith((_) async => http.Response('<html>', 200));
      await expectLater(api.fetchUsers(), throwsA(isA<DataException>()));
    });

    test('respuesta lenta lanza TimeoutAppException', () async {
      final api = _serviceWith(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          return http.Response('[]', 200);
        },
        timeout: const Duration(milliseconds: 50),
      );
      await expectLater(api.fetchUsers(), throwsA(isA<TimeoutAppException>()));
    });
  });
}
