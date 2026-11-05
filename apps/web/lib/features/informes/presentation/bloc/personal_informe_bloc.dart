import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/ausencias/domain/repositories/ausencia_repository.dart';
import 'package:ambutrack_web/features/ausencias/domain/repositories/tipo_ausencia_repository.dart';
import 'package:ambutrack_web/features/cuadrante/bases/domain/repositories/bases_repository.dart';
import 'package:ambutrack_web/features/informes/domain/informe_calculos.dart';
import 'package:ambutrack_web/features/informes/domain/informe_filtro.dart';
import 'package:ambutrack_web/features/informes/domain/informe_models.dart';
import 'package:ambutrack_web/features/informes/domain/personal_informe_models.dart';
import 'package:ambutrack_web/features/informes/domain/traslado_grupo.dart';
import 'package:ambutrack_web/features/informes/presentation/bloc/informe_bloc.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/formacion_personal_repository.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/personal/horarios/domain/repositories/registro_horario_repository.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/traslado_repository.dart';
import 'package:ambutrack_web/features/vacaciones/domain/repositories/vacaciones_repository.dart';
import 'package:injectable/injectable.dart';

/// BLoC del informe de personal.
///
/// Fuentes: `tpersonal`, `bases`, `ausencias` + `tipos_ausencia`,
/// `vacaciones`, `formacion_personal`, `registros_horarios` y `traslados`.
@injectable
class PersonalInformeBloc extends InformeBloc<PersonalInformeRaw, PersonalInformeData> {
  PersonalInformeBloc(
    this._personal,
    this._bases,
    this._tiposAusencia,
    this._ausencias,
    this._vacaciones,
    this._formacion,
    this._registros,
    this._traslados,
  );

  static const String kCategoria = 'categoria';
  static const String kBase = 'base';
  static const String sinCategoria = 'Sin categoría';

  final PersonalRepository _personal;
  final BasesRepository _bases;
  final TipoAusenciaRepository _tiposAusencia;
  final AusenciaRepository _ausencias;
  final VacacionesRepository _vacaciones;
  final FormacionPersonalRepository _formacion;
  final RegistroHorarioRepository _registros;
  final TrasladoRepository _traslados;

  @override
  String get nombre => 'PersonalInformeBloc';

  @override
  Future<PersonalInformeRaw> cargar(InformeFiltro filtro) async {
    // Consultas en paralelo
    final (
      List<PersonalEntity> personal,
      List<BaseCentroEntity> bases,
      List<TipoAusenciaEntity> tipos,
      List<AusenciaEntity> ausencias,
      List<VacacionesEntity> vacaciones,
      List<FormacionPersonalEntity> formaciones,
      List<RegistroHorarioEntity> registros,
      List<TrasladoEntity> traslados,
    ) = await (
      _personal.getAll(),
      _bases.getAll(),
      _tiposAusencia.getAll(),
      _ausencias.getAll(),
      _vacaciones.getAll(),
      _formacion.getAll(),
      _registros.getByDateRange(filtro.desde, filtro.finExclusivo),
      _traslados.getByRangoFechas(desde: filtro.desde, hasta: filtro.hasta),
    ).wait;
    return PersonalInformeRaw(
      personal: personal,
      bases: bases,
      tiposAusencia: tipos,
      ausencias: ausencias,
      vacaciones: vacaciones,
      formaciones: formaciones,
      registros: registros,
      traslados: traslados,
    );
  }

