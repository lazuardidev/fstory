import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:fstory/data/datasources/data_source.dart';
import 'package:fstory/data/repository/repository_impl.dart';
import 'package:fstory/presentation/provider/auth_provider.dart';
import 'package:fstory/presentation/provider/story_provider.dart';
import '../../domain/repository/repository.dart';

final locator = GetIt.instance;
Future init() async {
  // provider
  locator.registerLazySingleton(() => AuthProvider(repository: locator()));
  locator.registerLazySingleton(() => StoryProvider(repository: locator()));

  // repository
  locator.registerLazySingleton<Repository>(
      () => RepositoryImpl(dataSource: locator()));

  // remote data source
  locator
      .registerLazySingleton<DataSource>(() => DataSourceImpl(dio: locator()));

  // external
  locator.registerLazySingleton(() => Dio());
}
