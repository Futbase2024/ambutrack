import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ambutrack_core/ambutrack_core.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
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
import '../../features/vehiculo/data/repositories/incidencias_repository_impl.dart';
import '../../features/vehiculo/domain/repositories/incidencias_repository.dart';
import '../../features/vehiculo/presentation/bloc/incidencias/incidencias_bloc.dart';
import '../../features/vehiculo/data/repositories/checklist_vehiculo_repository_impl.dart';
import '../../features/vehiculo/domain/repositories/checklist_vehiculo_repository.dart';
import '../../features/vehiculo/presentation/bloc/checklist/checklist_bloc.dart';
import '../../features/vehiculo/presentation/bloc/vehiculo_asignado/vehiculo_asignado_bloc.dart';
import '../../features/ambulancias/data/repositories/ambulancias_repository_impl.dart';
import '../../features/ambulancias/domain/repositories/ambulancias_repository.dart';
import '../../features/ambulancias/presentation/bloc/ambulancias_bloc.dart';
import '../../features/ambulancias/presentation/bloc/revisiones_bloc.dart';
import '../../features/vehiculo/data/repositories/stock_repository_impl.dart';
import '../../features/vehiculo/domain/repositories/stock_repository.dart';
import '../../features/vehiculo/presentation/bloc/caducidades/caducidades_bloc.dart';
import '../../features/notificaciones/data/repositories/notificaciones_repository_impl.dart';
import '../../features/notificaciones/domain/repositories/notificaciones_repository.dart';
import '../../features/notificaciones/presentation/bloc/notificaciones_bloc.dart';
import '../../features/notificaciones/services/local_notifications_service.dart';

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

  // BLoC (Singleton para mantener el estado del turno globalmente)
  getIt.registerLazySingleton<RegistroHorarioBloc>(
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
    () => VacacionesBloc(
      getIt<VacacionesRepository>(),
      getIt<NotificacionesRepository>(),
      getIt<AuthBloc>(),
    ),
  );

  getIt.registerFactory<AusenciasBloc>(
    () => AusenciasBloc(
      getIt<AusenciasRepository>(),
      getIt<TiposAusenciaRepository>(),
      getIt<NotificacionesRepository>(),
      getIt<AuthBloc>(),
    ),
  );

  // ===== INCIDENCIAS VEHÍCULO =====

  // Repository
  getIt.registerLazySingleton<IncidenciasRepository>(
    () => IncidenciasRepositoryImpl(),
  );

  // BLoC (Factory para crear nueva instancia en cada página)
  getIt.registerFactory<IncidenciasBloc>(
    () => IncidenciasBloc(
      getIt<IncidenciasRepository>(),
      getIt<NotificacionesRepository>(),
      getIt<AuthBloc>(),
    ),
  );

  // ===== CHECKLIST VEHÍCULO =====

  // Repository
  getIt.registerLazySingleton<ChecklistVehiculoRepository>(
    () => ChecklistVehiculoRepositoryImpl(),
  );

  // BLoC (Factory para crear nueva instancia en cada página)
  getIt.registerFactory<ChecklistBloc>(
    () => ChecklistBloc(
      getIt<ChecklistVehiculoRepository>(),
      getIt<AuthBloc>(),
    ),
  );

  // ===== VEHÍCULO ASIGNADO =====

  // BLoC (Factory para crear nueva instancia en cada página)
  getIt.registerFactory<VehiculoAsignadoBloc>(
    () {
      final authBloc = getIt<AuthBloc>();
      final authState = authBloc.state;
      // Usar Personal ID (necesario para buscar turnos y vehículos asignados)
      // Si no hay personal, usar user.id como fallback
      final userId = authState is AuthAuthenticated
          ? (authState.personal?.id ?? authState.user.id)
          : '';
      return VehiculoAsignadoBloc(userId: userId);
    },
  );

  // ===== AMBULANCIAS =====

  // Repository
  getIt.registerLazySingleton<AmbulanciasRepository>(
    () => AmbulanciasRepositoryImpl(),
  );

  // BLoCs (Factory para crear nueva instancia en cada página)
  getIt.registerFactory<AmbulanciasBloc>(
    () => AmbulanciasBloc(getIt<AmbulanciasRepository>()),
  );

  getIt.registerFactory<RevisionesBloc>(
    () => RevisionesBloc(getIt<AmbulanciasRepository>()),
  );

  // ===== STOCK Y CADUCIDADES =====

  // Repository
  getIt.registerLazySingleton<StockRepository>(
    () => StockRepositoryImpl(),
  );

  // BLoC (Factory para crear nueva instancia en cada página)
  getIt.registerFactory<CaducidadesBloc>(
    () => CaducidadesBloc(stockRepository: getIt<StockRepository>()),
  );

  // ===== NOTIFICACIONES =====

  // Servicio de notificaciones locales (Singleton)
  getIt.registerLazySingleton<LocalNotificationsService>(
    () => LocalNotificationsService(),
  );

  // Repository
  getIt.registerLazySingleton<NotificacionesRepository>(
    () => NotificacionesRepositoryImpl(authBloc: getIt<AuthBloc>()),
  );

  // BLoC (Factory para crear nueva instancia en cada página)
  getIt.registerFactory<NotificacionesBloc>(
    () => NotificacionesBloc(
      repository: getIt<NotificacionesRepository>(),
      localNotificationsService: getIt<LocalNotificationsService>(),
    ),
  );
}
