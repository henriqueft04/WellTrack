import 'package:get_it/get_it.dart';
import 'package:welltrack/services/mental_state_service.dart';
import 'package:welltrack/services/navigation_service.dart';
import 'package:welltrack/services/journal_service.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // Register services
  getIt.registerLazySingleton<MentalStateService>(() => MentalStateService());
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<JournalService>(() => JournalService());
}

// Helper methods for easy access
T locate<T extends Object>() => getIt.get<T>(); 