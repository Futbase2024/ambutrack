import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Información sobre el estado de la conexión de red
///
/// Proporciona métodos para verificar si el dispositivo tiene conexión a
/// internet.
/// Utiliza internet_connection_checker para verificar la conectividad real.
abstract class NetworkInfo {
  /// Verifica si hay conexión a internet
  Future<bool> get isConnected;
}

/// Implementación de NetworkInfo usando InternetConnectionChecker
@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {

  const NetworkInfoImpl(this.connectionChecker);
  final InternetConnectionChecker connectionChecker;

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}

/// Factory para crear una instancia de InternetConnectionChecker
@module
abstract class NetworkModule {
  @lazySingleton
  InternetConnectionChecker get connectionChecker =>
      InternetConnectionChecker.instance;
}