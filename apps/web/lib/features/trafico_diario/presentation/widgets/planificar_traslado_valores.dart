import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';

/// Calcula los textos que se muestran en la rejilla de planificación
/// a partir del traslado y de los datos auxiliares cargados en la página.
class PlanificarTrasladoValores {
  const PlanificarTrasladoValores({
    required this.serviciosPorTraslado,
    required this.localidadesPorId,
    required this.personalPorId,
    required this.localidadesPorNombreHospital,
  });

  static const String _domicilio = 'domicilio_paciente';
  static const String _hospital = 'centro_hospitalario';

  final Map<String, ServicioEntity> serviciosPorTraslado;
  final Map<String, String> localidadesPorId;
  final Map<String, String> personalPorId;
  final Map<String, String> localidadesPorNombreHospital;

  PacienteEntity? _paciente(TrasladoEntity t) => serviciosPorTraslado[t.id]?.paciente;

  bool esIda(TrasladoEntity t) => (t.tipoTraslado ?? '').toUpperCase() == 'IDA';

  String tipo(TrasladoEntity t) => (t.tipoTraslado ?? '').toUpperCase();

  String paciente(TrasladoEntity t) {
    final PacienteEntity? p = _paciente(t);
    if (p == null) {
      return '';
    }
    final String segundo = p.segundoApellido != null ? ' ${p.segundoApellido}' : '';
    return '${p.nombre} ${p.primerApellido}$segundo'.toUpperCase();
  }

  String _domicilioDe(String? tipoUbicacion, TrasladoEntity t) =>
      tipoUbicacion == _domicilio ? (_paciente(t)?.domicilioDireccion ?? '').toUpperCase() : 'HOSPITAL';

  String _localidadDe(String? tipoUbicacion, String? valor, TrasladoEntity t) {
    if (tipoUbicacion == _domicilio) {
      final String? localidadId = _paciente(t)?.localidadId;
      return localidadId != null ? (localidadesPorId[localidadId] ?? '').toUpperCase() : '';
    }
    if (valor != null && valor.isNotEmpty) {
      return (localidadesPorNombreHospital[valor] ?? '').toUpperCase();
    }
    return '';
  }

  String _nombreDe(String? tipoUbicacion, String? valor) =>
      tipoUbicacion == _hospital && valor != null && valor.isNotEmpty ? valor.toUpperCase() : 'DOMICILIO';

  String domicilioOrigen(TrasladoEntity t) => _domicilioDe(t.tipoOrigen, t);

  String domicilioDestino(TrasladoEntity t) => _domicilioDe(t.tipoDestino, t);

  String localidadOrigen(TrasladoEntity t) => _localidadDe(t.tipoOrigen, t.origen, t);

  String localidadDestino(TrasladoEntity t) => _localidadDe(t.tipoDestino, t.destino, t);

  String origen(TrasladoEntity t) => _nombreDe(t.tipoOrigen, t.origen);

  String destino(TrasladoEntity t) => _nombreDe(t.tipoDestino, t.destino);

  String terapia(TrasladoEntity t) => (serviciosPorTraslado[t.id]?.motivoTraslado?.nombre ?? '').toUpperCase();

  String conductor(TrasladoEntity t) {
    if (t.idConductor == null) {
      return '';
    }
    return (personalPorId[t.idConductor!] ?? t.conductorNombre ?? '').toUpperCase();
  }

  String matricula(TrasladoEntity t) => (t.matriculaVehiculo ?? '').toUpperCase();
}
