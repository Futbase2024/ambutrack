part of '../turno_form_dialog.dart';

/// Catálogos del formulario de turnos (contratos, bases, vehículos,
/// dotaciones, funciones y plantillas) y su carga desde los repositorios.
mixin _TurnoFormCatalogos on State<TurnoFormDialog> {
  /// Fecha de inicio del turno (filtra las dotaciones vigentes)
  DateTime get _fechaInicio;

  // Plantilla seleccionada
  String? _idPlantillaSeleccionada;

  // Vehículo seleccionado
  String? _idVehiculo;
  List<VehiculoEntity> _vehiculosDisponibles = <VehiculoEntity>[];
  bool _isLoadingVehiculos = false;

  // Contrato seleccionado
  String? _idContrato;
  List<ContratoEntity> _contratosDisponibles = <ContratoEntity>[];
  bool _isLoadingContratos = false;

  // Base seleccionada (opcional)
  String? _idBase;
  List<BaseCentroEntity> _basesDisponibles = <BaseCentroEntity>[];
  bool _isLoadingBases = false;

  // Categoría/Función del personal
  String? _categoriaPersonal;

  // Dotación seleccionada
  String? _idDotacion;
  List<DotacionEntity> _dotacionesDisponibles = <DotacionEntity>[];
  bool _isLoadingDotaciones = false;

  // Categorías/Función desde BBDD
  List<CategoriaPersonalEntity> _categoriasDisponibles = <CategoriaPersonalEntity>[];
  bool _isLoadingCategorias = false;

  // Plantillas de turno desde BBDD
  List<PlantillaTurnoEntity> _plantillasDisponibles = <PlantillaTurnoEntity>[];
  bool _isLoadingPlantillas = false;

  /// Carga todos los catálogos del formulario
  void _loadCatalogos() {
    _loadContratos();
    _loadBases();
    _loadVehiculos();
    _loadDotaciones();
    _loadCategorias();
    _loadPlantillas();
  }

  /// Carga los vehículos disponibles desde el repositorio
  Future<void> _loadVehiculos() async {
    setState(() => _isLoadingVehiculos = true);

    try {
      final VehiculoRepository repository = getIt<VehiculoRepository>();
      final List<VehiculoEntity> vehiculos = await repository.getAll();

      // Filtrar solo vehículos activos y ordenar alfabéticamente por matrícula
      final List<VehiculoEntity> vehiculosOperativos = vehiculos
          .where((VehiculoEntity v) => v.estado == VehiculoEstado.activo)
          .toList()
        ..sort((VehiculoEntity a, VehiculoEntity b) =>
            a.matricula.toLowerCase().compareTo(b.matricula.toLowerCase()));

      // Si estamos editando y el vehículo asignado no está en la lista, agregarlo
      if (_idVehiculo != null && _idVehiculo!.isNotEmpty) {
        final bool vehiculoEnLista = vehiculosOperativos.any((VehiculoEntity v) => v.id == _idVehiculo);
        if (!vehiculoEnLista) {
          try {
            final VehiculoEntity vehiculoAsignado = vehiculos.firstWhere(
              (VehiculoEntity v) => v.id == _idVehiculo,
            );
            vehiculosOperativos.insert(0, vehiculoAsignado);
            debugPrint('⚠️ Vehículo asignado no está activo, incluido en lista: ${vehiculoAsignado.matricula}');
          } catch (e) {
            debugPrint('⚠️ Vehículo asignado no encontrado en repositorio, limpiando: $_idVehiculo');
            if (mounted) {
              setState(() => _idVehiculo = null);
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _vehiculosDisponibles = vehiculosOperativos;
          _isLoadingVehiculos = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar vehículos: $e');
      if (mounted) {
        setState(() => _isLoadingVehiculos = false);
      }
    }
  }

  /// Carga los contratos disponibles desde el repositorio
  Future<void> _loadContratos() async {
    setState(() => _isLoadingContratos = true);

    try {
      final ContratoRepository repository = getIt<ContratoRepository>();
      final List<ContratoEntity> contratos = await repository.getAll();

      // Filtrar solo contratos activos y vigentes y ordenar alfabéticamente
      final List<ContratoEntity> contratosVigentes = contratos.where((ContratoEntity c) =>
        c.activo && c.esVigente
      ).toList()
        ..sort((ContratoEntity a, ContratoEntity b) =>
            a.codigo.toLowerCase().compareTo(b.codigo.toLowerCase()));

      // Si estamos editando y el contrato asignado no está en la lista, agregarlo
      if (_idContrato != null && _idContrato!.isNotEmpty) {
        final bool contratoEnLista = contratosVigentes.any((ContratoEntity c) => c.id == _idContrato);
        if (!contratoEnLista) {
          try {
            final ContratoEntity contratoAsignado = contratos.firstWhere(
              (ContratoEntity c) => c.id == _idContrato,
            );
            contratosVigentes.insert(0, contratoAsignado);
            debugPrint('⚠️ Contrato asignado no está vigente, incluido en lista: ${contratoAsignado.codigo}');
          } catch (e) {
            debugPrint('⚠️ Contrato asignado no encontrado en repositorio, limpiando: $_idContrato');
            if (mounted) {
              setState(() => _idContrato = null);
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _contratosDisponibles = contratosVigentes;
          _isLoadingContratos = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar contratos: $e');
      if (mounted) {
        setState(() => _isLoadingContratos = false);
      }
    }
  }

  /// Carga las bases disponibles desde el repositorio
  Future<void> _loadBases() async {
    setState(() => _isLoadingBases = true);

    try {
      final BasesRepository repository = getIt<BasesRepository>();
      final List<BaseCentroEntity> bases = await repository.getAll();

      // Filtrar solo bases activas y ordenar alfabéticamente
      final List<BaseCentroEntity> basesActivas = bases.where((BaseCentroEntity b) =>
        b.activo
      ).toList()
        ..sort((BaseCentroEntity a, BaseCentroEntity b) =>
            a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

      // Si estamos editando y la base asignada no está en la lista, agregarla
      if (_idBase != null && _idBase!.isNotEmpty) {
        final bool baseEnLista = basesActivas.any((BaseCentroEntity b) => b.id == _idBase);
        if (!baseEnLista) {
          try {
            final BaseCentroEntity baseAsignada = bases.firstWhere(
              (BaseCentroEntity b) => b.id == _idBase,
            );
            basesActivas.insert(0, baseAsignada);
            debugPrint('⚠️ Base asignada no está activa, incluida en lista: ${baseAsignada.nombre}');
          } catch (e) {
            debugPrint('⚠️ Base asignada no encontrada en repositorio, limpiando: $_idBase');
            if (mounted) {
              setState(() => _idBase = null);
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _basesDisponibles = basesActivas;
          _isLoadingBases = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar bases: $e');
      if (mounted) {
        setState(() => _isLoadingBases = false);
      }
    }
  }

  Future<void> _loadDotaciones() async {
    setState(() => _isLoadingDotaciones = true);

    try {
      final DotacionesRepository repository = getIt<DotacionesRepository>();
      final List<DotacionEntity> dotaciones = await repository.getAll();

      // Filtrar solo dotaciones activas y vigentes en la fecha del turno, ordenar alfabéticamente
      final List<DotacionEntity> dotacionesVigentes = dotaciones.where((DotacionEntity d) =>
        d.activo && d.esVigenteEn(_fechaInicio)
      ).toList()
        ..sort((DotacionEntity a, DotacionEntity b) =>
            a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

      // Si estamos editando y la dotación asignada no está en la lista, agregarla
      if (_idDotacion != null && _idDotacion!.isNotEmpty) {
        final bool dotacionEnLista = dotacionesVigentes.any((DotacionEntity d) => d.id == _idDotacion);
        if (!dotacionEnLista) {
          try {
            final DotacionEntity dotacionAsignada = dotaciones.firstWhere(
              (DotacionEntity d) => d.id == _idDotacion,
            );
            dotacionesVigentes.insert(0, dotacionAsignada);
            debugPrint('⚠️ Dotación asignada no está vigente, incluida en lista: ${dotacionAsignada.nombre}');
          } catch (e) {
            debugPrint('⚠️ Dotación asignada no encontrada en repositorio, limpiando: $_idDotacion');
            if (mounted) {
              setState(() => _idDotacion = null);
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _dotacionesDisponibles = dotacionesVigentes;
          _isLoadingDotaciones = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar dotaciones: $e');
      if (mounted) {
        setState(() => _isLoadingDotaciones = false);
      }
    }
  }

  /// Carga las categorías desde TablasMaestrasService
  Future<void> _loadCategorias() async {
    setState(() => _isLoadingCategorias = true);

    try {
      final List<CategoriaPersonalEntity> categorias = await TablasMaestrasService().getCategorias();

      // Ordenar alfabéticamente
      categorias.sort((CategoriaPersonalEntity a, CategoriaPersonalEntity b) =>
          a.categoria.toLowerCase().compareTo(b.categoria.toLowerCase()));

      // Si la categoría asignada no está en la lista, agregarla
      if (_categoriaPersonal != null && _categoriaPersonal!.isNotEmpty) {
        final bool categoriaEnLista = categorias.any(
          (CategoriaPersonalEntity c) => c.categoria == _categoriaPersonal,
        );
        if (!categoriaEnLista) {
          debugPrint('⚠️ Categoría "$_categoriaPersonal" no está en BBDD, forzando inclusión');
          categorias.insert(
            0,
            CategoriaPersonalEntity(
              id: '',
              nombre: '',
              categoria: _categoriaPersonal!,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _categoriasDisponibles = categorias;
          _isLoadingCategorias = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar categorías: $e');
      if (mounted) {
        setState(() => _isLoadingCategorias = false);
      }
    }
  }

  /// Carga las plantillas de turno desde el repositorio
  Future<void> _loadPlantillas() async {
    setState(() => _isLoadingPlantillas = true);

    try {
      final PlantillaTurnoRepository repository = getIt<PlantillaTurnoRepository>();
      final List<PlantillaTurnoEntity> plantillas = await repository.getAll();

      // Filtrar solo plantillas activas y ordenar alfabéticamente
      final List<PlantillaTurnoEntity> plantillasActivas = plantillas
          .where((PlantillaTurnoEntity p) => p.activo)
          .toList()
        ..sort((PlantillaTurnoEntity a, PlantillaTurnoEntity b) =>
            a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

      // Si la plantilla asignada no está en la lista, agregarla
      if (_idPlantillaSeleccionada != null && _idPlantillaSeleccionada!.isNotEmpty) {
        final bool plantillaEnLista = plantillasActivas.any(
          (PlantillaTurnoEntity p) => p.id == _idPlantillaSeleccionada,
        );
        if (!plantillaEnLista) {
          try {
            final PlantillaTurnoEntity plantillaAsignada = plantillas.firstWhere(
              (PlantillaTurnoEntity p) => p.id == _idPlantillaSeleccionada,
            );
            plantillasActivas.insert(0, plantillaAsignada);
            debugPrint('⚠️ Plantilla asignada no está activa, incluida en lista: ${plantillaAsignada.nombre}');
          } catch (e) {
            debugPrint('⚠️ Plantilla asignada no encontrada, limpiando: $_idPlantillaSeleccionada');
            if (mounted) {
              setState(() => _idPlantillaSeleccionada = null);
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _plantillasDisponibles = plantillasActivas;
          _isLoadingPlantillas = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar plantillas: $e');
      if (mounted) {
        setState(() => _isLoadingPlantillas = false);
      }
    }
  }
}