  @override
  PersonalInformeData calcular(PersonalInformeRaw raw, InformeFiltro filtro) {
    final Map<String, String> bases = <String, String>{
      for (final BaseCentroEntity b in raw.bases) b.id: b.nombre,
    };
    final List<PersonalEntity> activos = raw.personal.where((PersonalEntity p) => p.activo).toList();
    final String? categoria = filtro.extra(kCategoria);
    final String? base = filtro.extra(kBase);
    final List<PersonalEntity> plantilla = activos
        .where((PersonalEntity p) => categoria == null || _categoria(p) == categoria)
        .where((PersonalEntity p) => base == null || p.baseId == base)
        .toList();
    final Set<String> ids = plantilla.map((PersonalEntity p) => p.id).toSet();

    final Map<String, double> horas = _horasPorPersona(raw.registros);
    final Map<String, int> servicios = _serviciosPorPersona(raw.traslados);
    final List<AusenciaEntity> ausencias = raw.ausencias
        .where((AusenciaEntity a) => a.activo && a.estado == EstadoAusencia.aprobada && ids.contains(a.idPersonal))
        .toList();
    final List<VacacionesEntity> vacaciones = raw.vacaciones
        .where((VacacionesEntity v) => v.activo && v.estado.toLowerCase() == 'aprobada' && ids.contains(v.idPersonal))
        .toList();
    final DateTime ahora = DateTime.now();
    final DateTime limite = ahora.add(const Duration(days: 30));

    final List<PersonalInformeFila> filas = plantilla.map((PersonalEntity p) {
      final Iterable<FormacionPersonalEntity> form =
          raw.formaciones.where((FormacionPersonalEntity f) => f.personalId == p.id);
      return PersonalInformeFila(
        id: p.id,
        nombre: p.nombreCompleto.trim().toUpperCase(),
        categoria: _categoria(p),
        base: bases[p.baseId] ?? '—',
        servicios: servicios[p.id] ?? 0,
        horas: horas[p.id] ?? 0,
        diasAusencia: ausencias
            .where((AusenciaEntity a) => a.idPersonal == p.id)
            .fold<int>(0, (int s, AusenciaEntity a) => s + _dias(filtro, a.fechaInicio, a.fechaFin)),
        diasVacaciones: vacaciones
            .where((VacacionesEntity v) => v.idPersonal == p.id)
            .fold<int>(0, (int s, VacacionesEntity v) => s + _dias(filtro, v.fechaInicio, v.fechaFin)),
        formacionVencida: form.where((FormacionPersonalEntity f) => f.fechaExpiracion.isBefore(ahora)).length,
        formacionProxima: form
            .where(
              (FormacionPersonalEntity f) => !f.fechaExpiracion.isBefore(ahora) && f.fechaExpiracion.isBefore(limite),
            )
            .length,
      );
    }).toList()
      ..sort((PersonalInformeFila a, PersonalInformeFila b) => a.nombre.compareTo(b.nombre));

    return PersonalInformeData(
      kpis: _kpis(filas),
      ausenciasPorTipo: _ausenciasPorTipo(raw, ausencias, filtro),
      horasPorCategoria: _horasPorCategoria(filas),
      filas: filas,
      categorias: activos.map(_categoria).toSet().toList()..sort(),
      bases: bases,
    );
  }

  List<InformeKpi> _kpis(List<PersonalInformeFila> filas) {
    int total(int Function(PersonalInformeFila f) v) => filas.fold<int>(0, (int s, PersonalInformeFila f) => s + v(f));
    final double horas = InformeCalculos.suma(filas, (PersonalInformeFila f) => f.horas);
    return <InformeKpi>[
      InformeKpi(label: 'Plantilla activa', valor: InformeCalculos.entero(filas.length)),
      InformeKpi(
        label: 'Servicios realizados',
        valor: InformeCalculos.entero(total((PersonalInformeFila f) => f.servicios)),
        detalle: 'Como conductor / sanitario',
      ),
      InformeKpi(
        label: 'Horas fichadas',
        valor: InformeCalculos.entero(horas),
        detalle: filas.isEmpty ? null : 'Media ${InformeCalculos.decimal(horas / filas.length)} h/persona',
      ),
      InformeKpi(
        label: 'Días de ausencia',
        valor: InformeCalculos.entero(total((PersonalInformeFila f) => f.diasAusencia)),
        detalle: 'Ausencias aprobadas',
      ),
      InformeKpi(
        label: 'Días de vacaciones',
        valor: InformeCalculos.entero(total((PersonalInformeFila f) => f.diasVacaciones)),
        detalle: 'Vacaciones aprobadas',
      ),
      InformeKpi(
        label: 'Formación vencida',
        valor: InformeCalculos.entero(total((PersonalInformeFila f) => f.formacionVencida)),
        detalle: '${total((PersonalInformeFila f) => f.formacionProxima)} vencen en 30 días',
      ),
    ];
  }

