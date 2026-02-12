import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/bloc/pacientes_bloc.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/bloc/pacientes_event.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/bloc/pacientes_state.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/tabs/paciente_tab_administrativo.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/tabs/paciente_tab_contacto.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/tabs/paciente_tab_personal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

/// Diálogo de formulario de Paciente con tabs
class PacienteFormDialog extends StatefulWidget {
  const PacienteFormDialog({
    super.key,
    this.paciente,
  });

  final PacienteEntity? paciente;

  @override
  State<PacienteFormDialog> createState() => _PacienteFormDialogState();
}

class _PacienteFormDialogState extends State<PacienteFormDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool get _isEditing => widget.paciente != null;

  // === CONTROLADORES TAB 1: DATOS PERSONALES ===
  late TextEditingController _nombreController;
  late TextEditingController _primerApellidoController;
  late TextEditingController _segundoApellidoController;
  late TextEditingController _documentoController;
  late TextEditingController _seguridadSocialController;
  late TextEditingController _numHistoriaController;
  late TextEditingController _profesionController;
  String _tipoDocumento = 'DNI';
  String _sexo = 'HOMBRE';
  DateTime? _fechaNacimiento;
  String _paisOrigen = 'España';

  // === CONTROLADORES TAB 2: CONTACTO Y DIRECCIÓN ===
  late TextEditingController _telefonoMovilController;
  late TextEditingController _telefonoFijoController;
  late TextEditingController _emailController;
  String? _provinciaId;
  String? _localidadId;
  late TextEditingController _domicilioDireccionController;
  late TextEditingController _recogidaDireccionController;

  // Listas para los dropdowns
  List<ProvinciaEntity> _provincias = <ProvinciaEntity>[];
  List<LocalidadEntity> _localidades = <LocalidadEntity>[];
  List<LocalidadEntity> _localidadesFiltradas = <LocalidadEntity>[];
  bool _isLoadingData = true;

  // === CONTROLADORES TAB 3: ADMINISTRATIVO ===
  late TextEditingController _mutuaAseguradoraController;
  late TextEditingController _numPolizaController;
  late TextEditingController _observacionesController;
  bool _consentimientoInformado = false;
  bool _consentimientoRgpd = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeControllers();
    _loadData();
  }

  void _initializeControllers() {
    final PacienteEntity? p = widget.paciente;

    // TAB 1: Datos Personales
    _nombreController = TextEditingController(text: p?.nombre ?? '');
    _primerApellidoController = TextEditingController(text: p?.primerApellido ?? '');
    _segundoApellidoController = TextEditingController(text: p?.segundoApellido ?? '');
    _documentoController = TextEditingController(text: p?.documento ?? '');
    _seguridadSocialController = TextEditingController(text: p?.seguridadSocial ?? '');
    _numHistoriaController = TextEditingController(text: p?.numHistoria ?? '');
    _profesionController = TextEditingController(text: p?.profesion ?? '');
    _tipoDocumento = p?.tipoDocumento ?? 'DNI';
    _sexo = p?.sexo ?? 'HOMBRE';
    _fechaNacimiento = p?.fechaNacimiento;
    _paisOrigen = p?.paisOrigen ?? 'España';

    // TAB 2: Contacto y Dirección
    _telefonoMovilController = TextEditingController(text: p?.telefonoMovil ?? '');
    _telefonoFijoController = TextEditingController(text: p?.telefonoFijo ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _provinciaId = p?.provinciaId;
    _localidadId = p?.localidadId;
    _domicilioDireccionController = TextEditingController(text: p?.domicilioDireccion ?? '');
    _recogidaDireccionController = TextEditingController(text: p?.recogidaInformacionAdicional ?? '');

    // TAB 3: Administrativo
    _mutuaAseguradoraController = TextEditingController(text: p?.mutuaAseguradora ?? '');
    _numPolizaController = TextEditingController(text: p?.numPoliza ?? '');
    _observacionesController = TextEditingController(text: p?.observaciones ?? '');
    _consentimientoInformado = p?.consentimientoInformado ?? false;
    _consentimientoRgpd = p?.consentimientoRgpd ?? false;
  }

  Future<void> _loadData() async {
    try {
      // Cargar provincias y localidades
      final ProvinciaDataSource provinciaDS = ProvinciaDataSourceFactory.createSupabase();
      final LocalidadDataSource localidadDS = LocalidadDataSourceFactory.createSupabase();

      final List<ProvinciaEntity> provincias = await provinciaDS.getAll();
      final List<LocalidadEntity> localidades = await localidadDS.getAll();

      if (mounted) {
        setState(() {
          _provincias = provincias;
          _localidades = localidades;
          _isLoadingData = false;

          // Si hay una provincia seleccionada, filtrar localidades
          if (_provinciaId != null) {
            _localidadesFiltradas = localidades
                .where((LocalidadEntity l) => l.provinciaId == _provinciaId)
                .toList();
          }
        });
      }
    } catch (e) {
      debugPrint('Error al cargar datos: $e');
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  void _onProvinciaChanged(String? value) {
    setState(() {
      _provinciaId = value;
      _localidadId = null; // Reset localidad al cambiar provincia
      _localidadesFiltradas = _localidades
          .where((LocalidadEntity l) => l.provinciaId == value)
          .toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    // TAB 1
    _nombreController.dispose();
    _primerApellidoController.dispose();
    _segundoApellidoController.dispose();
    _documentoController.dispose();
    _seguridadSocialController.dispose();
    _numHistoriaController.dispose();
    _profesionController.dispose();
    // TAB 2
    _telefonoMovilController.dispose();
    _telefonoFijoController.dispose();
    _emailController.dispose();
    _domicilioDireccionController.dispose();
    _recogidaDireccionController.dispose();
    // TAB 3
    _mutuaAseguradoraController.dispose();
    _numPolizaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PacientesBloc, PacientesState>(
      listener: (BuildContext context, PacientesState state) {
        if (state is PacientesLoaded) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Paciente',
            onClose: () => setState(() => _isSaving = false),
          );
        } else if (state is PacientesError) {
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Paciente',
            errorMessage: state.message,
            onClose: () => setState(() => _isSaving = false),
          );
        }
      },
      child: AppDialog(
        title: _isEditing ? 'Editar Paciente' : 'Agregar Paciente',
        maxWidth: 900,
        content: _isLoadingData
            ? const SizedBox(
                width: 900,
                height: 600,
                child: Center(
                  child: AppLoadingIndicator(
                    message: 'Cargando datos...',
                    size: 100,
                  ),
                ),
              )
            : SizedBox(
                width: 900,
                height: 600,
                child: Column(
            children: <Widget>[
              // Tab Bar
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(color: AppColors.gray300),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondaryLight,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const <Widget>[
                    Tab(text: '1. Datos Personales'),
                    Tab(text: '2. Contacto y Dirección'),
                    Tab(text: '3. Administrativo'),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spacing),

              // Tab Views
              Expanded(
                child: Form(
                  key: _formKey,
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      // TAB 1: Datos Personales
                      PacienteTabPersonal(
                        nombreController: _nombreController,
                        primerApellidoController: _primerApellidoController,
                        segundoApellidoController: _segundoApellidoController,
                        documentoController: _documentoController,
                        seguridadSocialController: _seguridadSocialController,
                        numHistoriaController: _numHistoriaController,
                        profesionController: _profesionController,
                        tipoDocumento: _tipoDocumento,
                        sexo: _sexo,
                        fechaNacimiento: _fechaNacimiento,
                        paisOrigen: _paisOrigen,
                        onTipoDocumentoChanged: (String? value) {
                          if (value != null) {
                            setState(() => _tipoDocumento = value);
                          }
                        },
                        onSexoChanged: (String? value) {
                          if (value != null) {
                            setState(() => _sexo = value);
                          }
                        },
                        onFechaNacimientoChanged: (DateTime? fecha) {
                          debugPrint('📅 onFechaNacimientoChanged llamado con: $fecha');
                          setState(() {
                            _fechaNacimiento = fecha;
                            debugPrint('📅 _fechaNacimiento actualizado a: $_fechaNacimiento');
                          });
                        },
                        onPaisOrigenChanged: (String? value) {
                          if (value != null) {
                            setState(() => _paisOrigen = value);
                          }
                        },
                      ),

                      // TAB 2: Contacto y Dirección
                      PacienteTabContacto(
                        telefonoMovilController: _telefonoMovilController,
                        telefonoFijoController: _telefonoFijoController,
                        emailController: _emailController,
                        provincias: _provincias,
                        localidadesFiltradas: _localidadesFiltradas,
                        provinciaId: _provinciaId,
                        localidadId: _localidadId,
                        domicilioDireccionController: _domicilioDireccionController,
                        recogidaDireccionController: _recogidaDireccionController,
                        onProvinciaChanged: _onProvinciaChanged,
                        onLocalidadChanged: (String? value) {
                          setState(() => _localidadId = value);
                        },
                        onCopiarDireccion: () {
                          setState(() {
                            _recogidaDireccionController.text = _domicilioDireccionController.text;
                          });
                        },
                      ),

                      // TAB 3: Administrativo y Consentimientos
                      PacienteTabAdministrativo(
                        mutuaAseguradoraController: _mutuaAseguradoraController,
                        numPolizaController: _numPolizaController,
                        observacionesController: _observacionesController,
                        consentimientoInformado: _consentimientoInformado,
                        consentimientoInformadoFecha: widget.paciente?.consentimientoInformadoFecha,
                        consentimientoRgpd: _consentimientoRgpd,
                        consentimientoRgpdFecha: widget.paciente?.consentimientoRgpdFecha,
                        onConsentimientoInformadoChanged: (bool? value) {
                          setState(() => _consentimientoInformado = value ?? false);
                        },
                        onConsentimientoRgpdChanged: (bool? value) {
                          setState(() => _consentimientoRgpd = value ?? false);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          AppButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            label: 'Cancelar',
            variant: AppButtonVariant.text,
          ),
          AppButton(
            onPressed: _isSaving ? null : _onSave,
            label: _isEditing ? 'Actualizar' : 'Guardar',
            icon: _isEditing ? Icons.save : Icons.add,
          ),
        ],
      ),
    );
  }

  void _onSave() {
    debugPrint('🔍 _onSave - _fechaNacimiento: $_fechaNacimiento');

    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ Validación del formulario falló');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Mostrar loading overlay
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppLoadingOverlay(
          message: _isEditing ? 'Actualizando paciente...' : 'Creando paciente...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        );
      },
    );

    // Generar identificación automática si no existe
    String? identificacion = widget.paciente?.identificacion;
    if (identificacion?.isEmpty ?? true) {
      // Generar identificación única usando los primeros 8 caracteres de UUID
      // Formato: PAC-XXXXXXXX (ejemplo: PAC-A3F2B891)
      final String uuid = const Uuid().v4().replaceAll('-', '').substring(0, 8).toUpperCase();
      identificacion = 'PAC-$uuid';
      debugPrint('🔑 Identificación generada automáticamente: $identificacion');
    }

    // Crear entidad
    final PacienteEntity paciente = PacienteEntity(
      id: _isEditing ? widget.paciente!.id : const Uuid().v4(),
      identificacion: identificacion,
      nombre: _nombreController.text.trim(),
      primerApellido: _primerApellidoController.text.trim(),
      segundoApellido: _segundoApellidoController.text.trim().isEmpty
          ? null
          : _segundoApellidoController.text.trim(),
      tipoDocumento: _tipoDocumento,
      documento: _documentoController.text.trim(),
      seguridadSocial: _seguridadSocialController.text.trim().isEmpty
          ? null
          : _seguridadSocialController.text.trim(),
      numHistoria: _numHistoriaController.text.trim().isEmpty
          ? null
          : _numHistoriaController.text.trim(),
      sexo: _sexo,
      fechaNacimiento: _fechaNacimiento ?? DateTime(2000),
      telefonoMovil: _telefonoMovilController.text.trim().isEmpty
          ? null
          : _telefonoMovilController.text.trim(),
      telefonoFijo: _telefonoFijoController.text.trim().isEmpty
          ? null
          : _telefonoFijoController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      paisOrigen: _paisOrigen,
      profesion:
          _profesionController.text.trim().isEmpty ? null : _profesionController.text.trim(),
      provinciaId: _provinciaId,
      localidadId: _localidadId,
      recogidaInformacionAdicional: _recogidaDireccionController.text.trim().isEmpty
          ? null
          : _recogidaDireccionController.text.trim(),
      domicilioDireccion: _domicilioDireccionController.text.trim().isEmpty
          ? null
          : _domicilioDireccionController.text.trim(),
      mutuaAseguradora: _mutuaAseguradoraController.text.trim().isEmpty
          ? null
          : _mutuaAseguradoraController.text.trim(),
      numPoliza: _numPolizaController.text.trim().isEmpty ? null : _numPolizaController.text.trim(),
      consentimientoInformado: _consentimientoInformado,
      consentimientoInformadoFecha:
          _consentimientoInformado ? DateTime.now() : widget.paciente?.consentimientoInformadoFecha,
      consentimientoRgpd: _consentimientoRgpd,
      consentimientoRgpdFecha:
          _consentimientoRgpd ? DateTime.now() : widget.paciente?.consentimientoRgpdFecha,
      observaciones: _observacionesController.text.trim().isEmpty
          ? null
          : _observacionesController.text.trim(),
    );

    // Disparar evento BLoC
    if (_isEditing) {
      context.read<PacientesBloc>().add(PacientesUpdateRequested(paciente));
    } else {
      context.read<PacientesBloc>().add(PacientesCreateRequested(paciente));
    }
  }
}
