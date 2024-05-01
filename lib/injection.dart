import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:fstory/data/data_sources/data_source.dart';
import 'package:fstory/data/repository/repository_impl.dart';
import 'package:fstory/presentation/providers/auth_notifier.dart';
import 'package:fstory/presentation/providers/story_notifier.dart';
import 'domain/repositories/repository.dart';

final locator = GetIt.instance;
Future init() async {
  locator.registerLazySingleton(() => AuthNotifier(repository: locator()));
  locator.registerLazySingleton(() => StoryNotifier(repository: locator()));

  locator
      .registerLazySingleton<DataSource>(() => DataSourceImpl(dio: locator()));

  locator.registerLazySingleton<Repository>(
      () => RepositoryImpl(dataSource: locator()));

  locator.registerLazySingleton(() => Dio());
}
