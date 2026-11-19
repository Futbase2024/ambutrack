import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/evaluacion_desempeno_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/evaluacion_desempeno_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/evaluacion_desempeno_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/personal_form_options.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/evaluaciones/evaluacion_gestion_columns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

/// Opciones de puntuación 1-5
const List<GestionOption<int>> _opcionesPuntuacion = <GestionOption<int>>[
  GestionOption<int>(1, '1 · Deficiente', color: AppColors.error),
  GestionOption<int>(2, '2 · Mejorable', color: AppColors.error),
  GestionOption<int>(3, '3 · Adecuado', color: AppColors.warning),
  GestionOption<int>(4, '4 · Bueno', color: AppColors.success),
  GestionOption<int>(5, '5 · Excelente', color: AppColors.success),
];

/// Formulario de alta/edición de una evaluación de desempeño.
/// El evaluador es siempre el usuario autenticado (se conserva el original al editar).
class EvaluacionFormDialog extends StatefulWidget {
  const EvaluacionFormDialog({super.key, this.item});

  final EvaluacionDesempenoEntity? item;

  @override
  State<EvaluacionFormDialog> createState() => _EvaluacionFormDialogState();
}

class _EvaluacionFormDialogState extends State<EvaluacionFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _periodo = TextEditingController(
    text: widget.item?.periodo ?? '${DateTime.now().year}',
  );
  late final TextEditingController _comentarios = TextEditingController(text: widget.item?.comentarios);

  late String? _personalId = widget.item?.personalId;
  late DateTime? _fecha = widget.item?.fecha ?? DateTime.now();
  late final Map<CriterioEvaluacion, int> _puntos = <CriterioEvaluacion, int>{
    for (final CriterioEvaluacion c in CriterioEvaluacion.values) c: widget.item?.puntuaciones[c] ?? 3,
  };

  List<PersonalEntity> _personal = <PersonalEntity>[];
  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _loadPersonal();
  }

  @override
  void dispose() {
    _periodo.dispose();
    _comentarios.dispose();
    super.dispose();
  }

  Future<void> _loadPersonal() async {
    try {
      final List<PersonalEntity> personal = await getIt<PersonalRepository>().getAll();
      if (mounted) {
        setState(() => _personal = personal);
      }
    } catch (e) {
      debugPrint('❌ EvaluacionFormDialog: error al cargar personal: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// (id, NOMBRE) del evaluador: el original al editar, el usuario actual al crear
  (String?, String?) _evaluador() {
    final EvaluacionDesempenoEntity? item = widget.item;
    if (item != null) {
      return (item.evaluadorId, item.evaluadorNombre);
    }
    final AuthState auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return (null, null);
    }
    final String nombre = (auth.user.displayName ?? auth.user.email).trim().toUpperCase();
    return (auth.user.uid, nombre.isEmpty ? null : nombre);
  }

  void _onBlocState(BuildContext context, EvaluacionDesempenoState state) {
    if (!_isSaving) {
      return;
    }
    if (state is EvaluacionDesempenoLoaded) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Evaluación',
        onClose: () => setState(() => _isSaving = false),
      );
    } else if (state is EvaluacionDesempenoError) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Evaluación',
        errorMessage: state.message,
        onClose: () => setState(() => _isSaving = false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double media = EvaluacionDesempenoEntity.calcularMedia(_puntos.values.toList());
    return BlocListener<EvaluacionDesempenoBloc, EvaluacionDesempenoState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: _isEditing ? 'Editar evaluación' : 'Nueva evaluación',
        subtitle: _isEditing ? widget.item!.personalNombre : null,
        icon: Icons.assessment_outlined,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _onSave,
        children: <Widget>[
          const GestionFormSection(title: 'Evaluación', first: true),
          GestionFormRow(
            label: 'Personal',
            required: true,
            child: GestionSearchField<String>(
              value: _personalId,
              required: true,
              loading: _isLoading,
              hint: 'Buscar por nombre o DNI',
              options: PersonalFormOptions.personal(_personal, conDni: true),
              onChanged: (String? id) => setState(() => _personalId = id),
            ),
          ),
          GestionFormColumns(
            children: <Widget>[
              GestionFormRow(
                label: 'Fecha',
                required: true,
                child: GestionDateField(
                  value: _fecha,
                  required: true,
                  onChanged: (DateTime? v) => setState(() => _fecha = v),
                ),
              ),
              GestionFormRow(
                label: 'Periodo',
                child: GestionTextField(controller: _periodo, hint: 'P. ej. 2026, 2026-S1'),
              ),
            ],
          ),
          GestionFormRow(
            label: 'Evaluador',
            child: GestionFormReadOnly(value: _evaluador().$2 ?? '—'),
          ),
          const GestionFormSection(title: 'Puntuaciones (1-5)'),
          _PuntuacionesFields(
            puntos: _puntos,
            onChanged: (CriterioEvaluacion c, int v) => setState(() => _puntos[c] = v),
          ),
          GestionFormRow(
            label: 'Media',
            child: GestionFormReadOnly(value: evaluacionMediaTexto(media)),
          ),
          GestionFormRow(
            label: 'Comentarios',
            multiline: true,
            child: GestionTextField(controller: _comentarios, maxLines: 4),
          ),
        ],
      ),
    );
  }

  void _onSave() {
    if (_isLoading || !_formKey.currentState!.validate() || _personalId == null || _fecha == null) {
      return;
    }
    setState(() => _isSaving = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => AppLoadingOverlay(
        message: _isEditing ? 'Actualizando evaluación...' : 'Creando evaluación...',
        color: _isEditing ? AppColors.secondary : AppColors.primary,
        icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
      ),
    );
    final EvaluacionDesempenoEntity entity = _buildEntity();
    context
        .read<EvaluacionDesempenoBloc>()
        .add(_isEditing ? EvaluacionDesempenoUpdateRequested(entity) : EvaluacionDesempenoCreateRequested(entity));
  }

  EvaluacionDesempenoEntity _buildEntity() {
    final (String? evaluadorId, String? evaluadorNombre) = _evaluador();
    final String periodo = _periodo.text.trim();
    final String comentarios = _comentarios.text.trim();
    return EvaluacionDesempenoEntity(
      id: widget.item?.id ?? const Uuid().v4(),
      empresaId: widget.item?.empresaId ?? '',
      personalId: _personalId!,
      fecha: _fecha!,
      periodo: periodo.isEmpty ? null : periodo,
      evaluadorId: evaluadorId,
      evaluadorNombre: evaluadorNombre,
      puntualidad: _puntos[CriterioEvaluacion.puntualidad]!,
      tratoPaciente: _puntos[CriterioEvaluacion.tratoPaciente]!,
      trabajoEquipo: _puntos[CriterioEvaluacion.trabajoEquipo]!,
      cumplimientoProtocolos: _puntos[CriterioEvaluacion.cumplimientoProtocolos]!,
      comentarios: comentarios.isEmpty ? null : comentarios,
    );
  }
}

