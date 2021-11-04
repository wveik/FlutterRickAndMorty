import 'dart:convert';

import 'package:rick_and_morty/core/error/exception.dart';
import 'package:rick_and_morty/feature/data/models/person_model.dart';
import 'package:http/http.dart' as http;

abstract class PersonRemoteDataSource {
  /// Вызываем url https://rickandmortyapi.com/api/character/?page=1
  ///
  /// Throws a [ServerException] for all error codes.
  Future<List<PersonModal>> getAllPersons(int page);

  /// Вызываем url https://rickandmortyapi.com/api/character/?name=rick
  ///
  /// Throws a [ServerException] for all error codes.
  Future<List<PersonModal>> searchPerson(String query);
}

enum PersonUrlTypeEnum { getAllPersons, searchPerson }

class PersonRemoteDataSourceImpl implements PersonRemoteDataSource {
  final http.Client client;

  PersonRemoteDataSourceImpl({required this.client});

  @override
  Future<List<PersonModal>> getAllPersons(int page) => _getPersonFromUrl(
      'https://rickandmortyapi.com/api/character/?page=$page',
      PersonUrlTypeEnum.getAllPersons);

  @override
  Future<List<PersonModal>> searchPerson(String query) => _getPersonFromUrl(
      'https://rickandmortyapi.com/api/character/?name=$query',
      PersonUrlTypeEnum.searchPerson);

  Future<List<PersonModal>> _getPersonFromUrl(
      String url, PersonUrlTypeEnum type) async {

    print(url);

    final String errorPrefix = type == PersonUrlTypeEnum.getAllPersons
        ? 'Ошибка получение персонажей по страницам. '
        : 'Ошибка получение персонажей по запросу. ';

    final response = await client
        .get(Uri.parse(url), headers: {'Content-Type': 'application/json'});

    final statusCode = response.statusCode;
    if (statusCode != 200)
      throw ServerException(errorMessage: errorPrefix + 'Получен статус код от сервера: \"$statusCode\"');

    final persons = json.decode(response.body);

    final List<dynamic> personList = (persons['results'] as List);

    return personList.map((person) => PersonModal.fromJson(person)).toList();
  }
}
