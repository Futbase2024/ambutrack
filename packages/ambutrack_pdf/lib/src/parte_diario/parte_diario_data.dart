import 'package:pdf/widgets.dart' as pw;

/// Datos de la empresa para la cabecera del parte
class EmpresaParte {
  const EmpresaParte({
    required this.nombre,
    this.razonSocial,
    this.direccion,
    this.telefono,
    this.cif,
    this.logo,
  });

  final String nombre;
  final String? razonSocial;
  final String? direccion;
  final String? telefono;
  final String? cif;

  /// Logo ya cargado (ver `ParteDiarioPdf.cargarLogo`). Sin logo se muestra el nombre.
  final pw.ImageProvider? logo;
}

/// Fila de la tabla de servicios (hoja 1)
class ServicioParte {
  const ServicioParte({
    required this.paciente,
    required this.domicilio,
    required this.origen,
    required this.destino,
    required this.horaRecogida,
    required this.horaFinal,
    required this.entidad,
  });

  final String paciente;
  final String domicilio;
  final String origen;
  final String destino;
  final String horaRecogida;
  final String horaFinal;
  final String entidad;
}

/// Punto del checklist del vehículo (hoja 2)
class ChecklistParte {
  const ChecklistParte({
    required this.nombre,
    required this.correcto,
    this.observacion,
  });

  final String nombre;
  final bool correcto;
  final String? observacion;
}

/// Todo lo que se pinta en el parte diario de una persona y un turno.
///
/// Todos los textos llegan ya formateados (MAYÚSCULAS, horas `HH:mm`,
/// números sin decimales salvo litros/importe); el renderizado no calcula nada.
class ParteDiarioData {
  const ParteDiarioData({
    required this.empresa,
    required this.tecnico,
    required this.fecha,
    this.rol = '',
    this.companero = '',
    this.matricula = '',
    this.horaEntrada = '',
    this.horaSalida = '',
    this.kmEntrada = '',
    this.kmSalida = '',
    this.kmRecorridos = '',
    this.gasoleoLitros = '',
    this.importe = '',
    this.numServicios = '',
    this.revisadoControles = false,
    this.servicios = const <ServicioParte>[],
    this.incidencias = const <String>[],
    this.numerosP10 = '',
    this.checklist = const <ChecklistParte>[],
    this.combustible = '',
    this.declaracionAptitud = false,
    this.otrasIncidencias = const <String>[],
  });

  final EmpresaParte empresa;

  // Cabecera hoja 1
  final String tecnico;
  final String rol;
  final String companero;
  final String matricula;
  final String fecha;
  final String horaEntrada;
  final String horaSalida;
  final String kmEntrada;
  final String kmSalida;
  final String kmRecorridos;
  final String gasoleoLitros;
  final String importe;
  final String numServicios;
  final bool revisadoControles;

  // Cuerpo hoja 1
  final List<ServicioParte> servicios;
  final List<String> incidencias;
  final String numerosP10;

  // Hoja 2 (revisión del vehículo)
  final List<ChecklistParte> checklist;
  final String combustible;
  final bool declaracionAptitud;
  final List<String> otrasIncidencias;

  /// Hay revisión de vehículo que imprimir
  bool get tieneRevision => checklist.isNotEmpty;
}
