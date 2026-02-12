import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/utils/upper_case_text_formatter.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/personal/data/services/tablas_maestras_service.dart';
import 'package:ambutrack_web/features/personal/domain/entities/categoria_personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/categoria_servicio.dart';
import 'package:ambutrack_web/features/personal/domain/entities/configuracion_validacion_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/empresa_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/poblacion_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/puesto_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/tipo_contrato_entity.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/configuracion_validaciones_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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

  late TextEditingController _nombreController;
  late TextEditingController _apellidosController;
  late TextEditingController _dniController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _movilController;
  late TextEditingController _direccionController;
  late TextEditingController _codigoPostalController;
  late TextEditingController _nassController;
  late TextEditingController _usuarioController;
  late TextEditingController _pwdWebController;
  late TextEditingController _pwdController;

  bool _tesSiNo = false;
  DateTime? _fechaNacimiento;
  DateTime? _fechaInicio;
  DateTime? _fechaAlta;
  DateTime? _dataAnti;

  // Foreign Keys
  String? _provinciaId;
  String? _poblacionId;
  String? _puestoId;
  String? _contratoId;
  String? _empresaIdFk;
  String? _categoriaIdFk;
  CategoriaServicio _categoriaServicio = CategoriaServicio.programado;

  // Configuración de validaciones de turnos
  ConfiguracionValidacionEntity? _configuracionValidaciones;

  // Listas para dropdowns
  List<ProvinciaEntity> _provincias = <ProvinciaEntity>[];
  List<PoblacionEntity> _poblaciones = <PoblacionEntity>[];
  List<PuestoEntity> _puestos = <PuestoEntity>[];
  List<TipoContratoEntity> _contratos = <TipoContratoEntity>[];
  List<EmpresaEntity> _empresas = <EmpresaEntity>[];
  List<CategoriaPersonalEntity> _categoriasPersonal = <CategoriaPersonalEntity>[];

  final TablasMaestrasService _tablasMaestrasService = TablasMaestrasService();

  bool _isLoading = true;
  bool _isSaving = false;
  bool get _isEditing => widget.persona != null;

  @override
  void initState() {
    super.initState();
    final PersonalEntity? p = widget.persona;

    _nombreController = TextEditingController(text: (p?.nombre ?? '').toUpperCase());
    _apellidosController = TextEditingController(text: (p?.apellidos ?? '').toUpperCase());
    _dniController = TextEditingController(text: p?.dni ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _telefonoController = TextEditingController(text: p?.telefono ?? '');
    _movilController = TextEditingController(text: p?.movil ?? '');
    _direccionController = TextEditingController(text: p?.direccion ?? '');
    _codigoPostalController = TextEditingController(text: p?.codigoPostal ?? '');
    _nassController = TextEditingController(text: p?.nass ?? '');
    _usuarioController = TextEditingController(text: p?.usuario ?? '');
    _pwdWebController = TextEditingController(text: p?.pwdWeb ?? '');
    _pwdController = TextEditingController(text: p?.pwd ?? '');

    if (p != null) {
      _tesSiNo = p.tesSiNo ?? false;
      _fechaNacimiento = p.fechaNacimiento;
      _fechaInicio = p.fechaInicio;
      _fechaAlta = p.fechaAlta;
      _dataAnti = p.dataAnti;
      _categoriaServicio = p.categoriaServicio;
      _configuracionValidaciones = p.configuracionValidaciones;
    }

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

    if (mounted) {
      setState(() {
        _provincias = provincias;
        _puestos = puestos;
        _contratos = contratos;
        _empresas = empresas;
        _categoriasPersonal = categorias;

        // Asignar valores DESPUÉS de cargar las listas
        if (p != null) {
          _provinciaId = p.provinciaId;
          _poblacionId = p.poblacionId;
          _puestoId = p.puestoTrabajoId;
          _contratoId = p.contratoId;
          _empresaIdFk = p.empresaId;
          _categoriaIdFk = p.categoriaId;
        }
      });

      if (_provinciaId != null) {
        final DateTime t6 = DateTime.now();
        await _loadPoblaciones(_provinciaId!);
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
        _poblaciones = poblaciones;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _dniController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _movilController.dispose();
    _direccionController.dispose();
    _codigoPostalController.dispose();
    _nassController.dispose();
    _usuarioController.dispose();
    _pwdWebController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PersonalBloc, PersonalState>(
      listener: (BuildContext context, PersonalState state) {
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
      },
      child: AppDialog(
        title: _isEditing ? 'Editar Personal' : 'Nuevo Personal',
        icon: _isEditing ? Icons.edit : Icons.person_add,
        maxWidth: 900,
        type: _isEditing ? AppDialogType.edit : AppDialogType.create,
        content: _isLoading
            ? const Center(
                child: AppLoadingIndicator(
                  message: 'Cargando datos del personal...',
                  size: 100,
                ),
              )
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
              // Información Personal
              _buildSectionTitle('Información Personal'),
              const SizedBox(height: AppSizes.spacingMedium),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildTextField(
                      controller: _nombreController,
                      label: 'Nombre *',
                      hint: 'Ej: Juan',
                      validator: _requiredValidator,
                      inputFormatters: <TextInputFormatter>[UpperCaseTextFormatter()],
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing),
                  Expanded(
                    child: _buildTextField(
                      controller: _apellidosController,
                      label: 'Apellidos *',
                      hint: 'Ej: García Pérez',
                      validator: _requiredValidator,
                      inputFormatters: <TextInputFormatter>[UpperCaseTextFormatter()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildTextField(
                      controller: _dniController,
                      label: 'DNI/NIE',
                      hint: 'Ej: 12345678A',
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing),
                  Expanded(
                    child: _buildTextField(
                      controller: _nassController,
                      label: 'Nº Seguridad Social (NASS)',
                      hint: '123456789012',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildDatePicker(
                      label: 'Fecha de Nacimiento',
                      value: _fechaNacimiento,
                      onChanged: (DateTime date) {
                        setState(() => _fechaNacimiento = date);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing),
                  Expanded(
                    child: _buildDatePicker(
                      label: 'Fecha de Inicio',
                      value: _fechaInicio,
                      onChanged: (DateTime date) {
                        setState(() => _fechaInicio = date);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingLarge),

              // Categoría Laboral
              _buildSectionTitle('Categoría Laboral'),
              const SizedBox(height: AppSizes.spacingMedium),
              Row(
                children: <Widget>[
                  Expanded(child: _buildCategoriaPersonalDropdown()),
                  const SizedBox(width: AppSizes.spacing),
                  Expanded(child: _buildCategoriaServicioDropdown()),
                ],
              ),
              const SizedBox(height: AppSizes.spacingLarge),

              // Contacto
              _buildSectionTitle('Contacto'),
              const SizedBox(height: AppSizes.spacingMedium),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'ejemplo@correo.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing),
                  Expanded(
                    child: _buildTextField(
                      controller: _telefonoController,
                      label: 'Teléfono Fijo',
                      hint: '+34 912 345 678',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildTextField(
                      controller: _movilController,
                      label: 'Teléfono Móvil',
                      hint: '+34 600 000 000',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing),
                  Expanded(child: Container()),
                ],
              ),
              const SizedBox(height: AppSizes.spacing),
              _buildTextField(
                controller: _direccionController,
                label: 'Dirección',
                hint: 'Calle, número, piso',
              ),
              const SizedBox(height: AppSizes.spacing),
              _buildTextField(
                controller: _codigoPostalController,
                label: 'Código Postal',
                hint: '28001',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSizes.spacingLarge),

              // Ubicación
              _buildSectionTitle('Ubicación'),
              const SizedBox(height: AppSizes.spacingMedium),
              Row(
                children: <Widget>[
                  Expanded(child: _buildProvinciaDropdown()),
                  const SizedBox(width: AppSizes.spacing),
                  Expanded(child: _buildPoblacionDropdown()),
                ],
              ),
              const SizedBox(height: AppSizes.spacingLarge),

              // Información Laboral
              _buildSectionTitle('Información Laboral'),
              const SizedBox(height: AppSizes.spacingMedium),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildDatePicker(
                      label: 'Fecha de Alta',
                      value: _fechaAlta,
                      onChanged: (DateTime date) {
                        setState(() => _fechaAlta = date);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing),
                  Expanded(child: _buildEmpresaDropdown()),
                ],
              ),
              const SizedBox(height: AppSizes.spacing),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildTextField(
                      controller: _usuarioController,
                      label: 'Usuario',
                      hint: 'Nombre de usuario',
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing),
                  Expanded(
                    child: _buildDatePicker(
                      label: 'Fecha Antigüedad',
                      value: _dataAnti,
                      onChanged: (DateTime date) {
                        setState(() => _dataAnti = date);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildTextField(
                      controller: _pwdWebController,
                      label: 'Contraseña Web',
                      hint: '••••••••',
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing),
                  Expanded(
                    child: _buildTextField(
                      controller: _pwdController,
                      label: 'Contraseña',
                      hint: '••••••••',
                      obscureText: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing),
              _buildTesSwitch(),
              const SizedBox(height: AppSizes.spacing),
              Row(
                children: <Widget>[
                  Expanded(child: _buildPuestoDropdown()),
                  const SizedBox(width: AppSizes.spacing),
                  Expanded(child: _buildContratoDropdown()),
                ],
              ),
              const SizedBox(height: AppSizes.spacing),
              _buildEmpresaDropdown(),

              // Configuración de Validaciones de Turnos
              const SizedBox(height: AppSizes.spacingLarge),
              _buildSectionTitle('Configuración de Turnos'),
              const SizedBox(height: AppSizes.spacingMedium),
              ConfiguracionValidacionesWidget(
                configuracion: _configuracionValidaciones,
                onConfiguracionChanged: (ConfiguracionValidacionEntity? config) {
                  setState(() {
                    _configuracionValidaciones = config;
                  });
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          AppButton(
            onPressed: () => Navigator.of(context).pop(),
            label: 'Cancelar',
            variant: AppButtonVariant.text,
          ),
          AppButton(
            onPressed: _isLoading ? null : _onSave,
            label: _isEditing ? 'Actualizar' : 'Crear',
            variant: _isEditing ? AppButtonVariant.secondary : AppButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: AppSizes.fontMedium,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: validator,
      obscureText: obscureText,
      textInputAction: maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }


  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required void Function(DateTime) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
        ),
        child: Text(
          value != null ? DateFormat('dd/MM/yyyy').format(value) : 'Seleccionar',
          style: TextStyle(
            color: value != null ? AppColors.textPrimaryLight : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildTesSwitch() {
    return Row(
      children: <Widget>[
        Text(
          'TES (Técnico en Emergencias Sanitarias)',
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontSmall,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(width: AppSizes.spacingMedium),
        Switch(
          value: _tesSiNo,
          onChanged: (bool value) {
            setState(() => _tesSiNo = value);
          },
          activeTrackColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildProvinciaDropdown() {
    return AppDropdown<String?>(
      value: _provinciaId,
      label: 'Provincia',
      hint: 'Seleccionar provincia',
      items: _provincias
          .map(
            (ProvinciaEntity provincia) => AppDropdownItem<String?>(
              value: provincia.id,
              label: provincia.nombre,
              icon: Icons.location_city,
            ),
          )
          .toList(),
      onChanged: (String? value) {
        setState(() {
          _provinciaId = value;
          _poblacionId = null;
          _poblaciones = <PoblacionEntity>[];
        });
        if (value != null) {
          _loadPoblaciones(value);
        }
      },
    );
  }

  Widget _buildPoblacionDropdown() {
    return AppDropdown<String?>(
      value: _poblacionId,
      label: 'Población',
      hint: 'Seleccionar población',
      enabled: _provinciaId != null,
      items: _poblaciones
          .map(
            (PoblacionEntity poblacion) => AppDropdownItem<String?>(
              value: poblacion.id,
              label: poblacion.nombre,
              icon: Icons.place,
            ),
          )
          .toList(),
      onChanged: (String? value) {
        setState(() => _poblacionId = value);
      },
    );
  }

  Widget _buildPuestoDropdown() {
    return AppDropdown<String?>(
      value: _puestoId,
      label: 'Puesto de Trabajo',
      hint: 'Seleccionar puesto',
      items: _puestos
          .map(
            (PuestoEntity puesto) => AppDropdownItem<String?>(
              value: puesto.id,
              label: puesto.nombre,
              icon: Icons.work,
            ),
          )
          .toList(),
      onChanged: (String? value) {
        setState(() => _puestoId = value);
      },
    );
  }

  Widget _buildContratoDropdown() {
    return AppDropdown<String?>(
      value: _contratoId,
      label: 'Tipo de Contrato',
      hint: 'Seleccionar tipo de contrato',
      items: _contratos
          .map(
            (TipoContratoEntity contrato) => AppDropdownItem<String?>(
              value: contrato.id,
              label: contrato.nombre,
              icon: Icons.description,
            ),
          )
          .toList(),
      onChanged: (String? value) {
        setState(() => _contratoId = value);
      },
    );
  }

  Widget _buildEmpresaDropdown() {
    return AppDropdown<String?>(
      value: _empresaIdFk,
      label: 'Empresa',
      hint: 'Seleccionar empresa',
      items: _empresas
          .map(
            (EmpresaEntity empresa) => AppDropdownItem<String?>(
              value: empresa.id,
              label: empresa.nombre,
              icon: Icons.business,
            ),
          )
          .toList(),
      onChanged: (String? value) {
        setState(() => _empresaIdFk = value);
      },
    );
  }

  Widget _buildCategoriaPersonalDropdown() {
    return AppDropdown<String?>(
      value: _categoriaIdFk,
      label: 'Categoría Laboral',
      hint: 'Seleccionar categoría',
      items: _categoriasPersonal
          .map(
            (CategoriaPersonalEntity cat) => AppDropdownItem<String?>(
              value: cat.id,
              label: cat.categoria,
              icon: Icons.category,
            ),
          )
          .toList(),
      onChanged: (String? value) {
        setState(() => _categoriaIdFk = value);
      },
    );
  }

  Widget _buildCategoriaServicioDropdown() {
    return AppDropdown<CategoriaServicio>(
      value: _categoriaServicio,
      label: 'Categoría de Servicio',
      hint: 'Seleccionar tipo',
      items: CategoriaServicio.values
          .map(
            (CategoriaServicio cat) => AppDropdownItem<CategoriaServicio>(
              value: cat,
              label: cat.displayText,
              icon: cat == CategoriaServicio.urgencias
                  ? Icons.emergency
                  : Icons.calendar_today,
              iconColor: cat == CategoriaServicio.urgencias
                  ? AppColors.emergency
                  : AppColors.info,
            ),
          )
          .toList(),
      onChanged: (CategoriaServicio? value) {
        if (value != null) {
          setState(() => _categoriaServicio = value);
        }
      },
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      debugPrint('👤 PersonalFormDialog: Validación exitosa, creando entidad...');

      final String nombre = _nombreController.text.trim().toUpperCase();
      final String apellidos = _apellidosController.text.trim().toUpperCase();

      // Obtener usuario autenticado
      final User? currentUser = Supabase.instance.client.auth.currentUser;
      final String? userId = currentUser?.id;

      final PersonalEntity persona = PersonalEntity(
        id: widget.persona?.id ?? '',
        nombre: nombre,
        apellidos: apellidos,
        dni: _dniController.text.isNotEmpty ? _dniController.text.trim() : null,
        nass: _nassController.text.isNotEmpty ? _nassController.text.trim() : null,
        email: _emailController.text.isNotEmpty ? _emailController.text.trim() : null,
        telefono: _telefonoController.text.isNotEmpty ? _telefonoController.text.trim() : null,
        movil: _movilController.text.isNotEmpty ? _movilController.text.trim() : null,
        direccion: _direccionController.text.isNotEmpty ? _direccionController.text.trim() : null,
        codigoPostal: _codigoPostalController.text.isNotEmpty ? _codigoPostalController.text.trim() : null,
        usuario: _usuarioController.text.isNotEmpty ? _usuarioController.text.trim() : null,
        pwdWeb: _pwdWebController.text.isNotEmpty ? _pwdWebController.text.trim() : null,
        pwd: _pwdController.text.isNotEmpty ? _pwdController.text.trim() : null,
        tesSiNo: _tesSiNo,
        dataAnti: _dataAnti,
        fechaNacimiento: _fechaNacimiento,
        fechaInicio: _fechaInicio,
        fechaAlta: _fechaAlta,
        provinciaId: _provinciaId,
        poblacionId: _poblacionId,
        puestoTrabajoId: _puestoId,
        contratoId: _contratoId,
        empresaId: _empresaIdFk,
        categoriaId: _categoriaIdFk,
        categoriaServicio: _categoriaServicio,
        configuracionValidaciones: _configuracionValidaciones,
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
