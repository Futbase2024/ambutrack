import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/personal/data/services/tablas_maestras_service.dart';
import 'package:ambutrack_web/features/personal/domain/entities/categoria_personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/configuracion_validacion_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/empresa_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/poblacion_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/puesto_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/tipo_contrato_entity.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/asignacion_default_section.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/configuracion_validaciones_widget.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/personal_form_body.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/personal_form_data.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/personal_form_laboral.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Diálogo para crear/editar personal
class PersonalFormDialog extends StatefulWidget {
  const PersonalFormDialog({super.key, this.persona});

  final PersonalEntity? persona;

  @override
  State<PersonalFormDialog> createState() => _PersonalFormDialogState();
}

class _PersonalFormDialogState extends State<PersonalFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final PersonalFormData _data = PersonalFormData(p: widget.persona);

  final TablasMaestrasService _tablasMaestrasService = TablasMaestrasService();

  bool _isLoading = true;
  bool _isSaving = false;
  bool get _isEditing => widget.persona != null;

  @override
  void initState() {
    super.initState();
    _loadTablasMaestras();
  }

  Future<void> _loadTablasMaestras() async {
    final DateTime startTime = DateTime.now();
    debugPrint('⏱️ PersonalFormDialog: Iniciando carga de tablas maestras...');

    final PersonalEntity? p = widget.persona;

    // Medir tiempo de cada llamada
    final DateTime t1 = DateTime.now();
    final List<ProvinciaEntity> provincias = await _tablasMaestrasService.getProvincias();
    debugPrint('⏱️ Provincias cargadas en ${DateTime.now().difference(t1).inMilliseconds}ms');

    final DateTime t2 = DateTime.now();
    final List<PuestoEntity> puestos = await _tablasMaestrasService.getPuestos();
    debugPrint('⏱️ Puestos cargados en ${DateTime.now().difference(t2).inMilliseconds}ms');

    final DateTime t3 = DateTime.now();
    final List<TipoContratoEntity> contratos = await _tablasMaestrasService.getContratos();
    debugPrint('⏱️ Tipos de contrato cargados en ${DateTime.now().difference(t3).inMilliseconds}ms');

    final DateTime t4 = DateTime.now();
    final List<EmpresaEntity> empresas = await _tablasMaestrasService.getEmpresas();
    debugPrint('⏱️ Empresas cargadas en ${DateTime.now().difference(t4).inMilliseconds}ms');

    final DateTime t5 = DateTime.now();
    final List<CategoriaPersonalEntity> categorias = await _tablasMaestrasService.getCategorias();
    debugPrint('⏱️ Categorías cargadas en ${DateTime.now().difference(t5).inMilliseconds}ms');

    // Cargar datos para asignación por defecto (en paralelo)
    final DateTime t6 = DateTime.now();
    final List<ContratoEntity> contratosCliente = await _tablasMaestrasService.getContratosCliente();
    debugPrint('⏱️ Contratos cliente cargados en ${DateTime.now().difference(t6).inMilliseconds}ms');

    final DateTime t7 = DateTime.now();
    final List<BaseCentroEntity> bases = await _tablasMaestrasService.getBases();
    debugPrint('⏱️ Bases cargadas en ${DateTime.now().difference(t7).inMilliseconds}ms');

    final DateTime t8 = DateTime.now();
    final List<DotacionEntity> dotaciones = await _tablasMaestrasService.getDotaciones();
    debugPrint('⏱️ Dotaciones cargadas en ${DateTime.now().difference(t8).inMilliseconds}ms');

    final DateTime t9 = DateTime.now();
    final List<VehiculoEntity> vehiculos = await _tablasMaestrasService.getVehiculos();
    debugPrint('⏱️ Vehículos cargados en ${DateTime.now().difference(t9).inMilliseconds}ms');

    if (mounted) {
      setState(() {
        _data
          ..provincias = provincias
          ..puestos = puestos
          ..contratos = contratos
          ..empresas = empresas
          ..categoriasPersonal = categorias
          ..contratosCliente = contratosCliente
          ..bases = bases
          ..dotaciones = dotaciones
          ..vehiculos = vehiculos;

        // Asignar valores DESPUÉS de cargar las listas
        if (p != null) {
          _data.asignarClaves(p);
        }
      });

      if (_data.provinciaId != null) {
        final DateTime t6 = DateTime.now();
        await _loadPoblaciones(_data.provinciaId!);
        debugPrint('⏱️ Poblaciones cargadas en ${DateTime.now().difference(t6).inMilliseconds}ms');
      }

      // Marcar como cargado
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    final Duration totalTime = DateTime.now().difference(startTime);
    debugPrint('⏱️ PersonalFormDialog: ✅ TOTAL carga de tablas maestras: ${totalTime.inMilliseconds}ms');
  }

  Future<void> _loadPoblaciones(String provinciaId) async {
    final List<PoblacionEntity> poblaciones =
        await _tablasMaestrasService.getPoblaciones(provinciaId: provinciaId);

    if (mounted) {
      setState(() {
        _data.poblaciones = poblaciones;
      });
    }
  }

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  void _onProvinciaChanged(String? value) {
    setState(() {
      _data
        ..provinciaId = value
        ..poblacionId = null
        ..poblaciones = <PoblacionEntity>[];
    });
    if (value != null) {
      _loadPoblaciones(value);
    }
  }

  void _onBlocState(BuildContext context, PersonalState state) {
    if (!_isSaving) {
      return;
    }
    if (state is PersonalLoaded) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Personal',
        onClose: () => setState(() => _isSaving = false),
      );
    } else if (state is PersonalError) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Personal',
        errorMessage: state.message,
        onClose: () => setState(() => _isSaving = false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final PersonalEntity? p = widget.persona;
    return BlocListener<PersonalBloc, PersonalState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: _isEditing ? 'Editar personal' : 'Nuevo personal',
        subtitle: p != null ? '${p.nombre} ${p.apellidos}'.toUpperCase() : null,
        icon: _isEditing ? Icons.edit_outlined : Icons.person_add_alt_1_outlined,
        size: GestionFormSize.large,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        saveLabel: _isEditing ? 'Actualizar' : 'Crear',
        onSave: _onSave,
        children: _isLoading
            ? const <Widget>[AppLoadingIndicator(message: 'Cargando datos del personal...', size: 100)]
            : <Widget>[
                PersonalFormBody(
                  data: _data,
                  onChanged: () => setState(() {}),
                  onProvinciaChanged: _onProvinciaChanged,
                ),
                PersonalFormLaboral(data: _data, onChanged: () => setState(() {})),
                ConfiguracionValidacionesWidget(
                  configuracion: _data.configuracionValidaciones,
                  onConfiguracionChanged: (ConfiguracionValidacionEntity? config) {
                    setState(() => _data.configuracionValidaciones = config);
                  },
                ),
                AsignacionDefaultSection(
                  contratoAsignadoId: _data.contratoAsignadoId,
                  baseId: _data.baseId,
                  dotacionId: _data.dotacionId,
                  vehiculoId: _data.vehiculoId,
                  contratos: _data.contratosCliente,
                  bases: _data.bases,
                  dotaciones: _data.dotaciones,
                  vehiculos: _data.vehiculos,
                  onContratoChanged: (String? v) => setState(() => _data.contratoAsignadoId = v),
                  onBaseChanged: (String? v) => setState(() => _data.baseId = v),
                  onDotacionChanged: (String? v) => setState(() => _data.dotacionId = v),
                  onVehiculoChanged: (String? v) => setState(() => _data.vehiculoId = v),
                ),
              ],
      ),
    );
  }

  void _onSave() {
    if (_isLoading) {
      return;
    }
    if (_formKey.currentState!.validate()) {
      debugPrint('👤 PersonalFormDialog: Validación exitosa, creando entidad...');

      final String nombre = _data.nombre.text.trim().toUpperCase();
      final String apellidos = _data.apellidos.text.trim().toUpperCase();

      // Obtener usuario autenticado
      final User? currentUser = Supabase.instance.client.auth.currentUser;
      final String? userId = currentUser?.id;

      final PersonalEntity persona = PersonalEntity(
        id: widget.persona?.id ?? '',
        nombre: nombre,
        apellidos: apellidos,
        dni: _data.dni.text.isNotEmpty ? _data.dni.text.trim() : null,
        nass: _data.nass.text.isNotEmpty ? _data.nass.text.trim() : null,
        email: _data.email.text.isNotEmpty ? _data.email.text.trim() : null,
        telefono: _data.telefono.text.isNotEmpty ? _data.telefono.text.trim() : null,
        movil: _data.movil.text.isNotEmpty ? _data.movil.text.trim() : null,
        direccion: _data.direccion.text.isNotEmpty ? _data.direccion.text.trim() : null,
        codigoPostal: _data.codigoPostal.text.isNotEmpty ? _data.codigoPostal.text.trim() : null,
        usuario: _data.usuario.text.isNotEmpty ? _data.usuario.text.trim() : null,
        pwdWeb: _data.pwdWeb.text.isNotEmpty ? _data.pwdWeb.text.trim() : null,
        pwd: _data.pwd.text.isNotEmpty ? _data.pwd.text.trim() : null,
        tesSiNo: _data.tesSiNo,
        dataAnti: _data.dataAnti,
        fechaNacimiento: _data.fechaNacimiento,
        fechaInicio: _data.fechaInicio,
        fechaAlta: _data.fechaAlta,
        provinciaId: _data.provinciaId,
        poblacionId: _data.poblacionId,
        puestoTrabajoId: _data.puestoId,
        contratoId: _data.contratoId,
        empresaId: _data.empresaIdFk,
        categoriaId: _data.categoriaIdFk,
        categoriaServicio: _data.categoriaServicio,
        configuracionValidaciones: _data.configuracionValidaciones,
        contratoAsignadoId: _data.contratoAsignadoId,
        baseId: _data.baseId,
        dotacionId: _data.dotacionId,
        vehiculoId: _data.vehiculoId,
        createdAt: widget.persona?.createdAt ?? DateTime.now(),
        createdBy: widget.persona?.createdBy ?? userId,
        updatedAt: _isEditing ? DateTime.now() : null,
        updatedBy: _isEditing ? userId : null,
      );

      debugPrint('👤 PersonalFormDialog: ${_isEditing ? "Actualizando" : "Creando"} personal - ${persona.nombreCompleto}');
      debugPrint('👤 PersonalFormDialog: DNI: ${persona.dni}, NASS: ${persona.nass}');

      // Mostrar loading overlay
      setState(() {
        _isSaving = true;
      });

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AppLoadingOverlay(
            message: _isEditing ? 'Actualizando personal...' : 'Creando personal...',
            color: _isEditing ? AppColors.secondary : AppColors.primary,
            icon: _isEditing ? Icons.edit : Icons.person_add,
          );
        },
      );

      if (_isEditing) {
        debugPrint('👤 PersonalFormDialog: Enviando evento PersonalUpdateRequested al BLoC...');
        context.read<PersonalBloc>().add(PersonalUpdateRequested(persona: persona));
      } else {
        debugPrint('👤 PersonalFormDialog: Enviando evento PersonalCreateRequested al BLoC...');
        context.read<PersonalBloc>().add(PersonalCreateRequested(persona: persona));
      }
    } else {
      debugPrint('❌ PersonalFormDialog: Validación fallida');
    }
  }
}
