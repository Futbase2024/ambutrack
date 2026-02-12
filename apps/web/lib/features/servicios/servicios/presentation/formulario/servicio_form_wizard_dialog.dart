import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/di/locator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../core/widgets/dialogs/result_dialog.dart';
import '../../../../../core/widgets/dropdowns/app_searchable_dropdown.dart';
import '../../../../tablas/centros_hospitalarios/domain/repositories/centro_hospitalario_repository.dart';
import '../../../../tablas/facultativos/domain/repositories/facultativo_repository.dart';
import '../../../../tablas/localidades/domain/repositories/localidad_repository.dart';
import '../../../../tablas/motivos_traslado/domain/repositories/motivo_traslado_repository.dart';
import '../../../../tablas/tipos_vehiculo/domain/repositories/tipo_vehiculo_repository.dart';
import '../../../domain/entities/configuracion_dia.dart';
import '../../../domain/entities/configuracion_modalidad.dart';
import '../../../domain/entities/dia_semana.dart';
import '../../../pacientes/domain/repositories/paciente_repository.dart';
import '../../domain/entities/servicio_entity.dart';
import '../../domain/repositories/servicio_recurrente_repository.dart';
import '../../domain/repositories/servicio_repository.dart';
import 'logic/servicio_creator.dart';
import 'models/modalidad_servicio.dart';
import 'models/tipo_ubicacion.dart';
import 'models/trayecto_data.dart';
import 'steps/step_1_datos_generales/step_1_datos_generales.dart';
import 'steps/step_2_modalidad/step_2_modalidad.dart';
import 'steps/step_3_trayectos/step_3_trayectos.dart';
import 'steps/step_4_revision/step_4_revision.dart';

/// Wizard profesional para creación/edición de servicios programados
///
/// Orquesta 4 pasos:
/// 1. Datos Generales (paciente, tipo servicio, fechas)
/// 2. Modalidad (recurrencia)
/// 3. Trayectos (origen/destino/hora)
/// 4. Revisión Final
class ServicioFormWizardDialog extends StatefulWidget {
  const ServicioFormWizardDialog({
    super.key,
    this.paciente,
    this.servicio,
  });

  final PacienteEntity? paciente;
  final ServicioEntity? servicio; // Para modo edición

  @override
  State<ServicioFormWizardDialog> createState() => _ServicioFormWizardDialogState();
}

class _ServicioFormWizardDialogState extends State<ServicioFormWizardDialog> {
  // Control del wizard
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Estado del formulario consolidado
  // Step 1
  PacienteEntity? _pacienteSeleccionado;
  FacultativoEntity? _facultativoSeleccionado;
  DateTime? _fechaInicioTratamiento;
  DateTime? _fechaFinTratamiento;
  TimeOfDay? _horaEnCentro;
  CentroHospitalarioEntity? _centroHospitalarioPaso1; // Centro seleccionado en Paso 1 (opcional)
  String? _observacionesGenerales;
  String _observacionesMedicas = '';
  String _movilidad = 'sentado';
  int _acompanantes = 0;
  bool _requiereOxigeno = false;
  bool _requiereMedico = false;
  bool _requiereDue = false;
  bool _requiereAyudante = false;

  // Step 2
  ModalidadServicio _modalidad = ModalidadServicio.unico;
  Map<String, dynamic>? _configuracionModalidad; // Nueva arquitectura con ConfiguracionDia

  // Variables legacy (pueden eliminarse en el futuro)
  final Set<int> _diasSemanaSeleccionados = <int>{};
  int _intervaloSemanas = 2; // Cambiado de final para poder cargar en edit mode
  int _intervaloDias = 2; // Cambiado de final para poder cargar en edit mode
  final Set<int> _diasMesSeleccionados = <int>{};
  final Set<DateTime> _fechasEspecificas = <DateTime>{};

  // Step 3
  final List<TrayectoData> _trayectos = <TrayectoData>[];
  List<CentroHospitalarioEntity> _centrosHospitalarios = <CentroHospitalarioEntity>[];
  bool _loadingCentros = true;
  List<MotivoTrasladoEntity> _motivosTraslado = <MotivoTrasladoEntity>[];
  bool _loadingMotivosTraslado = true;
  MotivoTrasladoEntity? _motivoTrasladoSeleccionado;

  // Datos maestros
  List<PacienteEntity> _pacientes = <PacienteEntity>[];
  bool _loadingPacientes = true;
  List<LocalidadEntity> _localidades = <LocalidadEntity>[];
  List<TipoVehiculoEntity> _tiposVehiculo = <TipoVehiculoEntity>[];
  bool _loadingTiposVehiculo = true;
  List<FacultativoEntity> _facultativos = <FacultativoEntity>[];
  bool _loadingFacultativos = true;

  // Recursos necesarios
  String? _tipoAmbulancia;

  // Estado de guardado
  bool _isCreating = false;

  // Modo edición
  bool get _isEditMode => widget.servicio != null;

  // FormKeys para cada step
  final GlobalKey<FormState> _formKeyStep1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyStep2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyStep3 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Inicializar desde widget
    _pacienteSeleccionado = widget.paciente;

