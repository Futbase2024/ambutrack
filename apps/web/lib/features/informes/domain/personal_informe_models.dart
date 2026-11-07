import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/informes/domain/informe_models.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';

/// Datos en bruto del informe de personal
class PersonalInformeRaw {
  const PersonalInformeRaw({
    required this.personal,
    required this.bases,
    required this.tiposAusencia,
    required this.ausencias,
    required this.vacaciones,
    required this.formaciones,
    required this.registros,
    required this.traslados,
  });

  final List<PersonalEntity> personal;
  final List<BaseCentroEntity> bases;
  final List<TipoAusenciaEntity> tiposAusencia;
  final List<AusenciaEntity> ausencias;
  final List<VacacionesEntity> vacaciones;
  final List<FormacionPersonalEntity> formaciones;
  final List<RegistroHorarioEntity> registros;
  final List<TrasladoEntity> traslados;
}

/// Fila del desglose por empleado
class PersonalInformeFila {
  const PersonalInformeFila({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.base,
    required this.servicios,
    required this.horas,
    required this.diasAusencia,
    required this.diasVacaciones,
    required this.formacionVencida,
    required this.formacionProxima,
  });

  final String id;
  final String nombre;
  final String categoria;
  final String base;
  final int servicios;
  final double horas;
  final int diasAusencia;
  final int diasVacaciones;
  final int formacionVencida;
  final int formacionProxima;
}

/// Datos agregados del informe de personal
class PersonalInformeData {
  const PersonalInformeData({
    required this.kpis,
    required this.ausenciasPorTipo,
    required this.horasPorCategoria,
    required this.filas,
    required this.categorias,
    required this.bases,
  });

  final List<InformeKpi> kpis;
  final List<InformeBarItem> ausenciasPorTipo;
  final List<InformeBarItem> horasPorCategoria;
  final List<PersonalInformeFila> filas;

  /// Opciones de filtro
  final List<String> categorias;

  /// id → nombre de base
  final Map<String, String> bases;
}
