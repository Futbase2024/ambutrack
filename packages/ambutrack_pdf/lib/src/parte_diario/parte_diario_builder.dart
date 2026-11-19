import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import 'parte_diario_data.dart';
import 'parte_formato.dart';

/// Estados que no se pintan en la tabla de servicios (van a incidencias)
const Set<EstadoTraslado> _estadosFueraDeTabla = <EstadoTraslado>{
  EstadoTraslado.noRealizado,
  EstadoTraslado.cancelado,
  EstadoTraslado.suspendido,
  EstadoTraslado.anulado,
};

/// Construye los partes diarios de una persona a partir de las entities del día.
///
/// Se genera **un parte por vehículo**: los inicios de turno seguidos con la
/// misma ambulancia (p. ej. repetido o con otro rol) se juntan en un solo parte;
/// si la persona cambia de vehículo sale otro. Fichajes, traslados, repostajes e
/// incidencias se reparten por la hora en que ocurrieron.
///
/// [soloInicioId]: devuelve únicamente el parte que contiene ese inicio.
class ParteDiarioBuilder {
  const ParteDiarioBuilder._();

  static List<ParteDiarioData> construirDia({
    required String personalId,
    required String personalNombre,
    required DateTime dia,
    required EmpresaParte empresa,
    required List<InicioTurnoEntity> inicios,
    required List<RegistroHorarioEntity> fichajes,
    required List<TrasladoEntity> traslados,
    List<ConsumoCombustibleEntity> repostajes = const <ConsumoCombustibleEntity>[],
    List<IncidenciaVehiculoEntity> incidencias = const <IncidenciaVehiculoEntity>[],
    Map<String, String> nombresCentros = const <String, String>{},
    String? soloInicioId,
  }) {
    final List<List<InicioTurnoEntity>> grupos = _agrupar(inicios);
    final List<InicioTurnoEntity?> turnos = grupos.isEmpty
        ? <InicioTurnoEntity?>[null]
        : grupos.map((List<InicioTurnoEntity> g) => g.first).toList();
    final List<DateTime> inicioVentanas = turnos.map((InicioTurnoEntity? i) => _t(i?.createdAt)).toList();
    final Set<String> vehiculos = turnos.map((InicioTurnoEntity? i) => i?.vehiculoId).whereType<String>().toSet();

    final List<TrasladoEntity> propios = traslados.where((TrasladoEntity t) {
      return t.idPersonalConductor == personalId ||
          t.idPersonalEnfermero == personalId ||
          t.idPersonalMedico == personalId ||
          (t.idVehiculo != null && vehiculos.contains(t.idVehiculo));
    }).toList()..sort((TrasladoEntity a, TrasladoEntity b) => _t(_horaTraslado(a)).compareTo(_t(_horaTraslado(b))));

    final List<RegistroHorarioEntity> fichajesOrdenados = List<RegistroHorarioEntity>.of(fichajes)
      ..sort((RegistroHorarioEntity a, RegistroHorarioEntity b) => a.fechaHora.compareTo(b.fechaHora));

    return <ParteDiarioData>[
      for (int i = 0; i < turnos.length; i++)
        if (soloInicioId == null || grupos[i].any((InicioTurnoEntity x) => x.id == soloInicioId))
          _construirTurno(
            inicio: turnos[i],
            grupo: grupos.isEmpty ? const <InicioTurnoEntity>[] : grupos[i],
            personalId: personalId,
            personalNombre: personalNombre,
            dia: dia,
            empresa: empresa,
            fichajes: fichajesOrdenados
                .where((RegistroHorarioEntity f) => _ventana(f.fechaHora, inicioVentanas) == i)
                .toList(),
            traslados: propios.where((TrasladoEntity t) => _ventana(_horaTraslado(t), inicioVentanas) == i).toList(),
            repostajes: repostajes.where((ConsumoCombustibleEntity r) {
              final bool mio =
                  r.conductorId == personalId || (r.conductorId == null && r.vehiculoId == turnos[i]?.vehiculoId);
              return mio && _ventana(r.fecha, inicioVentanas) == i;
            }).toList(),
            incidencias: incidencias.where((IncidenciaVehiculoEntity inc) {
              return inc.vehiculoId == turnos[i]?.vehiculoId && _ventana(inc.fechaReporte, inicioVentanas) == i;
            }).toList(),
            nombresCentros: nombresCentros,
          ),
    ];
  }