/// Selectores de puntuación de los cuatro criterios (en dos columnas)
class _PuntuacionesFields extends StatelessWidget {
  const _PuntuacionesFields({required this.puntos, required this.onChanged});

  final Map<CriterioEvaluacion, int> puntos;
  final void Function(CriterioEvaluacion criterio, int valor) onChanged;

  @override
  Widget build(BuildContext context) {
    const List<CriterioEvaluacion> c = CriterioEvaluacion.values;
    return Column(
      children: <Widget>[
        for (int i = 0; i < c.length; i += 2)
          GestionFormColumns(
            children: <Widget>[
              for (final CriterioEvaluacion criterio in c.sublist(i, i + 2))
                _PuntuacionField(criterio: criterio, valor: puntos[criterio], onChanged: onChanged),
            ],
          ),
      ],
    );
  }
}

/// Selector de puntuación (1-5) de un criterio
class _PuntuacionField extends StatelessWidget {
  const _PuntuacionField({required this.criterio, required this.valor, required this.onChanged});

  final CriterioEvaluacion criterio;
  final int? valor;
  final void Function(CriterioEvaluacion criterio, int valor) onChanged;

  @override
  Widget build(BuildContext context) {
    return GestionFormRow(
      label: criterio.label,
      required: true,
      child: GestionDropdownField<int>(
        value: valor,
        options: _opcionesPuntuacion,
        required: true,
        onChanged: (int? v) {
          if (v != null) {
            onChanged(criterio, v);
          }
        },
      ),
    );
  }
}
