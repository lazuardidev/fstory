import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:fstory/data/datasources/data_source.dart';
import 'package:fstory/data/repository/repository_impl.dart';
import 'package:fstory/presentation/providers/auth_notifier.dart';
import 'package:fstory/presentation/providers/story_notifier.dart';
import '../../domain/repositories/repository.dart';

final locator = GetIt.instance;
Future init() async {
  // provider
  locator.registerLazySingleton(() => AuthNotifier(repository: locator()));
  locator.registerLazySingleton(() => StoryNotifier(repository: locator()));

  // repository
  locator.registerLazySingleton<Repository>(
      () => RepositoryImpl(dataSource: locator()));

  // remote data source
  locator
      .registerLazySingleton<DataSource>(() => DataSourceImpl(dio: locator()));

  // external
  locator.registerLazySingleton(() => Dio());
}
