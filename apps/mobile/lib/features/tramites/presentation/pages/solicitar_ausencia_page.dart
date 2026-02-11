import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/ausencias_bloc.dart';
import '../bloc/ausencias_event.dart';
import '../bloc/ausencias_state.dart';

/// Página para solicitar ausencias (baja médica, permisos, etc.).
class SolicitarAusenciaPage extends StatefulWidget {
  const SolicitarAusenciaPage({
    this.tipoPreseleccionado,
    super.key,
  });

  final String? tipoPreseleccionado;

  @override
  State<SolicitarAusenciaPage> createState() => _SolicitarAusenciaPageState();
}

class _SolicitarAusenciaPageState extends State<SolicitarAusenciaPage> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();
  final _observacionesController = TextEditingController();

  TipoAusenciaEntity? _tipoSeleccionado;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  int _diasSolicitados = 0;

  @override
  void initState() {
    super.initState();
    // Cargar tipos de ausencias
    context.read<AusenciasBloc>().add(const TiposAusenciaLoadRequested());
  }

  @override
  void dispose() {
    _motivoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _calcularDias() {
    if (_fechaInicio != null && _fechaFin != null) {
      final diferencia = _fechaFin!.difference(_fechaInicio!).inDays + 1;
      setState(() {
        _diasSolicitados = diferencia;
      });
    }
  }

  Future<void> _seleccionarFechaInicio() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      setState(() {
        _fechaInicio = fecha;
        // Establecer automáticamente la fecha de fin al mismo día
        if (_fechaFin == null || _fechaFin!.isBefore(_fechaInicio!)) {
          _fechaFin = fecha;
        }
      });
      _calcularDias();
    }
  }

  Future<void> _seleccionarFechaFin() async {
    if (_fechaInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero selecciona la fecha de inicio'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? _fechaInicio!,
      firstDate: _fechaInicio!,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      setState(() {
        _fechaFin = fecha;
      });
      _calcularDias();
    }
  }

  Future<void> _solicitarAusencia() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_tipoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un tipo de ausencia'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_fechaInicio == null || _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona las fechas de inicio y fin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_motivoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El motivo es requerido'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || authState.personal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo obtener información del usuario'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final ausencia = AusenciaEntity(
      id: const Uuid().v4(),
      idPersonal: authState.personal!.id,
      idTipoAusencia: _tipoSeleccionado!.id,
      fechaInicio: _fechaInicio!,
      fechaFin: _fechaFin!,
      motivo: _motivoController.text.trim(),
      estado: EstadoAusencia.pendiente,
      observaciones: _observacionesController.text.trim().isEmpty
          ? null
          : _observacionesController.text.trim(),
      activo: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<AusenciasBloc>().add(
          AusenciaCreateRequested(ausencia),
        );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.gray50,
        appBar: AppBar(
          title: const Text('Solicitar Ausencia'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: BlocListener<AusenciasBloc, AusenciasState>(
          listener: (context, state) {
            if (state is AusenciaCreated) {
              // Mostrar diálogo de éxito
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            size: 48,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Solicitud Enviada',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tu solicitud de ausencia ha sido enviada correctamente y está pendiente de aprobación.',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.gray700,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Entendido',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is AusenciasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: BlocBuilder<AusenciasBloc, AusenciasState>(
            builder: (context, state) {
              final isLoading = state is AusenciasLoading;

              List<TipoAusenciaEntity> tipos = [];
              if (state is AusenciasLoaded) {
                tipos = state.tiposAusencia;
              } else if (state is TiposAusenciaLoaded) {
                tipos = state.tipos;
              }

              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Card: Tipo de Ausencia
                    Card(
                      elevation: 1,
                      shadowColor: AppColors.primary.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.list_alt_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _buildFieldLabel('Tipo de Ausencia', required: true),
                              ],
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<TipoAusenciaEntity>(
                              decoration: InputDecoration(
                                hintText: 'Seleccionar tipo',
                                hintStyle: const TextStyle(
                                  color: AppColors.gray400,
                                  fontSize: 15,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.gray300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.gray300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.gray50,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              items: tipos
                                  .map(
                                    (tipo) => DropdownMenuItem(
                                      value: tipo,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: _getColorFromHex(tipo.color),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _getColorFromHex(tipo.color)
                                                      .withValues(alpha: 0.3),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Flexible(
                                            child: Text(
                                              tipo.nombre,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: isLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _tipoSeleccionado = value;
                                      });
                                    },
                            ),
                            if (_tipoSeleccionado != null &&
                                _tipoSeleccionado!.descripcion != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.info.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.info_outline_rounded,
                                      size: 18,
                                      color: AppColors.info,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _tipoSeleccionado!.descripcion!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.gray700,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Card: Fechas
                    Card(
                      elevation: 1,
                      shadowColor: AppColors.primary.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_month_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Periodo de Ausencia',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gray800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Fecha de inicio
                            _buildFieldLabel('Fecha de Inicio', required: true),
                            const SizedBox(height: 8),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: isLoading ? null : _seleccionarFechaInicio,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _fechaInicio != null
                                          ? AppColors.primary.withValues(alpha: 0.3)
                                          : AppColors.gray300,
                                      width: _fechaInicio != null ? 1.5 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        color: AppColors.primary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _fechaInicio == null
                                              ? 'Seleccionar fecha'
                                              : dateFormat.format(_fechaInicio!),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: _fechaInicio != null
                                                ? FontWeight.w500
                                                : FontWeight.w400,
                                            color: _fechaInicio == null
                                                ? AppColors.gray400
                                                : AppColors.gray900,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Fecha de fin
                            _buildFieldLabel('Fecha de Fin', required: true),
                            const SizedBox(height: 8),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: isLoading ? null : _seleccionarFechaFin,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _fechaFin != null
                                          ? AppColors.primary.withValues(alpha: 0.3)
                                          : AppColors.gray300,
                                      width: _fechaFin != null ? 1.5 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.event_available_rounded,
                                        color: AppColors.primary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _fechaFin == null
                                              ? 'Seleccionar fecha'
                                              : dateFormat.format(_fechaFin!),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: _fechaFin != null
                                                ? FontWeight.w500
                                                : FontWeight.w400,
                                            color: _fechaFin == null
                                                ? AppColors.gray400
                                                : AppColors.gray900,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Días solicitados
                            if (_diasSolicitados > 0) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Total: $_diasSolicitados ${_diasSolicitados == 1 ? 'día' : 'días'}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Card: Motivo y Observaciones
                    Card(
                      elevation: 1,
                      shadowColor: AppColors.primary.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.edit_note_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Detalles',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gray800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Motivo
                            _buildFieldLabel('Motivo', required: true),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _motivoController,
                              maxLines: 3,
                              enabled: !isLoading,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Describe el motivo de la ausencia...',
                                hintStyle: const TextStyle(
                                  color: AppColors.gray400,
                                  fontSize: 13,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.gray300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.gray300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.all(12),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El motivo es requerido';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // Observaciones
                            _buildFieldLabel('Observaciones'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _observacionesController,
                              maxLines: 3,
                              enabled: !isLoading,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Información adicional (opcional)...',
                                hintStyle: const TextStyle(
                                  color: AppColors.gray400,
                                  fontSize: 13,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.gray300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.gray300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Documento adjunto (futura implementación)
                    if (_tipoSeleccionado != null &&
                        _tipoSeleccionado!.requiereDocumento) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.warning,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Este tipo de ausencia requiere documento adjunto.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.gray700,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Botón de enviar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _solicitarAusencia,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.gray300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Solicitar Ausencia',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool required = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(
        int.parse(hexColor.replaceFirst('#', '0xFF')),
      );
    } catch (e) {
      return AppColors.gray500;
    }
  }
}
