import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ambutrack_core/ambutrack_core.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/registro_horario/data/repositories/registro_horario_repository_impl.dart';
import '../../features/registro_horario/domain/repositories/registro_horario_repository.dart';
import '../../features/registro_horario/presentation/bloc/registro_horario_bloc.dart';
import '../../features/servicios/data/repositories/traslados_repository_impl.dart';
import '../../features/servicios/domain/repositories/traslados_repository.dart';
import '../../features/servicios/presentation/bloc/traslados_bloc.dart';
import '../../features/tramites/data/repositories/ausencias_repository_impl.dart';
import '../../features/tramites/data/repositories/tipos_ausencia_repository_impl.dart';
import '../../features/tramites/data/repositories/vacaciones_repository_impl.dart';
import '../../features/tramites/domain/repositories/ausencias_repository.dart';
import '../../features/tramites/domain/repositories/tipos_ausencia_repository.dart';
import '../../features/tramites/domain/repositories/vacaciones_repository.dart';
import '../../features/tramites/presentation/bloc/ausencias_bloc.dart';
import '../../features/tramites/presentation/bloc/vacaciones_bloc.dart';

/// Localizador de servicios global usando GetIt
final GetIt getIt = GetIt.instance;

/// Configuración de la inyección de dependencias
///
/// Registra todas las dependencias manualmente.
Future<void> configureDependencies() async {
  // ===== CORE =====

  // Registro de SupabaseClient
  getIt.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // DataSources
  getIt.registerLazySingleton<PersonalDataSource>(
    () => PersonalDataSourceFactory.createSupabase(),
  );

  // ===== AUTH =====

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(),
  );

  // BLoC (Singleton para mantener el estado global de autenticación)
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      authRepository: getIt<AuthRepository>(),
      personalDataSource: getIt<PersonalDataSource>(),
    ),
  );

  // ===== REGISTRO HORARIO =====

  // Repository
  getIt.registerLazySingleton<RegistroHorarioRepository>(
    () => RegistroHorarioRepositoryImpl(),
  );

  // BLoC (Factory para crear nueva instancia en cada página)
  getIt.registerFactory<RegistroHorarioBloc>(
    () => RegistroHorarioBloc(
      registroHorarioRepository: getIt<RegistroHorarioRepository>(),
      authBloc: getIt<AuthBloc>(),
    ),
  );

  // ===== SERVICIOS/TRASLADOS =====

  // Repository (el datasource se crea internamente usando el factory del core package)
  getIt.registerLazySingleton<TrasladosRepository>(
    () => TrasladosRepositoryImpl(),
  );

  // BLoC (Factory para crear nueva instancia en cada página)
  getIt.registerFactory<TrasladosBloc>(
    () => TrasladosBloc(getIt<TrasladosRepository>()),
  );

  // ===== TRÁMITES =====

  // Repositories (el datasource se crea internamente usando el factory del core package)
  getIt.registerLazySingleton<VacacionesRepository>(
    () => VacacionesRepositoryImpl(),
  );

  getIt.registerLazySingleton<AusenciasRepository>(
    () => AusenciasRepositoryImpl(),
  );

  getIt.registerLazySingleton<TiposAusenciaRepository>(
    () => TiposAusenciaRepositoryImpl(),
  );

  // BLoCs (Factory para crear nueva instancia en cada página)
  getIt.registerFactory<VacacionesBloc>(
    () => VacacionesBloc(getIt<VacacionesRepository>()),
  );

  getIt.registerFactory<AusenciasBloc>(
    () => AusenciasBloc(
      getIt<AusenciasRepository>(),
      getIt<TiposAusenciaRepository>(),
    ),
  );
}
