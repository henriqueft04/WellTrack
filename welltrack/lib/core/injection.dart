import 'package:get_it/get_it.dart';
import 'package:welltrack/services/mental_state_service.dart';
import 'package:welltrack/services/navigation_service.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // Register repositories
  getIt.registerLazySingleton<MentalStateRepository>(() => LocalMentalStateRepository());
  
  // Register services
  getIt.registerLazySingleton<MentalStateService>(() => MentalStateService(getIt()));
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
}

// Helper methods for easy access
T locate<T extends Object>() => getIt.get<T>(); 