  /// Inicios ordenados y agrupados: seguidos con el mismo vehículo → mismo parte
  static List<List<InicioTurnoEntity>> _agrupar(List<InicioTurnoEntity> inicios) {
    final List<InicioTurnoEntity> orden = List<InicioTurnoEntity>.of(inicios)
      ..sort((InicioTurnoEntity a, InicioTurnoEntity b) => _t(a.createdAt).compareTo(_t(b.createdAt)));
    final List<List<InicioTurnoEntity>> grupos = <List<InicioTurnoEntity>>[];
    for (final InicioTurnoEntity i in orden) {
      final InicioTurnoEntity? previo = grupos.isEmpty ? null : grupos.last.last;
      if (previo != null && i.vehiculoId != null && i.vehiculoId == previo.vehiculoId) {
        grupos.last.add(i);
      } else {
        grupos.add(<InicioTurnoEntity>[i]);
      }
    }
    return grupos;
  }

  static ParteDiarioData _construirTurno({
    required InicioTurnoEntity? inicio,
    required List<InicioTurnoEntity> grupo,
    required String personalId,
    required String personalNombre,
    required DateTime dia,
    required EmpresaParte empresa,
    required List<RegistroHorarioEntity> fichajes,
    required List<TrasladoEntity> traslados,
    required List<ConsumoCombustibleEntity> repostajes,
    required List<IncidenciaVehiculoEntity> incidencias,
    required Map<String, String> nombresCentros,
  }) {
    final RegistroHorarioEntity? entrada = _entrada(fichajes, inicio?.registroEntradaId);
    // km final: el del último inicio del grupo que lo tenga
    final int? kmFinal = grupo.reversed.map((InicioTurnoEntity g) => g.kmFinal).nonNulls.firstOrNull;
    final RegistroHorarioEntity? salida = entrada == null
        ? null
        : fichajes.where((RegistroHorarioEntity f) {
            return f.tipo.toLowerCase() == 'salida' && f.fechaHora.isAfter(entrada.fechaHora);
          }).firstOrNull;

    final List<TrasladoEntity> enTabla = traslados.where((TrasladoEntity t) {
      return !_estadosFueraDeTabla.contains(EstadoTraslado.fromValue(t.estado));
    }).toList();
    final int finalizados = traslados
        .where((TrasladoEntity t) => EstadoTraslado.fromValue(t.estado) == EstadoTraslado.finalizado)
        .length;

    final double litros = repostajes.fold<double>(0, (double s, ConsumoCombustibleEntity r) => s + r.litros);
    final double importe = repostajes.fold<double>(0, (double s, ConsumoCombustibleEntity r) => s + r.costoTotal);

    return ParteDiarioData(
      empresa: empresa,
      tecnico: ParteFormato.mayusculas(inicio?.personalNombre ?? personalNombre),
      rol: ParteFormato.mayusculas(grupo.map((InicioTurnoEntity g) => g.rol?.label).nonNulls.toSet().join(' / ')),
      companero: ParteFormato.mayusculas(inicio?.companeroNombre),
      matricula: ParteFormato.mayusculas(inicio?.vehiculoMatricula ?? entrada?.vehiculoMatricula),
      fecha: ParteFormato.fecha(inicio?.createdAt ?? dia),
      horaEntrada: ParteFormato.hora(entrada?.fechaHora),
      horaSalida: ParteFormato.hora(salida?.fechaHora),
      kmEntrada: ParteFormato.entero(inicio?.kmInicial),
      kmSalida: ParteFormato.entero(kmFinal),
      kmRecorridos: ParteFormato.entero(_kmRecorridos(inicio?.kmInicial, kmFinal)),
      gasoleoLitros: ParteFormato.decimal(litros),
      importe: importe == 0 ? '' : '${ParteFormato.decimal(importe)} €',
      numServicios: finalizados.toString(),
      revisadoControles: inicio != null && inicio.checklistItems.isNotEmpty,
      servicios: enTabla.map((TrasladoEntity t) => _servicio(t, nombresCentros)).toList(),
      incidencias: _incidencias(traslados, incidencias),
      numerosP10: ParteFormato.mayusculas(
        grupo
            .map((InicioTurnoEntity g) => (g.numerosP10 ?? '').trim())
            .where((String n) => n.isNotEmpty)
            .toSet()
            .join(', '),
      ),
      checklist: (inicio?.checklistItems ?? const <ChecklistInicioItem>[])
          .map(
            (ChecklistInicioItem c) => ChecklistParte(
              nombre: ParteFormato.mayusculas(c.nombre),
              correcto: c.correcto,
              observacion: c.observacion,
            ),
          )
          .toList(),
      combustible: ParteFormato.mayusculas(inicio?.combustible?.label),
      declaracionAptitud: inicio?.declaracionAptitud ?? false,
      otrasIncidencias: grupo.expand(_otrasIncidencias).toSet().toList(),
    );
  }

