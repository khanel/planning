import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:planning/src/core/di/injection_container.config.dart';

final GetIt sl = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
void configureDependencies() => sl.init();