import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Localizador de servicios global usando GetIt
///
/// Este archivo maneja la inyección de dependencias de toda la aplicación.
/// Utiliza Injectable para la generación automática de código.
final GetIt getIt = GetIt.instance;

/// Módulo para registrar dependencias externas
@module
abstract class RegisterModule {
  /// Registro de SupabaseClient
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;

  /// Registro de ContratoDataSource usando factory
  @lazySingleton
  ContratoDataSource get contratoDataSource => ContratoDataSourceFactory.createSupabase();

  /// Registro de ProvinciaDataSource usando factory
  @lazySingleton
  ProvinciaDataSource get provinciaDataSource => ProvinciaDataSourceFactory.createSupabase();

  /// Registro de ComunidadAutonomaDataSource usando factory
  @lazySingleton
  ComunidadAutonomaDataSource get comunidadAutonomaDataSource => ComunidadAutonomaDataSourceFactory.createSupabase();

  /// Registro de LocalidadDataSource usando factory
  @lazySingleton
  LocalidadDataSource get localidadDataSource => LocalidadDataSourceFactory.createSupabase();

  /// Registro de UsuarioDataSource usando factory
  @lazySingleton
  UsuarioDataSource get usuarioDataSource => UsuarioDataSourceFactory.createSupabase();
}

/// Configuración de la inyección de dependencias
///
/// Esta función debe ser llamada al inicio de la aplicación
/// para registrar todas las dependencias.
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();

/// Inicializa todas las dependencias de la aplicación
///
/// Función helper que debe ser llamada en main.dart
Future<void> initializeDependencies() async {
  await configureDependencies();
}