  static ServicioParte _servicio(TrasladoEntity t, Map<String, String> centros) {
    final String tipo = ParteFormato.mayusculas(t.tipoTraslado);
    final String origen = ParteFormato.punto(tipo: t.tipoOrigen, valor: t.origen, nombresCentros: centros);
    return ServicioParte(
      paciente: ParteFormato.paciente(t.paciente),
      domicilio: ParteFormato.domicilio(t),
      origen: tipo.isEmpty ? origen : '$tipo · $origen',
      destino: ParteFormato.punto(tipo: t.tipoDestino, valor: t.destino, nombresCentros: centros),
      horaRecogida: ParteFormato.hora(t.fechaEnOrigen ?? t.horaProgramada),
      horaFinal: ParteFormato.hora(t.fechaFinalizado ?? t.fechaEnDestino),
      entidad: ParteFormato.entidad(t.paciente),
    );
  }

  static List<String> _incidencias(List<TrasladoEntity> traslados, List<IncidenciaVehiculoEntity> vehiculo) {
    final List<String> lineas = <String>[];
    for (final TrasladoEntity t in traslados) {
      final EstadoTraslado? estado = EstadoTraslado.fromValue(t.estado);
      if (estado == null || !_estadosFueraDeTabla.contains(estado)) {
        continue;
      }
      final String motivo = (t.motivoNoRealizacion ?? t.motivoCancelacion ?? '').trim();
      final String paciente = ParteFormato.paciente(t.paciente);
      lineas.add(
        <String>[
          if (paciente.isNotEmpty) paciente,
          estado.label.toUpperCase(),
          if (motivo.isNotEmpty) motivo,
        ].join(' - '),
      );
    }
    for (final IncidenciaVehiculoEntity inc in vehiculo) {
      lineas.add('VEHÍCULO: ${inc.titulo}${inc.descripcion.trim().isEmpty ? '' : ' - ${inc.descripcion.trim()}'}');
    }
    return lineas;
  }

  static int? _kmRecorridos(int? inicial, int? fin) {
    if (inicial == null || fin == null || fin < inicial) {
      return null;
    }
    return fin - inicial;
  }

  static List<String> _otrasIncidencias(InicioTurnoEntity inicio) {
    return <String>[
      for (final ChecklistInicioItem c in inicio.checklistItems)
        if (!c.correcto)
          '${ParteFormato.mayusculas(c.nombre)}${(c.observacion ?? '').trim().isEmpty ? '' : ': ${c.observacion!.trim()}'}',
      ...inicio.avisos,
      if (inicio.fueraDeBase && (inicio.motivoFueraBase ?? '').trim().isNotEmpty)
        'INICIO FUERA DE BASE: ${inicio.motivoFueraBase!.trim()}',
    ];
  }

  /// Fichaje de entrada del turno: el vinculado al inicio o la primera entrada
  static RegistroHorarioEntity? _entrada(List<RegistroHorarioEntity> fichajes, String? registroEntradaId) {
    final Iterable<RegistroHorarioEntity> entradas = fichajes.where(
      (RegistroHorarioEntity f) => f.tipo.toLowerCase() == 'entrada',
    );
    return entradas.where((RegistroHorarioEntity f) => f.id == registroEntradaId).firstOrNull ?? entradas.firstOrNull;
  }

  /// Momento del servicio: llegada a origen o fecha + hora programada
  static DateTime? _horaTraslado(TrasladoEntity t) {
    final DateTime? real = t.fechaEnOrigen;
    if (real != null) {
      return real;
    }
    final DateTime? f = t.fecha;
    final DateTime? h = t.horaProgramada?.toLocal();
    if (f != null && h != null) {
      return DateTime(f.year, f.month, f.day, h.hour, h.minute);
    }
    return f ?? h;
  }

  static DateTime _t(DateTime? d) => d ?? DateTime.fromMillisecondsSinceEpoch(0);

  /// Índice del turno al que pertenece un instante (lo anterior al primero → turno 0)
  static int _ventana(DateTime? momento, List<DateTime> inicios) {
    if (momento == null || inicios.length == 1) {
      return 0;
    }
    int indice = 0;
    for (int i = 0; i < inicios.length; i++) {
      if (!momento.isBefore(inicios[i])) {
        indice = i;
      }
    }
    return indice;
  }
}