  List<InformeBarItem> _ausenciasPorTipo(
    PersonalInformeRaw raw,
    List<AusenciaEntity> ausencias,
    InformeFiltro filtro,
  ) {
    final Map<String, String> tipos = <String, String>{
      for (final TipoAusenciaEntity t in raw.tiposAusencia) t.id: t.nombre,
    };
    final Map<String, double> dias = <String, double>{};
    for (final AusenciaEntity a in ausencias) {
      final int d = InformeCalculos.diasSolapados(filtro, a.fechaInicio, a.fechaFin);
      if (d > 0) {
        final String tipo = tipos[a.idTipoAusencia] ?? 'Otro';
        dias[tipo] = (dias[tipo] ?? 0) + d;
      }
    }
    return InformeCalculos.barras(dias, (double v) => '${InformeCalculos.entero(v)} d');
  }

  List<InformeBarItem> _horasPorCategoria(List<PersonalInformeFila> filas) {
    final Map<String, double> horas = <String, double>{};
    for (final PersonalInformeFila f in filas) {
      if (f.horas > 0) {
        horas[f.categoria] = (horas[f.categoria] ?? 0) + f.horas;
      }
    }
    return InformeCalculos.barras(horas, (double v) => '${InformeCalculos.entero(v)} h');
  }

  static int _dias(InformeFiltro filtro, DateTime inicio, DateTime fin) =>
      InformeCalculos.diasSolapados(filtro, inicio, fin);

  static String _categoria(PersonalEntity p) {
    final String? c = p.categoria;
    return c == null || c.trim().isEmpty ? sinCategoria : c.trim();
  }

  /// Servicios finalizados en los que participa cada persona
  static Map<String, int> _serviciosPorPersona(List<TrasladoEntity> traslados) {
    final Map<String, int> res = <String, int>{};
    for (final TrasladoEntity t in traslados) {
      if (TrasladoGrupo.de(t) != TrasladoGrupo.finalizado) {
        continue;
      }
      final Set<String?> equipo = <String?>{t.idPersonalConductor, t.idPersonalEnfermero, t.idPersonalMedico};
      for (final String? id in equipo) {
        if (id != null) {
          res[id] = (res[id] ?? 0) + 1;
        }
      }
    }
    return res;
  }

  /// Horas fichadas por persona (horas registradas en la salida o, si no
  /// existen, diferencia entre entrada y salida consecutivas)
  static Map<String, double> _horasPorPersona(List<RegistroHorarioEntity> registros) {
    final Map<String, List<RegistroHorarioEntity>> porPersona = <String, List<RegistroHorarioEntity>>{};
    for (final RegistroHorarioEntity r in registros.where((RegistroHorarioEntity r) => r.activo)) {
      porPersona.putIfAbsent(r.personalId, () => <RegistroHorarioEntity>[]).add(r);
    }
    final Map<String, double> res = <String, double>{};
    porPersona.forEach((String id, List<RegistroHorarioEntity> lista) {
      lista.sort((RegistroHorarioEntity a, RegistroHorarioEntity b) => a.fechaHora.compareTo(b.fechaHora));
      DateTime? entrada;
      double total = 0;
      for (final RegistroHorarioEntity r in lista) {
        final String tipo = r.tipo.toLowerCase();
        if (tipo == 'entrada') {
          entrada = r.fechaHora;
        } else if (tipo == 'salida') {
          final double? h = r.horasTrabajadas;
          if (h != null && h > 0) {
            total += h;
          } else if (entrada != null) {
            total += r.fechaHora.difference(entrada).inMinutes / 60;
          }
          entrada = null;
        }
      }
      res[id] = total;
    });
    return res;
  }
}
