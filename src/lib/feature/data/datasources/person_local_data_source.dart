import 'dart:convert';

import 'package:rick_and_morty/core/error/exception.dart';
import 'package:rick_and_morty/feature/data/models/person_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PersonLocalDataSource {
  /// Получение из кеша [List<PersonModal>]
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<List<PersonModal>> getLastPersonsFromCache();

  /// Положить в КЕШ персонажей
  ///
  /// Throws [CacheException]
  Future<void> personsToCache(List<PersonModal> persons);
}

const CACHED_PERSONS_LIST = 'CACHED_PERSONS_LIST';

class PersonLocalDataSourceImpl implements PersonLocalDataSource {
  final SharedPreferences sharedPreferences;

  PersonLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<PersonModal>> getLastPersonsFromCache() {
    final jsonPersonsList =
    sharedPreferences.getStringList(CACHED_PERSONS_LIST);

    if (jsonPersonsList == null) {
      throw CacheException(errorMessage: 'Не удалось получить список персонажей из КЕША. Список null.');
    }

    if (jsonPersonsList.isEmpty) {
      throw CacheException(errorMessage: 'Не удалось получить список персонажей из КЕША. Список пуст.');
    }

    print('Get Persons from Cache: ${jsonPersonsList.length}');
    return Future.value(jsonPersonsList
        .map((person) => PersonModal.fromJson(json.decode(person)))
        .toList());
  }

  @override
  Future<void> personsToCache(List<PersonModal> persons) {
    final List<String> jsonPersonsList =
    persons.map((person) => json.encode(person.toJson())).toList();

    sharedPreferences.setStringList(CACHED_PERSONS_LIST, jsonPersonsList);
    print('Persons to write Cache: ${jsonPersonsList.length}');
    return Future.value(jsonPersonsList);
  }
}