    // Cargar datos maestros PRIMERO
    _initializeData();
  }

  /// Inicializa los datos maestros y luego carga el servicio si estamos en modo edición
  Future<void> _initializeData() async {
    // Cargar todos los datos maestros en paralelo
    await Future.wait(<Future<void>>[
      _loadPacientes(),
      _loadCentrosHospitalarios(),
      _loadTiposTraslado(),
      _loadLocalidades(),
      _loadTiposVehiculo(),
      _loadFacultativos(),
    ]);

    // Una vez cargados los datos maestros, cargar el servicio si estamos en modo edición
    if (_isEditMode) {
      await _loadServicioData();
    } else {
      // Modo creación: agregar un trayecto vacío
      if (mounted) {
        setState(() {
          _trayectos.add(TrayectoData());
        });
      }
    }
  }

  @override
  void dispose() {
    for (final TrayectoData trayecto in _trayectos) {
      trayecto.dispose();
    }
    super.dispose();
  }

  // ============================================================================
  // HELPERS DE MAPEO ENTRE SISTEMAS
  // ============================================================================

  /// Mapea ModalidadServicio (sistema viejo) a TipoRecurrencia (sistema nuevo)
  TipoRecurrencia _mapModalidadToTipoRecurrencia(ModalidadServicio modalidad) {
    switch (modalidad) {
      case ModalidadServicio.unico:
        return TipoRecurrencia.unico;
      case ModalidadServicio.semanal:
      case ModalidadServicio.semanasAlternas:
        return TipoRecurrencia.semanal;
      case ModalidadServicio.diasAlternos:
        return TipoRecurrencia.diasAlternos;
      case ModalidadServicio.mensual:
        return TipoRecurrencia.mensual;
      case ModalidadServicio.especifico:
        return TipoRecurrencia.fechasEspecificas;
      case ModalidadServicio.diario:
        return TipoRecurrencia.diario;
    }
  }

  /// Mapea TipoRecurrencia (sistema nuevo) a ModalidadServicio (sistema viejo)
  ModalidadServicio _mapTipoRecurrenciaToModalidad(TipoRecurrencia tipo) {
    switch (tipo) {
      case TipoRecurrencia.unico:
        return ModalidadServicio.unico;
      case TipoRecurrencia.semanal:
        return ModalidadServicio.semanal;
      case TipoRecurrencia.diasAlternos:
        return ModalidadServicio.diasAlternos;
      case TipoRecurrencia.mensual:
        return ModalidadServicio.mensual;
      case TipoRecurrencia.fechasEspecificas:
        return ModalidadServicio.especifico;
      case TipoRecurrencia.diario:
        return ModalidadServicio.diario;
    }
  }

  // ============================================================================
  // CARGA DE DATOS MAESTROS
  // ============================================================================

  Future<void> _loadCentrosHospitalarios() async {
    try {
      final CentroHospitalarioRepository repository = getIt<CentroHospitalarioRepository>();
      final List<CentroHospitalarioEntity> centros = await repository.getAll();

      if (mounted) {
        setState(() {
          _centrosHospitalarios = centros;
          _loadingCentros = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error cargando centros hospitalarios: $e');
      if (mounted) {
        setState(() {
          _loadingCentros = false;
        });
      }
    }
  }

  Future<void> _loadTiposTraslado() async {
    try {
      final MotivoTrasladoRepository repository = getIt<MotivoTrasladoRepository>();
      final List<MotivoTrasladoEntity> motivos = await repository.getAll();

      if (mounted) {
        setState(() {
          _motivosTraslado = motivos
            ..sort((MotivoTrasladoEntity a, MotivoTrasladoEntity b) => a.nombre.compareTo(b.nombre));
          _loadingMotivosTraslado = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error cargando motivos de traslado: $e');
      if (mounted) {
        setState(() {
          _loadingMotivosTraslado = false;
        });
      }
    }
  }

  Future<void> _loadLocalidades() async {
    try {
      final LocalidadRepository repository = getIt<LocalidadRepository>();
      final List<LocalidadEntity> localidades = await repository.getAll();

      if (mounted) {
        setState(() {
          _localidades = localidades;
        });
      }
    } catch (e) {
      debugPrint('❌ Error cargando localidades: $e');
    }
  }

  Future<void> _loadTiposVehiculo() async {
    try {
      final TipoVehiculoRepository repository = getIt<TipoVehiculoRepository>();
      final List<TipoVehiculoEntity> tipos = await repository.getActivos();

      if (mounted) {
        setState(() {
          _tiposVehiculo = tipos
            ..sort((TipoVehiculoEntity a, TipoVehiculoEntity b) {
              if (a.orden != null && b.orden != null) {
                return a.orden!.compareTo(b.orden!);
              }
              return a.nombre.compareTo(b.nombre);
            });
          _loadingTiposVehiculo = false;

          if (_tipoAmbulancia == null && _tiposVehiculo.isNotEmpty) {
            final TipoVehiculoEntity? colectiva = _tiposVehiculo.cast<TipoVehiculoEntity?>().firstWhere(
                  (TipoVehiculoEntity? tipo) => tipo?.nombre.toLowerCase().contains('colectiva') ?? false,
              orElse: () => null,
            );
            _tipoAmbulancia = colectiva?.id;
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error cargando tipos de vehículo: $e');
      if (mounted) {
        setState(() {
          _loadingTiposVehiculo = false;
        });
      }
    }
  }

  Future<void> _loadFacultativos() async {
    try {
      final FacultativoRepository repository = getIt<FacultativoRepository>();
      final List<FacultativoEntity> facultativos = await repository.getActivos();

      if (mounted) {
        setState(() {
          _facultativos = facultativos
            ..sort((FacultativoEntity a, FacultativoEntity b) =>
                '${a.nombre} ${a.apellidos}'.compareTo('${b.nombre} ${b.apellidos}'));
          _loadingFacultativos = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error cargando facultativos: $e');
      if (mounted) {
        setState(() {
          _loadingFacultativos = false;
        });
      }
    }
  }

  Future<void> _loadPacientes() async {
    try {
      final PacienteRepository repository = getIt<PacienteRepository>();
      final List<PacienteEntity> pacientes = await repository.getAll();

      if (mounted) {
        setState(() {
          _pacientes = pacientes
            ..sort((PacienteEntity a, PacienteEntity b) =>
                a.nombreCompleto.compareTo(b.nombreCompleto));
          _loadingPacientes = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error cargando pacientes: $e');
      if (mounted) {
        setState(() {
          _loadingPacientes = false;
        });
      }
    }
  }

  /// Carga los datos del servicio en modo edición
  Future<void> _loadServicioData() async {
    final ServicioEntity? servicio = widget.servicio;
    if (servicio == null) {
      return;
    }

    debugPrint('📝 Wizard: Cargando datos del servicio ${servicio.codigo} para edición');

    setState(() {
      // ========================================================================
      // STEP 1: Datos Generales y Médicos
      // ========================================================================

      // Paciente y fechas
      _pacienteSeleccionado = servicio.paciente;
      _fechaInicioTratamiento = servicio.fechaServicioInicio;
      _fechaFinTratamiento = servicio.fechaServicioFin;

      // Facultativo
      if (servicio.medicoId != null && _facultativos.isNotEmpty) {
        try {
          _facultativoSeleccionado = _facultativos.firstWhere(
            (FacultativoEntity f) => f.id == servicio.medicoId,
          );
          debugPrint('✅ Facultativo cargado: ${_facultativoSeleccionado!.nombre}');
        } catch (e) {
          debugPrint('⚠️ No se encontró facultativo con id: ${servicio.medicoId}');
        }
      }

      // Centro Hospitalario (si el destino es un centro hospitalario)
      if (servicio.tipoDestino?.toLowerCase() == 'centro_hospitalario' &&
          servicio.destino != null &&
          _centrosHospitalarios.isNotEmpty) {
        try {
          // Buscar centro por nombre (el campo destino contiene el nombre del centro)
          _centroHospitalarioPaso1 = _centrosHospitalarios.firstWhere(
            (CentroHospitalarioEntity c) => c.nombre == servicio.destino,
          );
          debugPrint('✅ Centro hospitalario cargado: ${_centroHospitalarioPaso1!.nombre}');
        } catch (e) {
          debugPrint('⚠️ No se encontró centro hospitalario con nombre: ${servicio.destino}');
        }
      }

      // Motivo de traslado
      _motivoTrasladoSeleccionado = servicio.motivoTraslado;

      // Hora en centro (parseando horaRecogida)
      if (servicio.horaRecogida != null) {
        try {
          final List<String> parts = servicio.horaRecogida!.split(':');
          if (parts.length >= 2) {
            _horaEnCentro = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }
        } catch (e) {
          debugPrint('⚠️ Error parseando horaRecogida: $e');
        }
      }

      // Observaciones
      _observacionesGenerales = servicio.observaciones ?? '';
      _observacionesMedicas = servicio.observacionesMedicas ?? '';

      // Recursos médicos (checkboxes del Step 1)
      // Estos mapean desde los campos del servicio
      // requiereAyuda, requiereCamilla, requiereSillaRuedas
      _requiereAyudante = servicio.requiereAyuda;
      // TODO(dev): Mapear movilidad, acompañantes, oxígeno cuando estén en el modelo
      // Por ahora dejamos valores por defecto

      // Tipo de ambulancia
      _tipoAmbulancia = servicio.tipoAmbulancia;

      // ========================================================================
      // STEP 2: Modalidad y Configuración de Recurrencia
      // ========================================================================

      final String? tipoRecurrencia = servicio.tipoRecurrencia;
      if (tipoRecurrencia != null) {
        switch (tipoRecurrencia.toLowerCase()) {
          case 'unico':
            _modalidad = ModalidadServicio.unico;
            break;
          case 'diario':
            _modalidad = ModalidadServicio.diario;
            break;
          case 'semanal':
            _modalidad = ModalidadServicio.semanal;
            break;
          case 'mensual':
            _modalidad = ModalidadServicio.mensual;
            break;
          case 'dias_alternos':
            _modalidad = ModalidadServicio.diasAlternos;
            break;
          case 'semanas_alternas':
            _modalidad = ModalidadServicio.semanasAlternas;
            break;
          case 'fechas_especificas':
          case 'especifico':
            _modalidad = ModalidadServicio.especifico;
            break;
          default:
            _modalidad = ModalidadServicio.unico;
        }
      }

      // Cargar configuración de modalidad
      if (servicio.diasSemana != null && servicio.diasSemana!.isNotEmpty) {
        _diasSemanaSeleccionados
          ..clear()
          ..addAll(servicio.diasSemana!);
      }

      // Cargar intervalos
      if (servicio.intervaloSemanas != null) {
        _intervaloSemanas = servicio.intervaloSemanas!;
      }
      if (servicio.intervaloDias != null) {
        _intervaloDias = servicio.intervaloDias!;
      }

      if (servicio.diasMes != null && servicio.diasMes!.isNotEmpty) {
        _diasMesSeleccionados
          ..clear()
          ..addAll(servicio.diasMes!);
      }

      if (servicio.fechasEspecificas != null && servicio.fechasEspecificas!.isNotEmpty) {
        _fechasEspecificas
          ..clear()
          ..addAll(
          servicio.fechasEspecificas!.map((String dateStr) {
            try {
              return DateTime.parse(dateStr);
            } catch (e) {
              debugPrint('⚠️ Error parseando fecha específica: $dateStr - $e');
              return DateTime.now();
            }
          }),
        );
      }

      // ⚙️ Construir _configuracionModalidad en el formato esperado por los widgets
      // Los widgets de paso 2 esperan ConfiguracionDia en lugar de los Sets legacy
      _buildConfiguracionModalidadFromLegacyData();

      // ========================================================================
      // STEP 3: Trayectos (continúa abajo...)
      // ======================================================================

      // Step 3: Trayectos
      // NOTA: En modo edición, los trayectos NO se cargan desde los traslados generados.
      // Los datos de los trayectos están almacenados en el servicio.
      if (_trayectos.isEmpty) {
        debugPrint('📝 Wizard: Cargando trayectos desde servicio...');

        // ✅ FIX: Parsear horaRecogida y horaVuelta ANTES de crear los trayectos
        TimeOfDay? horaIda;
        TimeOfDay? horaVuelta;

        // Parsear hora de IDA (horaRecogida)
        if (servicio.horaRecogida != null) {
          try {
            final List<String> parts = servicio.horaRecogida!.split(':');
            if (parts.length >= 2) {
              horaIda = TimeOfDay(
                hour: int.parse(parts[0]),
                minute: int.parse(parts[1]),
              );
              debugPrint('   ✅ Hora IDA parseada: ${horaIda.hour.toString().padLeft(2, "0")}:${horaIda.minute.toString().padLeft(2, "0")}');
            }
          } catch (e) {
            debugPrint('⚠️ Error parseando horaRecogida: $e');
          }
        }

        // Parsear hora de VUELTA (horaVuelta) si requiereVuelta es true
        if (servicio.requiereVuelta && servicio.horaVuelta != null) {
          try {
            final List<String> parts = servicio.horaVuelta!.split(':');
            if (parts.length >= 2) {
              horaVuelta = TimeOfDay(
                hour: int.parse(parts[0]),
                minute: int.parse(parts[1]),
              );
              debugPrint('   ✅ Hora VUELTA parseada: ${horaVuelta.hour.toString().padLeft(2, "0")}:${horaVuelta.minute.toString().padLeft(2, "0")}');
            }
          } catch (e) {
            debugPrint('⚠️ Error parseando horaVuelta: $e');
          }
        }

        // Mapear tipoOrigen de String? a TipoUbicacion
        TipoUbicacion tipoOrigen = TipoUbicacion.domicilioPaciente;
        if (servicio.tipoOrigen != null) {
          switch (servicio.tipoOrigen!.toLowerCase()) {
            case 'domicilio_paciente':
              tipoOrigen = TipoUbicacion.domicilioPaciente;
              break;
            case 'otro_domicilio':
              tipoOrigen = TipoUbicacion.otroDomicilio;
              break;
            case 'centro_hospitalario':
              tipoOrigen = TipoUbicacion.centroHospitalario;
              break;
          }
        }

        // Mapear tipoDestino de String? a TipoUbicacion
        TipoUbicacion tipoDestino = TipoUbicacion.centroHospitalario;
        if (servicio.tipoDestino != null) {
          switch (servicio.tipoDestino!.toLowerCase()) {
            case 'domicilio_paciente':
              tipoDestino = TipoUbicacion.domicilioPaciente;
              break;
            case 'otro_domicilio':
              tipoDestino = TipoUbicacion.otroDomicilio;
              break;
            case 'centro_hospitalario':
              tipoDestino = TipoUbicacion.centroHospitalario;
              break;
          }
        }

        // ✅ Crear trayecto de IDA con hora asignada
        _trayectos.add(
          TrayectoData(
            tipoOrigen: tipoOrigen,
            tipoDestino: tipoDestino,
            // Mapear origen según tipo
            origenDomicilio: tipoOrigen == TipoUbicacion.otroDomicilio ? servicio.origen : null,
            origenCentro: tipoOrigen == TipoUbicacion.centroHospitalario ? servicio.origen : null,
            origenUbicacionEnCentro: servicio.origenUbicacionCentro,
            // Mapear destino según tipo
            destinoDomicilio: tipoDestino == TipoUbicacion.otroDomicilio ? servicio.destino : null,
            destinoCentro: tipoDestino == TipoUbicacion.centroHospitalario ? servicio.destino : null,
            destinoUbicacionEnCentro: servicio.destinoUbicacionCentro,
            // ✅ FIX: Asignar hora parseada de horaRecogida
            hora: horaIda,
          ),
        );

        debugPrint('   ✅ Trayecto IDA creado');

        // ✅ Si requiereVuelta es true, crear trayecto de VUELTA
        if (servicio.requiereVuelta) {
          // El trayecto de vuelta invierte origen y destino
          _trayectos.add(
            TrayectoData(
              tipoOrigen: tipoDestino, // Invertido
              tipoDestino: tipoOrigen, // Invertido
              // Mapear origen (era destino en IDA)
              origenDomicilio: tipoDestino == TipoUbicacion.otroDomicilio ? servicio.destino : null,
              origenCentro: tipoDestino == TipoUbicacion.centroHospitalario ? servicio.destino : null,
              origenUbicacionEnCentro: servicio.destinoUbicacionCentro,
              // Mapear destino (era origen en IDA)
              destinoDomicilio: tipoOrigen == TipoUbicacion.otroDomicilio ? servicio.origen : null,
              destinoCentro: tipoOrigen == TipoUbicacion.centroHospitalario ? servicio.origen : null,
              destinoUbicacionEnCentro: servicio.origenUbicacionCentro,
              // ✅ FIX: Asignar hora parseada de horaVuelta
              hora: horaVuelta,
            ),
          );

          debugPrint('   ✅ Trayecto VUELTA creado');
        }
      }
    });

    debugPrint('📝 Wizard: ✅ Datos del servicio cargados (${_trayectos.length} trayecto(s))');
  }

  /// Actualiza la hora en la configuración de modalidad cuando cambia en Step 1
  void _actualizarHoraEnConfiguracionModalidad(TimeOfDay? nuevaHora) {
    if (_configuracionModalidad == null || _configuracionModalidad!.isEmpty || nuevaHora == null) {
      return;
    }

    debugPrint('⏰ Actualizando hora en configuración de modalidad: ${nuevaHora.format(context)}');

    // Función auxiliar para actualizar un día individual
    Map<String, dynamic> actualizarDia(Map<String, dynamic> dia) {
      // Solo actualizar si el día tiene ida=true
      if (dia['ida'] == true) {
        final Map<String, dynamic> diaActualizado = Map<String, dynamic>.from(dia);

        // ✅ CORRECCIÓN: Usar formato de cadena "HH:MM" que espera fromJson()
        // ConfiguracionDia.fromJson() espera: (json['hora_ida'] as String).split(':')
        diaActualizado['hora_ida'] = '${nuevaHora.hour.toString().padLeft(2, '0')}:${nuevaHora.minute.toString().padLeft(2, '0')}';

        debugPrint('   ✅ Día actualizado: ${diaActualizado['dia_semana'] ?? diaActualizado['dia_mes'] ?? diaActualizado['fecha']}');

        return diaActualizado;
      }

      // Si ida=false, mantener sin cambios
      return dia;
    }

    // Actualizar según tipo de modalidad
    final Map<String, dynamic> nuevaConfiguracion = Map<String, dynamic>.from(_configuracionModalidad!);

    // Para modalidades con 'dias' (semanal, mensual)
    if (nuevaConfiguracion.containsKey('dias')) {
      final List<dynamic>? dias = nuevaConfiguracion['dias'] as List<dynamic>?;
      if (dias != null) {
        // ignore: always_specify_types
        nuevaConfiguracion['dias'] = dias.map((dia) {
          if (dia is Map<String, dynamic>) {
            return actualizarDia(dia);
          }
          return dia;
        }).toList();
        // ignore: always_specify_types
        debugPrint('📅 ${(nuevaConfiguracion['dias'] as List).length} días actualizados en configuración');
      }
    }

    // Para modalidad de días alternos (pares e impares)
    if (nuevaConfiguracion.containsKey('pares')) {
      final List<dynamic>? pares = nuevaConfiguracion['pares'] as List<dynamic>?;
      if (pares != null) {
        // ignore: always_specify_types
        nuevaConfiguracion['pares'] = pares.map((dia) {
          if (dia is Map<String, dynamic>) {
            return actualizarDia(dia);
          }
          return dia;
        }).toList();
        // ignore: always_specify_types
        debugPrint('📅 ${(nuevaConfiguracion['pares'] as List).length} días PARES actualizados');
      }
    }

    if (nuevaConfiguracion.containsKey('impares')) {
      final List<dynamic>? impares = nuevaConfiguracion['impares'] as List<dynamic>?;
      if (impares != null) {
        // ignore: always_specify_types
        nuevaConfiguracion['impares'] = impares.map((dia) {
          if (dia is Map<String, dynamic>) {
            return actualizarDia(dia);
          }
          return dia;
        }).toList();
        // ignore: always_specify_types
        debugPrint('📅 ${(nuevaConfiguracion['impares'] as List).length} días IMPARES actualizados');
      }
    }

    // Para modalidad de fechas específicas
    if (nuevaConfiguracion.containsKey('fechas')) {
      final List<dynamic>? fechas = nuevaConfiguracion['fechas'] as List<dynamic>?;
      if (fechas != null) {
        // ignore: always_specify_types
        nuevaConfiguracion['fechas'] = fechas.map((fecha) {
          if (fecha is Map<String, dynamic>) {
            return actualizarDia(fecha);
          }
          return fecha;
        }).toList();
        // ignore: always_specify_types
        debugPrint('📅 ${(nuevaConfiguracion['fechas'] as List).length} fechas específicas actualizadas');
      }
    }

    // Aplicar configuración actualizada
    _configuracionModalidad = nuevaConfiguracion;

    debugPrint('✅ Configuración de modalidad actualizada con nueva hora');

    // ✅ CRÍTICO: También actualizar los trayectos con la nueva hora
    if (_trayectos.isNotEmpty) {
      debugPrint('⏰ Actualizando hora en ${_trayectos.length} trayectos...');

      // Actualizar trayecto de IDA (siempre es el primero)
      _trayectos[0].hora = nuevaHora;
      debugPrint('   ✅ Trayecto IDA actualizado a ${nuevaHora.format(context)}');

      // Actualizar trayecto de VUELTA si existe (siempre es el segundo)
      if (_trayectos.length > 1 && _motivoTrasladoSeleccionado?.vuelta == true) {
        final int tiempoEspera = _motivoTrasladoSeleccionado?.tiempo ?? 60;
        final int totalMinutos = nuevaHora.hour * 60 + nuevaHora.minute + tiempoEspera;
        final TimeOfDay horaVuelta = TimeOfDay(
          hour: (totalMinutos ~/ 60) % 24,
          minute: totalMinutos % 60,
        );

        _trayectos[1].hora = horaVuelta;
        debugPrint('   ✅ Trayecto VUELTA actualizado a ${horaVuelta.format(context)}');
      }

      debugPrint('✅ Trayectos actualizados correctamente');
    }
  }

  /// Construye _configuracionModalidad en el formato de ConfiguracionDia
  /// a partir de los datos legacy (_diasSemanaSeleccionados, _diasMesSeleccionados, _fechasEspecificas)
  void _buildConfiguracionModalidadFromLegacyData() {
    if (_motivoTrasladoSeleccionado == null) {
      return;
    }

    final int tiempoEspera = _motivoTrasladoSeleccionado!.tiempo;
    final bool tieneVuelta = _motivoTrasladoSeleccionado!.vuelta;

    switch (_modalidad) {
      case ModalidadServicio.semanal:
        if (_diasSemanaSeleccionados.isNotEmpty) {
          final List<Map<String, dynamic>> dias = _diasSemanaSeleccionados.map((int diaInt) {
            return ConfiguracionDia.semanal(
              diaSemana: DiaSemana.fromValor(diaInt),
              ida: true,
              horaIda: _horaEnCentro,
              tiempoEspera: tiempoEspera,
              vuelta: tieneVuelta,
            ).toJson();
          }).toList();

          _configuracionModalidad = <String, dynamic>{'dias': dias};
          debugPrint('✅ Configuración semanal construida con ${dias.length} días');
        }
        break;

      case ModalidadServicio.mensual:
        if (_diasMesSeleccionados.isNotEmpty) {
          final List<Map<String, dynamic>> dias = _diasMesSeleccionados.map((int dia) {
            return ConfiguracionDia.mensual(
              diaMes: dia,
              ida: true,
              horaIda: _horaEnCentro,
              tiempoEspera: tiempoEspera,
              vuelta: tieneVuelta,
            ).toJson();
          }).toList();

          _configuracionModalidad = <String, dynamic>{'dias': dias};
          debugPrint('✅ Configuración mensual construida con ${dias.length} días');
        }
        break;

      case ModalidadServicio.especifico:
        if (_fechasEspecificas.isNotEmpty) {
          final List<Map<String, dynamic>> fechas = _fechasEspecificas.map((DateTime fecha) {
            return ConfiguracionDia.fechaEspecifica(
              fecha: fecha,
              ida: true,
              horaIda: _horaEnCentro,
              tiempoEspera: tiempoEspera,
              vuelta: tieneVuelta,
            ).toJson();
          }).toList();

          _configuracionModalidad = <String, dynamic>{'fechas': fechas};
          debugPrint('✅ Configuración de fechas específicas construida con ${fechas.length} fechas');
        }
        break;

      case ModalidadServicio.unico:
      case ModalidadServicio.diario:
        // Estos tipos no necesitan configuración de días
        debugPrint('ℹ️ Modalidad ${_modalidad.name} no requiere configuración de días');
        break;

      case ModalidadServicio.diasAlternos:
      case ModalidadServicio.semanasAlternas:
        // TODO(dev): Implementar cuando se definan estos formatos en ServicioEntity
        debugPrint('⚠️ Modalidad ${_modalidad.name} no soportada aún en modo edición');
        break;
    }
  }

  // ============================================================================
  // NAVEGACIÓN DEL WIZARD
  // ============================================================================

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;

          // 🔄 Si avanzamos del Step 2 al Step 3, generar trayectos automáticamente
          if (_currentStep == 2) {
            _generarTrayectosDesdeConfiguracion();
          }
        });
      }
    } else {
      _guardarServicio();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _validatePaso1();
      case 1:
        return _validatePaso2();
      case 2:
        return _validatePaso3();
      case 3:
        return true; // Revisión no necesita validación
      default:
        return true;
    }
  }

  bool _validatePaso1() {
    if (_pacienteSeleccionado == null) {
      _showError('Selecciona un paciente');
      return false;
    }
    if (_motivoTrasladoSeleccionado == null) {
      _showError('Selecciona un tipo de servicio');
      return false;
    }
    if (_fechaInicioTratamiento == null) {
      _showError('Selecciona la fecha de inicio del tratamiento');
      return false;
    }
    return true;
  }

  bool _validatePaso2() {
    // ✅ SERVICIO ÚNICO y DIARIO: No necesitan validación (ya tienen fecha/hora del Paso 1)
    if (_modalidad == ModalidadServicio.unico || _modalidad == ModalidadServicio.diario) {
      return true;
    }

    // ⚠️ RESTO DE MODALIDADES: Sí necesitan configuración de horarios/días
    if (_configuracionModalidad == null || _configuracionModalidad!.isEmpty) {
      _showError('Configura los horarios y días del servicio');
      return false;
    }

    // Para modalidades con días configurables, verificar que haya al menos un día activo
    if (_modalidad == ModalidadServicio.semanal ||
        _modalidad == ModalidadServicio.semanasAlternas ||
        _modalidad == ModalidadServicio.mensual ||
        _modalidad == ModalidadServicio.diasAlternos ||
        _modalidad == ModalidadServicio.especifico) {

      List<dynamic> diasAValidar = <dynamic>[];

      // Para Días Alternos, combinar pares e impares
      if (_modalidad == ModalidadServicio.diasAlternos) {
        final List<dynamic>? pares = _configuracionModalidad!['pares'] as List<dynamic>?;
        final List<dynamic>? impares = _configuracionModalidad!['impares'] as List<dynamic>?;

        if (pares != null) {
          diasAValidar.addAll(pares);
        }
        if (impares != null) {
          diasAValidar.addAll(impares);
        }
      } else if (_modalidad == ModalidadServicio.especifico) {
        // Para Fechas Específicas, usar 'fechas'
        final List<dynamic>? fechas = _configuracionModalidad!['fechas'] as List<dynamic>?;
        debugPrint('🔍 Validando Fechas Específicas: fechas = $fechas');
        debugPrint('🔍 _configuracionModalidad = $_configuracionModalidad');
        if (fechas != null) {
          diasAValidar = fechas;
        }
      } else {
        // Para otras modalidades (semanal, mensual, etc.), usar 'dias'
        final List<dynamic>? dias = _configuracionModalidad!['dias'] as List<dynamic>?;
        if (dias != null) {
          diasAValidar = dias;
        }
      }

      debugPrint('🔍 diasAValidar.length = ${diasAValidar.length}');
      debugPrint('🔍 diasAValidar = $diasAValidar');

      if (diasAValidar.isEmpty) {
        _showError('Selecciona al menos un día');
        return false;
      }

      // Verificar que al menos un día tenga ida=true
      final bool hayDiaActivo = diasAValidar.any((Object? d) {
        if (d is Map<String, dynamic>) {
          return d['ida'] == true;
        }
        return false;
      });

      if (!hayDiaActivo) {
        _showError('Selecciona al menos un día marcando la casilla "Ida"');
        return false;
      }
    }

    return true;
  }

  bool _validatePaso3() {
    if (_trayectos.isEmpty) {
      _showError('Agrega al menos un trayecto');
      return false;
    }

    for (final TrayectoData trayecto in _trayectos) {
      if (trayecto.tipoOrigen == TipoUbicacion.otroDomicilio) {
        if (trayecto.origenDomicilio == null || trayecto.origenDomicilio!.isEmpty) {
          _showError('Completa la dirección de origen en todos los trayectos');
          return false;
        }
      } else if (trayecto.tipoOrigen == TipoUbicacion.centroHospitalario) {
        if (trayecto.origenCentro == null || trayecto.origenCentro!.isEmpty) {
          _showError('Selecciona el centro hospitalario de origen en todos los trayectos');
          return false;
        }
      }

      if (trayecto.tipoDestino == TipoUbicacion.otroDomicilio) {
        if (trayecto.destinoDomicilio == null || trayecto.destinoDomicilio!.isEmpty) {
          _showError('Completa la dirección de destino en todos los trayectos');
          return false;
        }
      } else if (trayecto.tipoDestino == TipoUbicacion.centroHospitalario) {
        if (trayecto.destinoCentro == null || trayecto.destinoCentro!.isEmpty) {
          _showError('Selecciona el centro hospitalario de destino en todos los trayectos');
          return false;
        }
      }

      if (trayecto.hora == null) {
        _showError('Completa la hora de todos los trayectos');
        return false;
      }
    }

    return true;
  }

  /// Genera trayectos automáticamente basándose en la configuración de modalidad
  void _generarTrayectosDesdeConfiguracion() {
    debugPrint('🚗 === INICIANDO GENERACIÓN DE TRAYECTOS ===');

    // Limpiar trayectos existentes
    for (final TrayectoData trayecto in _trayectos) {
      trayecto.dispose();
    }
    _trayectos.clear();

    // ✅ CASO ESPECIAL: SERVICIO ÚNICO y DIARIO - Generar trayectos desde datos del Paso 1
    if (_modalidad == ModalidadServicio.unico || _modalidad == ModalidadServicio.diario) {
      debugPrint('📅 Modalidad ${_modalidad == ModalidadServicio.unico ? "SERVICIO ÚNICO" : "DIARIO"} detectada - Generando trayectos desde Paso 1');
      _generarTrayectosSimples();
      return;
    }

    // ⚠️ RESTO DE MODALIDADES: Usar configuración de días
    if (_configuracionModalidad == null || _configuracionModalidad!.isEmpty) {
      debugPrint('❌ No hay configuración de modalidad disponible');
      return;
    }

    debugPrint('✅ Configuración encontrada: $_configuracionModalidad');

    // Obtener lista de días configurados según la modalidad
    List<dynamic> dias = <dynamic>[];

    if (_modalidad == ModalidadServicio.diasAlternos) {
      // Para Días Alternos, combinar pares e impares
      final List<dynamic>? pares = _configuracionModalidad!['pares'] as List<dynamic>?;
      final List<dynamic>? impares = _configuracionModalidad!['impares'] as List<dynamic>?;

      if (pares != null) {
        dias.addAll(pares);
      }
      if (impares != null) {
        dias.addAll(impares);
      }
      debugPrint('✅ Días Alternos: ${pares?.length ?? 0} pares + ${impares?.length ?? 0} impares = ${dias.length} total');
    } else if (_modalidad == ModalidadServicio.especifico) {
      // Para Fechas Específicas, usar 'fechas'
      final List<dynamic>? fechas = _configuracionModalidad!['fechas'] as List<dynamic>?;
      if (fechas != null) {
        dias = fechas;
      }
      debugPrint('✅ Fechas Específicas: ${dias.length} fechas');
    } else {
      // Para otras modalidades (semanal, mensual, etc.), usar 'dias'
      final List<dynamic>? diasConfig = _configuracionModalidad!['dias'] as List<dynamic>?;
      if (diasConfig != null) {
        dias = diasConfig;
      }
      debugPrint('✅ Configuración estándar: ${dias.length} días');
    }

    if (dias.isEmpty) {
      debugPrint('❌ No hay días en la configuración');
      return;
    }

    debugPrint('✅ ${dias.length} días encontrados en configuración');

    // Para cada día configurado, generar trayectos
    for (final dynamic diaData in dias) {
      if (diaData is! Map<String, dynamic>) {
        debugPrint('⚠️ Día no es un Map: $diaData');
        continue;
      }

      debugPrint('📅 Procesando día: $diaData');

      final bool ida = diaData['ida'] as bool? ?? false;
      final bool vuelta = diaData['vuelta'] as bool? ?? false;

      debugPrint('   ida=$ida, vuelta=$vuelta');

      // Parsear horaIda desde el campo 'hora_ida' (snake_case)
      final dynamic horaIdaRaw = diaData['hora_ida'];
      TimeOfDay? horaIda;

      if (horaIdaRaw is String) {
        // Si viene como string "10:00", parsear
        final List<String> parts = horaIdaRaw.split(':');
        if (parts.length == 2) {
          final int? hour = int.tryParse(parts[0]);
          final int? minute = int.tryParse(parts[1]);
          if (hour != null && minute != null) {
            horaIda = TimeOfDay(hour: hour, minute: minute);
            debugPrint('   horaIda=${horaIda.format(context)} (desde string)');
          }
        }
      } else if (horaIdaRaw is Map<String, dynamic>) {
        // Si viene como Map {hour: X, minute: Y}
        final int? hour = horaIdaRaw['hour'] as int?;
        final int? minute = horaIdaRaw['minute'] as int?;
        if (hour != null && minute != null) {
          horaIda = TimeOfDay(hour: hour, minute: minute);
          debugPrint('   horaIda=${horaIda.format(context)} (desde Map)');
        }
      }

      // Parsear tiempoEspera desde el campo 'tiempo_espera' (snake_case)
      final int tiempoEspera = diaData['tiempo_espera'] as int? ?? 0;
      debugPrint('   tiempoEspera=$tiempoEspera min');

      // Generar trayecto de IDA si está marcado
      if (ida && horaIda != null) {
        debugPrint('   ➕ Agregando trayecto IDA');

        // Formatear hora como "HH:MM"
        final String horaTexto = '${horaIda.hour.toString().padLeft(2, '0')}:${horaIda.minute.toString().padLeft(2, '0')}';

        _trayectos.add(
          TrayectoData(
            hora: horaIda,
            horaController: TextEditingController(text: horaTexto),
            destinoCentro: _centroHospitalarioPaso1?.nombre, // ✅ Auto-completar con centro del Paso 1
          ),
        );
      } else {
        debugPrint('   ⏭️ NO se agrega IDA (ida=$ida, horaIda=$horaIda)');
      }

      // Generar trayecto de VUELTA si está marcado
      if (vuelta && horaIda != null && tiempoEspera > 0) {
        // Calcular hora de vuelta (hora ida + tiempo de espera)
        final int totalMinutes = horaIda.hour * 60 + horaIda.minute + tiempoEspera;
        final int horaVuelta = (totalMinutes ~/ 60) % 24;
        final int minutoVuelta = totalMinutes % 60;

        debugPrint('   ➕ Agregando trayecto VUELTA a las $horaVuelta:$minutoVuelta');

        // Formatear hora como "HH:MM"
        final String horaTexto = '${horaVuelta.toString().padLeft(2, '0')}:${minutoVuelta.toString().padLeft(2, '0')}';

        _trayectos.add(
          TrayectoData(
            tipoOrigen: TipoUbicacion.centroHospitalario,
            tipoDestino: TipoUbicacion.domicilioPaciente,
            hora: TimeOfDay(hour: horaVuelta, minute: minutoVuelta),
            horaController: TextEditingController(text: horaTexto),
            origenCentro: _centroHospitalarioPaso1?.nombre, // ✅ Auto-completar con centro del Paso 1
          ),
        );
      } else {
        debugPrint('   ⏭️ NO se agrega VUELTA (vuelta=$vuelta, horaIda=$horaIda, tiempoEspera=$tiempoEspera)');
      }
    }

    debugPrint('🚗 === FIN GENERACIÓN: ${_trayectos.length} trayectos totales ===');
  }

  /// Genera trayectos para SERVICIO ÚNICO y DIARIO basándose en datos del Paso 1
  void _generarTrayectosSimples() {
    debugPrint('📅 === GENERANDO TRAYECTOS SIMPLES (Único/Diario) ===');

    // Verificar que tengamos la hora de recogida del Paso 1
    if (_horaEnCentro == null) {
      debugPrint('❌ No hay hora de recogida configurada en el Paso 1');
      return;
    }

    // Verificar que tengamos el motivo de traslado para saber si tiene vuelta
    if (_motivoTrasladoSeleccionado == null) {
      debugPrint('❌ No hay motivo de traslado seleccionado');
      return;
    }

    final bool tieneVuelta = _motivoTrasladoSeleccionado!.vuelta;
    final int tiempoEspera = _motivoTrasladoSeleccionado!.tiempo;

    debugPrint('   Hora de recogida: ${_horaEnCentro!.format(context)}');
    debugPrint('   Tiene vuelta: $tieneVuelta');
    debugPrint('   Tiempo de espera: $tiempoEspera min');

    // Verificar si hay centro hospitalario seleccionado en Paso 1
    if (_centroHospitalarioPaso1 != null) {
      debugPrint('   🏥 Centro hospitalario del Paso 1: ${_centroHospitalarioPaso1!.nombre}');
    } else {
      debugPrint('   ℹ️ No hay centro hospitalario en Paso 1 (se configurará en Paso 3)');
    }

    // Generar trayecto de IDA (siempre)
    final String horaIdaTexto = '${_horaEnCentro!.hour.toString().padLeft(2, '0')}:${_horaEnCentro!.minute.toString().padLeft(2, '0')}';

    _trayectos.add(
      TrayectoData(
        hora: _horaEnCentro,
        horaController: TextEditingController(text: horaIdaTexto),
        destinoCentro: _centroHospitalarioPaso1?.nombre, // ✅ Aplicar nombre del centro del Paso 1 si existe
      ),
    );
    debugPrint('   ✅ Trayecto IDA agregado a las $horaIdaTexto${_centroHospitalarioPaso1 != null ? " → ${_centroHospitalarioPaso1!.nombre}" : ""}');

    // Generar trayecto de VUELTA (solo si tieneVuelta == true)
    if (tieneVuelta) {
      // Calcular hora de vuelta (hora ida + tiempo de espera)
      final int totalMinutes = _horaEnCentro!.hour * 60 + _horaEnCentro!.minute + tiempoEspera;
      final int horaVuelta = (totalMinutes ~/ 60) % 24;
      final int minutoVuelta = totalMinutes % 60;

      final String horaVueltaTexto = '${horaVuelta.toString().padLeft(2, '0')}:${minutoVuelta.toString().padLeft(2, '0')}';

      _trayectos.add(
        TrayectoData(
          tipoOrigen: TipoUbicacion.centroHospitalario,
          tipoDestino: TipoUbicacion.domicilioPaciente,
          hora: TimeOfDay(hour: horaVuelta, minute: minutoVuelta),
          horaController: TextEditingController(text: horaVueltaTexto),
          origenCentro: _centroHospitalarioPaso1?.nombre, // ✅ Aplicar nombre del centro del Paso 1 si existe
        ),
      );
      debugPrint('   ✅ Trayecto VUELTA agregado a las $horaVueltaTexto${_centroHospitalarioPaso1 != null ? " ${_centroHospitalarioPaso1!.nombre} →" : ""}');
    } else {
      debugPrint('   ℹ️ NO se genera trayecto VUELTA (servicio solo ida)');
    }

    debugPrint('📅 === FIN GENERACIÓN SIMPLE: ${_trayectos.length} trayectos ===');
  }

  void _showError(String message) {
    unawaited(
      showResultDialog(
        context: context,
        title: 'Validación Requerida',
        message: message,
        type: ResultType.warning,
      ),
    );
  }

  Future<void> _guardarServicio() async {
    setState(() {
      _isCreating = true;
    });

    try {
      if (_isEditMode) {
        // MODO EDICIÓN: Actualizar servicio existente
        await _actualizarServicio();
      } else {
        // MODO CREACIÓN: Crear nuevo servicio
        await _crearServicioNuevo();
      }

      if (mounted) {
        setState(() {
          _isCreating = false;
        });

        Navigator.of(context).pop(true);

        if (mounted) {
          unawaited(
            showResultDialog(
              context: context,
              title: _isEditMode ? 'Servicio Actualizado' : 'Servicio Creado',
              message: _isEditMode
                  ? 'El servicio se ha actualizado exitosamente.'
                  : 'El nuevo servicio se ha creado exitosamente.\n\n'
                      'Los traslados se han generado automáticamente según la configuración de recurrencia.',
              type: ResultType.success,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error al ${_isEditMode ? "actualizar" : "crear"} servicio: $e');

      if (mounted) {
        setState(() {
          _isCreating = false;
        });

        unawaited(
          showResultDialog(
            context: context,
            title: _isEditMode ? 'Error al Actualizar Servicio' : 'Error al Crear Servicio',
            message: _isEditMode
                ? 'No se pudo actualizar el servicio. Por favor, intenta de nuevo.'
                : 'No se pudo crear el servicio. Por favor, intenta de nuevo.',
            type: ResultType.error,
            details: e.toString(),
          ),
        );
      }
    }
  }

  /// Crea un nuevo servicio (modo creación)
  Future<void> _crearServicioNuevo() async {
    debugPrint('📦 Wizard: PASO 1 - Creando servicio padre (nivel 1)...');
    final String servicioId = await ServicioCreator.crearServicioPadre(
      paciente: _pacienteSeleccionado!,
      modalidad: _modalidad,
      fechaInicio: _fechaInicioTratamiento!,
      fechaFin: _fechaFinTratamiento,
      trayectos: _trayectos,
      medicoId: _facultativoSeleccionado?.id, // ✅ ID del médico/facultativo seleccionado
      motivoTrasladoId: _motivoTrasladoSeleccionado?.id, // ✅ ID del motivo de traslado
      tipoAmbulancia: _tipoAmbulancia,
      observaciones: _observacionesGenerales,
      observacionesMedicas: _observacionesMedicas.isNotEmpty ? _observacionesMedicas : null,
      movilidad: _movilidad,
      acompanantes: _acompanantes,
      requiereAyudante: _requiereAyudante,
      diasSemana: _diasSemanaSeleccionados.toList(),
      intervaloSemanas: _intervaloSemanas,
      intervaloDias: _intervaloDias,
      diasMes: _diasMesSeleccionados.toList(),
      fechasEspecificas: _fechasEspecificas.toList(),
    );
    debugPrint('📦 Wizard: ✅ Servicio padre creado con ID: $servicioId');

    // ✅ SOLO crear servicio recurrente si NO es único
    // Para servicios únicos, el trigger de la tabla `servicios` generará el traslado directamente
    if (_modalidad != ModalidadServicio.unico) {
      debugPrint('📦 Wizard: PASO 2 - Creando servicio recurrente (nivel 2)...');
      final ServicioRecurrenteEntity servicio = ServicioCreator.crearEntidadServicioRecurrente(
        servicioId: servicioId,
        paciente: _pacienteSeleccionado!,
        modalidad: _modalidad,
        fechaInicio: _fechaInicioTratamiento!,
        fechaFin: _fechaFinTratamiento,
        trayectos: _trayectos,
        motivoTrasladoId: _motivoTrasladoSeleccionado?.id, // ✅ ID del motivo de traslado
        observaciones: _observacionesGenerales,
        diasSemana: _diasSemanaSeleccionados.toList(),
        intervaloSemanas: _intervaloSemanas,
        intervaloDias: _intervaloDias,
        diasMes: _diasMesSeleccionados.toList(),
        fechasEspecificas: _fechasEspecificas.toList(),
      );

      final ServicioRecurrenteRepository repository = getIt<ServicioRecurrenteRepository>();
      await repository.create(servicio);
      debugPrint('📦 Wizard: ✅ Servicio recurrente creado exitosamente');
    } else {
      debugPrint('📦 Wizard: ⚠️ Servicio ÚNICO - NO se crea entrada en servicios_recurrentes');
      debugPrint('📦 Wizard: ⚡ El trigger de la tabla servicios generará el traslado automáticamente');
    }
  }

  /// Actualiza un servicio existente (modo edición)
  ///
  /// Lógica de actualización:
  /// 1. Actualiza el servicio base (datos generales, fechas, observaciones)
  /// 2. Actualiza el servicio recurrente (si existe)
  /// 3. Elimina trayectos futuros (fecha >= hoy que NO estén en estado final)
  /// 4. Regenera nuevos trayectos con la configuración actualizada
  /// 5. Mantiene trayectos pasados sin modificar (ya gestionados/finalizados)
  Future<void> _actualizarServicio() async {
    final ServicioEntity? servicio = widget.servicio;
    if (servicio == null) {
      throw Exception('No hay servicio para actualizar');
    }

    debugPrint('📝 Wizard: Actualizando servicio ${servicio.codigo} (${servicio.id})');

    // ✅ Validar y obtener servicioId al inicio
    final String servicioId = servicio.id ?? '';
    if (servicioId.isEmpty) {
      throw Exception('El servicio no tiene ID válido');
    }

    // PASO 1: Actualizar servicio base (tabla servicios)
    final ServicioRepository servicioRepository = getIt<ServicioRepository>();

    // Calcular horaRecogida y horaVuelta desde los trayectos
    String? horaRecogida;
    String? horaVuelta;
    bool requiereVuelta = false;

    debugPrint('📊 Wizard: Calculando horas desde trayectos (${_trayectos.length} trayectos)');

    if (_trayectos.isNotEmpty) {
      // Primer trayecto es la IDA
      final TrayectoData primerTrayecto = _trayectos.first;
      debugPrint('   🕐 Trayecto IDA hora: ${primerTrayecto.hora?.format(context) ?? "NULL"}');

      if (primerTrayecto.hora != null) {
        horaRecogida = '${primerTrayecto.hora!.hour.toString().padLeft(2, '0')}:${primerTrayecto.hora!.minute.toString().padLeft(2, '0')}:00';
        debugPrint('   ✅ horaRecogida calculada: $horaRecogida');
      }

      // Si hay más de un trayecto, el segundo es la VUELTA
      if (_trayectos.length > 1) {
        requiereVuelta = true;
        final TrayectoData segundoTrayecto = _trayectos[1];
        debugPrint('   🕐 Trayecto VUELTA hora: ${segundoTrayecto.hora?.format(context) ?? "NULL"}');

        if (segundoTrayecto.hora != null) {
          horaVuelta = '${segundoTrayecto.hora!.hour.toString().padLeft(2, '0')}:${segundoTrayecto.hora!.minute.toString().padLeft(2, '0')}:00';
          debugPrint('   ✅ horaVuelta calculada: $horaVuelta');
        }
      }
    }

    // Calcular origen y destino desde los trayectos
    String? tipoOrigen;
    String? origen;
    String? origenUbicacionCentro;
    String? tipoDestino;
    String? destino;
    String? destinoUbicacionCentro;

    if (_trayectos.isNotEmpty) {
      final TrayectoData primerTrayecto = _trayectos.first;

      // Origen
      switch (primerTrayecto.tipoOrigen) {
        case TipoUbicacion.domicilioPaciente:
          tipoOrigen = 'domicilio_paciente';
          origen = _pacienteSeleccionado?.domicilioDireccion;
          break;
        case TipoUbicacion.otroDomicilio:
          tipoOrigen = 'otro_domicilio';
          origen = primerTrayecto.origenDomicilio;
          break;
        case TipoUbicacion.centroHospitalario:
          tipoOrigen = 'centro_hospitalario';
          origen = primerTrayecto.origenCentro;
          origenUbicacionCentro = primerTrayecto.origenUbicacionEnCentro;
          break;
      }

      // Destino
      switch (primerTrayecto.tipoDestino) {
        case TipoUbicacion.domicilioPaciente:
          tipoDestino = 'domicilio_paciente';
          destino = _pacienteSeleccionado?.domicilioDireccion;
          break;
        case TipoUbicacion.otroDomicilio:
          tipoDestino = 'otro_domicilio';
          destino = primerTrayecto.destinoDomicilio;
          break;
        case TipoUbicacion.centroHospitalario:
          tipoDestino = 'centro_hospitalario';
          destino = primerTrayecto.destinoCentro;
          destinoUbicacionCentro = primerTrayecto.destinoUbicacionEnCentro;
          break;
      }
    }

    final ServicioEntity servicioActualizado = servicio.copyWith(
      // ✅ Datos del médico y motivo de traslado
      medicoId: _facultativoSeleccionado?.id,
      idMotivoTraslado: _motivoTrasladoSeleccionado?.id,

      // ✅ Fechas y horas
      fechaServicioFin: _fechaFinTratamiento,
      horaRecogida: horaRecogida,
      requiereVuelta: requiereVuelta,
      horaVuelta: horaVuelta,

      // ✅ Origen y destino
      tipoOrigen: tipoOrigen,
      origen: origen,
      origenUbicacionCentro: origenUbicacionCentro,
      tipoDestino: tipoDestino,
      destino: destino,
      destinoUbicacionCentro: destinoUbicacionCentro,

      // ✅ Observaciones
      observaciones: _observacionesGenerales?.isNotEmpty == true ? _observacionesGenerales : null,
      observacionesMedicas: _observacionesMedicas.isNotEmpty ? _observacionesMedicas : null,

      // ✅ Tipo de ambulancia
      tipoAmbulancia: _tipoAmbulancia,

      // ✅ Requisitos médicos
      requiereAyuda: _requiereAyudante,
      requiereAcompanante: _acompanantes > 0,
      requiereSillaRuedas: _movilidad == 'silla_ruedas' || _movilidad == 'silla_electrica',
      requiereCamilla: _movilidad == 'camilla' || _movilidad == 'camilla_palas',

      // ✅ Configuración de recurrencia
      diasSemana: _diasSemanaSeleccionados.isNotEmpty ? _diasSemanaSeleccionados.toList() : null,
      intervaloSemanas: _modalidad == ModalidadServicio.semanasAlternas ? _intervaloSemanas : null,
      intervaloDias: _modalidad == ModalidadServicio.diasAlternos ? _intervaloDias : null,
      diasMes: _diasMesSeleccionados.isNotEmpty ? _diasMesSeleccionados.toList() : null,
      fechasEspecificas: _fechasEspecificas.isNotEmpty
          ? _fechasEspecificas.map((DateTime f) => f.toIso8601String()).toList()
          : null,

      // ❌ NO actualizamos: id, codigo, idPaciente, tipoRecurrencia, fechaServicioInicio, createdAt
    );

    await servicioRepository.update(servicioActualizado);
    debugPrint('📝 Wizard: ✅ Servicio base actualizado');

    // PASO 2: Actualizar servicio recurrente (si existe y NO es modalidad única)
    if (_modalidad != ModalidadServicio.unico) {
      debugPrint('📝 Wizard: Actualizando servicio recurrente...');

      final ServicioRecurrenteRepository recurrenteRepository = getIt<ServicioRecurrenteRepository>();

      // ✅ Verificar si ya existe un servicio recurrente para actualizar
      // Importante: Buscar por id_servicio (FK), no por id (PK del servicio_recurrente)
      try {
        final ServicioRecurrenteEntity existente = await recurrenteRepository.getByServicioId(servicioId);
        debugPrint('📝 Wizard: ✅ Servicio recurrente existente encontrado (ID: ${existente.id}, Código: ${existente.codigo})');

        // ✅ WORKAROUND: El trigger de Supabase solo se ejecuta en INSERT, no en UPDATE
        // Por lo tanto, eliminamos el servicio_recurrente existente y creamos uno nuevo
        // con el MISMO código para que se dispare el trigger de generación de traslados
        debugPrint('📝 Wizard: Eliminando servicio_recurrente existente (${existente.id}) para forzar regeneración...');
        await recurrenteRepository.hardDelete(existente.id);
        debugPrint('📝 Wizard: ✅ Servicio_recurrente existente eliminado físicamente (traslados eliminados por CASCADE)');

        // Crear nuevo servicio_recurrente con el MISMO código
        final ServicioRecurrenteEntity servicioRecurrente = ServicioCreator.crearEntidadServicioRecurrente(
          servicioId: servicio.id ?? '',
          paciente: _pacienteSeleccionado!,
          modalidad: _modalidad,
          fechaInicio: _fechaInicioTratamiento!,
          fechaFin: _fechaFinTratamiento,
          trayectos: _trayectos,
          motivoTrasladoId: _motivoTrasladoSeleccionado?.id,
          observaciones: _observacionesGenerales,
          diasSemana: _diasSemanaSeleccionados.toList(),
          intervaloSemanas: _intervaloSemanas,
          intervaloDias: _intervaloDias,
          diasMes: _diasMesSeleccionados.toList(),
          fechasEspecificas: _fechasEspecificas.toList(),
        );

        // ✅ Preservar el CÓDIGO del servicio recurrente existente
        final ServicioRecurrenteEntity servicioParaCrear = servicioRecurrente.copyWith(
          codigo: existente.codigo,
        );

        debugPrint('📝 Wizard: Creando nuevo servicio_recurrente con código: ${servicioParaCrear.codigo}');

        // Crear servicio recurrente nuevo (esto disparará el trigger)
        await recurrenteRepository.create(servicioParaCrear);
        debugPrint('📝 Wizard: ✅ Servicio recurrente RECREADO exitosamente (trigger disparado)');
      } catch (e) {
        debugPrint('📝 Wizard: ⚠️ No se encontró servicio recurrente existente, creando uno nuevo...');

        // Si no existe, crear uno nuevo
        final ServicioRecurrenteEntity servicioRecurrente = ServicioCreator.crearEntidadServicioRecurrente(
          servicioId: servicio.id ?? '',
          paciente: _pacienteSeleccionado!,
          modalidad: _modalidad,
          fechaInicio: _fechaInicioTratamiento!,
          fechaFin: _fechaFinTratamiento,
          trayectos: _trayectos,
          motivoTrasladoId: _motivoTrasladoSeleccionado?.id,
          observaciones: _observacionesGenerales,
          diasSemana: _diasSemanaSeleccionados.toList(),
          intervaloSemanas: _intervaloSemanas,
          intervaloDias: _intervaloDias,
          diasMes: _diasMesSeleccionados.toList(),
          fechasEspecificas: _fechasEspecificas.toList(),
        );

        await recurrenteRepository.create(servicioRecurrente);
        debugPrint('📝 Wizard: ✅ Servicio recurrente CREADO (trigger disparado)');
      }
    }

    // PASO 3: Eliminar TODOS los traslados del servicio_recurrente
    // (ya que vamos a regenerar todo desde cero con el trigger)
    debugPrint('📝 Wizard: Eliminando TODOS los traslados del servicio para regenerar...');

    // NOTA: Los traslados están vinculados a id_servicio_recurrente, NO a id_servicio
    // Por lo tanto, al eliminar el servicio_recurrente en PASO 2, los traslados
    // vinculados se eliminan automáticamente por la FK con ON DELETE CASCADE
    debugPrint('📝 Wizard: ✅ Traslados eliminados automáticamente por CASCADE del servicio_recurrente');

    // PASO 4: Traslados generados automáticamente por trigger
    debugPrint('📝 Wizard: ✅ Traslados regenerados automáticamente por trigger de Supabase');

    // El trigger de Supabase (generar_traslados_al_crear_servicio_recurrente)
    // se ejecutó automáticamente al crear el nuevo servicio_recurrente en PASO 2.
    // Los traslados se generan con estado inicial según configuración.

    debugPrint('📝 Wizard: ✅ Servicio actualizado exitosamente');
  }

  // ============================================================================
  // UI - BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSizes.spacing),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 900,
          maxHeight: 700,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            _buildHeader(),
            const Divider(height: 1, color: AppColors.gray200),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingXl),
                child: _buildCurrentStep(),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radius),
          topRight: Radius.circular(AppSizes.radius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.medical_services, color: Colors.white, size: 24),
              const SizedBox(width: AppSizes.spacingSmall),
              Text(
                _getTituloConPaso(),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Cerrar',
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing),
          _buildStepper(),
          const SizedBox(height: AppSizes.spacingSmall),
          _buildStepLabels(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      children: List<Widget>.generate(_totalSteps, (int index) {
        final bool isCompleted = index < _currentStep;
        final bool isCurrent = index == _currentStep;

        return Expanded(
          child: Row(
            children: <Widget>[
              if (index > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? AppColors.success : Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              _buildStepCircle(
                index + 1,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepCircle(int stepNumber, {required bool isCompleted, required bool isCurrent}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? AppColors.success
            : (isCurrent ? Colors.white : Colors.white.withValues(alpha: 0.3)),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : Text(
          stepNumber.toString(),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isCurrent ? AppColors.primary : Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildStepLabels() {
    return Row(
      children: <Widget>[
        _buildStepLabel('Básicos', 0),
        _buildStepLabel('Modalidad', 1),
        _buildStepLabel('Trayectos', 2),
        _buildStepLabel('Revisar', 3),
      ],
    );
  }

  Widget _buildStepLabel(String label, int stepIndex) {
    final bool isCurrent = stepIndex == _currentStep;

    return Expanded(
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            color: Colors.white.withValues(alpha: isCurrent ? 1.0 : 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(top: BorderSide(color: AppColors.gray200)),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radius),
          bottomRight: Radius.circular(AppSizes.radius),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          if (_currentStep > 0)
            AppButton(
              onPressed: _isCreating ? null : _previousStep,
              label: 'Atrás',
              icon: Icons.arrow_back,
              variant: AppButtonVariant.text,
            )
          else
            const SizedBox.shrink(),
          AppButton(
            onPressed: _isCreating ? null : _nextStep,
            label: _currentStep == _totalSteps - 1
                ? (_isEditMode ? 'Editar Servicio' : 'Crear Servicio')
                : 'Siguiente',
            icon: _currentStep == _totalSteps - 1 ? Icons.check : Icons.arrow_forward,
          ),
        ],
      ),
    );
  }

  String _getTituloConPaso() {
    final String base = _isEditMode ? 'Editar Servicio' : 'Crear Nuevo Servicio';
    switch (_currentStep) {
      case 0:
        return '$base - Datos Básicos';
      case 1:
        return '$base - Modalidad';
      case 2:
        return '$base - Trayectos';
      case 3:
        return '$base - Revisar';
      default:
        return base;
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return Step1DatosGenerales(
          formKey: _formKeyStep1,
          pacienteSeleccionado: _pacienteSeleccionado,
          pacientes: _pacientes,
          loadingPacientes: _loadingPacientes,
          facultativoSeleccionado: _facultativoSeleccionado,
          facultativos: _facultativos,
          loadingFacultativos: _loadingFacultativos,
          motivoTrasladoSeleccionado: _motivoTrasladoSeleccionado,
          motivosTraslado: _motivosTraslado,
          loadingMotivosTraslado: _loadingMotivosTraslado,
          fechaInicioTratamiento: _fechaInicioTratamiento,
          fechaFinTratamiento: _fechaFinTratamiento,
          horaEnCentro: _horaEnCentro,
          centroHospitalario: _centroHospitalarioPaso1,
          centrosHospitalarios: _centrosHospitalarios,
          movilidad: _movilidad,
          acompanantes: _acompanantes,
          tipoAmbulancia: _tipoAmbulancia,
          tiposVehiculo: _tiposVehiculo,
          loadingTiposVehiculo: _loadingTiposVehiculo,
          requiereOxigeno: _requiereOxigeno,
          requiereMedico: _requiereMedico,
          requiereDue: _requiereDue,
          requiereAyudante: _requiereAyudante,
          observacionesGenerales: _observacionesGenerales,
          observacionesMedicas: _observacionesMedicas,
          pacienteReadOnly: widget.paciente != null, // ✅ Si viene paciente pre-seleccionado, solo lectura
          onPacienteChanged: (PacienteEntity? paciente) {
            setState(() {
              _pacienteSeleccionado = paciente;
            });
          },
          onFacultativoChanged: (FacultativoEntity? facultativo) {
            setState(() {
              _facultativoSeleccionado = facultativo;
            });
          },
          onMotivoTrasladoChanged: (MotivoTrasladoEntity? motivo) {
            setState(() {
              _motivoTrasladoSeleccionado = motivo;
            });
          },
          onFechaInicioChanged: (DateTime? fecha) {
            setState(() {
              _fechaInicioTratamiento = fecha;
            });
          },
          onFechaFinChanged: (DateTime? fecha) {
            setState(() {
              _fechaFinTratamiento = fecha;
            });
          },
          onHoraEnCentroChanged: (TimeOfDay? hora) {
            setState(() {
              _horaEnCentro = hora;

              // ⚡ PROPAGACIÓN REACTIVA: Actualizar configuración de modalidad
              // cuando cambia la hora en el Step 1
              _actualizarHoraEnConfiguracionModalidad(hora);
            });
          },
          onCentroHospitalarioChanged: (CentroHospitalarioEntity? centro) {
            setState(() {
              _centroHospitalarioPaso1 = centro;
            });
          },
          onMovilidadChanged: (String movilidad) {
            setState(() {
              _movilidad = movilidad;
            });
          },
          onAcompanantesChanged: (int acompanantes) {
            setState(() {
              _acompanantes = acompanantes;
            });
          },
          onTipoAmbulanciaChanged: (String? tipo) {
            setState(() {
              _tipoAmbulancia = tipo;
            });
          },
          onRequiereOxigenoChanged: (bool requiere) {
            setState(() {
              _requiereOxigeno = requiere;
            });
          },
          onRequiereMedicoChanged: (bool requiere) {
            setState(() {
              _requiereMedico = requiere;
            });
          },
          onRequiereDueChanged: (bool requiere) {
            setState(() {
              _requiereDue = requiere;
            });
          },
          onRequiereAyudanteChanged: (bool requiere) {
            setState(() {
              _requiereAyudante = requiere;
            });
          },
          onObservacionesGeneralesChanged: (String? obs) {
            setState(() {
              _observacionesGenerales = obs;
            });
          },
          onObservacionesMedicasChanged: (String? obs) {
            setState(() {
              _observacionesMedicas = obs ?? '';
            });
          },
        );
      case 1:
        // Si no hay motivo de traslado seleccionado, mostrar mensaje
        if (_motivoTrasladoSeleccionado == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingXl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.info_outline,
                    size: 64,
                    color: AppColors.warning.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSizes.spacing),
                  Text(
                    'Selecciona un motivo de traslado en el Paso 1',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  Text(
                    'El motivo de traslado es necesario para configurar los horarios y tiempos de espera',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Step2Modalidad(
          formKey: _formKeyStep2,
          tipoRecurrencia: _mapModalidadToTipoRecurrencia(_modalidad),
          motivoTraslado: _motivoTrasladoSeleccionado!,
          configuracionInicial: _configuracionModalidad,
          horaEnCentro: _horaEnCentro,
          onTipoRecurrenciaChanged: (TipoRecurrencia tipo) {
            setState(() {
              _modalidad = _mapTipoRecurrenciaToModalidad(tipo);
              // Limpiar configuración al cambiar tipo
              _configuracionModalidad = null;
            });
          },
          onConfiguracionChanged: (Map<String, dynamic> configuracion) {
            if (!mounted) {
              return;
            }

            setState(() {
              _configuracionModalidad = configuracion;
              debugPrint('📋 Configuración actualizada: $_configuracionModalidad');

              // ✅ Extraer días de semana de la configuración para modalidades semanales
              if (_modalidad == ModalidadServicio.semanal || _modalidad == ModalidadServicio.semanasAlternas) {
                _diasSemanaSeleccionados.clear();
                final List<dynamic>? dias = configuracion['dias'] as List<dynamic>?;
                if (dias != null) {
                  for (final dynamic diaData in dias) {
                    if (diaData is Map<String, dynamic>) {
                      final int? diaSemanaIndex = diaData['dia_semana'] as int?;
                      if (diaSemanaIndex != null) {
                        _diasSemanaSeleccionados.add(diaSemanaIndex);
                      }
                    }
                  }
                  debugPrint('📅 Días de semana extraídos: $_diasSemanaSeleccionados');
                }
              }

              // ✅ Extraer días del mes de la configuración para modalidad mensual
              if (_modalidad == ModalidadServicio.mensual) {
                _diasMesSeleccionados.clear();
                final List<dynamic>? dias = configuracion['dias'] as List<dynamic>?;
                if (dias != null) {
                  for (final dynamic diaData in dias) {
                    if (diaData is Map<String, dynamic>) {
                      final int? diaMesNum = diaData['dia_mes'] as int?;
                      if (diaMesNum != null) {
                        _diasMesSeleccionados.add(diaMesNum);
                      }
                    }
                  }
                  debugPrint('📅 Días del mes extraídos: $_diasMesSeleccionados');
                }
              }

              // ✅ Extraer fechas específicas de la configuración
              if (_modalidad == ModalidadServicio.especifico) {
                _fechasEspecificas.clear();
                final List<dynamic>? fechas = configuracion['fechas'] as List<dynamic>?;
                if (fechas != null) {
                  for (final dynamic fechaData in fechas) {
                    if (fechaData is Map<String, dynamic>) {
                      final String? fechaStr = fechaData['fecha'] as String?;
                      if (fechaStr != null) {
                        try {
                          _fechasEspecificas.add(DateTime.parse(fechaStr));
                        } catch (e) {
                          debugPrint('⚠️ Error parseando fecha: $fechaStr - $e');
                        }
                      }
                    }
                  }
                  debugPrint('📅 Fechas específicas extraídas: $_fechasEspecificas');
                }
              }
            });
          },
        );
      case 2:
        return Step3Trayectos(
          formKey: _formKeyStep3,
          trayectos: _trayectos,
          centrosHospitalarios: _centrosHospitalarios,
          centrosDropdownItems: _centrosHospitalarios
              .map(
                (CentroHospitalarioEntity centro) => AppSearchableDropdownItem<CentroHospitalarioEntity>(
                  value: centro,
                  label: centro.nombre,
                  icon: Icons.local_hospital,
                  iconColor: AppColors.primary,
                ),
              )
              .toList(),
          loadingCentros: _loadingCentros,
          pacienteNombreCompleto: _pacienteSeleccionado != null
              ? '${_pacienteSeleccionado!.nombre} ${_pacienteSeleccionado!.primerApellido} ${_pacienteSeleccionado!.segundoApellido ?? ''}'.trim()
              : null,
          onTrayectosChanged: (List<TrayectoData> trayectos) {
            setState(() {
              _trayectos
                ..clear()
                ..addAll(trayectos);
            });
          },
        );
      case 3:
        return Step4Revision(
          paciente: _pacienteSeleccionado,
          motivoTraslado: _motivoTrasladoSeleccionado,
          fechaInicio: _fechaInicioTratamiento,
          fechaFin: _fechaFinTratamiento,
          observaciones: _observacionesGenerales,
          modalidad: _modalidad,
          diasSemana: _diasSemanaSeleccionados.toList(),
          intervaloSemanas: _intervaloSemanas,
          diasMes: _diasMesSeleccionados.toList(),
          trayectos: _trayectos,
          localidades: _localidades,
          isEditMode: _isEditMode,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
