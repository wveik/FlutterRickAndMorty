import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:rick_and_morty/core/platform/network_info.dart';
import 'package:rick_and_morty/feature/data/datasources/person_local_data_source.dart';
import 'package:rick_and_morty/feature/data/datasources/person_remote_data_source.dart';
import 'package:rick_and_morty/feature/domain/repositories/person_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'feature/data/repositories/person_repository_impl.dart';
import 'feature/domain/usecases/get_all_persons.dart';
import 'feature/domain/usecases/search_person.dart';
import 'feature/presentation/bloc/person_list_cubit/person_list_cubit.dart';
import 'feature/presentation/bloc/search_bloc/search_bloc.dart';

import 'package:http/http.dart' as http;

final serviceLocator = GetIt.instance;

Future<void> init() async {
  // BLoC / Cubit
  serviceLocator.registerFactory(
        () => PersonListCubit(getAllPersons: serviceLocator()),
  );
  serviceLocator.registerFactory(
        () => PersonSearchBloc(searchPerson: serviceLocator()),
  );

  // UseCases
  serviceLocator.registerLazySingleton(() => GetAllPersons(serviceLocator()));
  serviceLocator.registerLazySingleton(() => SearchPerson(serviceLocator()));

  // Repository
  serviceLocator.registerLazySingleton<PersonRepository>(
        () => PersonRepositoryImpl(
      remoteDataSource: serviceLocator(),
      localDataSource: serviceLocator(),
      networkInfo: serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton<PersonRemoteDataSource>(
        () => PersonRemoteDataSourceImpl(
      client: serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton<PersonLocalDataSource>(
        () => PersonLocalDataSourceImpl(sharedPreferences: serviceLocator()),
  );

  // Core
  serviceLocator.registerLazySingleton<NetworkInfo>(
        () => NetworkInfoImp(serviceLocator()),
  );

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(() => sharedPreferences);
  serviceLocator.registerLazySingleton(() => http.Client());
  serviceLocator.registerLazySingleton(() => InternetConnectionChecker());
}