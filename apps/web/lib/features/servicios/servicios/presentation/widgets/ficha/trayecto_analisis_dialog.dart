import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Diálogo de análisis detallado del trayecto
class TrayectoAnalisisDialog extends StatefulWidget {
  const TrayectoAnalisisDialog({
    required this.trayecto,
    required this.servicio,
    super.key,
  });

  final TrasladoEntity trayecto;
  final ServicioEntity servicio;

  @override
  State<TrayectoAnalisisDialog> createState() => TrayectoAnalisisDialogState();
}

class TrayectoAnalisisDialogState extends State<TrayectoAnalisisDialog> {
  String? _localidadNombre;

  @override
  void initState() {
    super.initState();
    _loadLocalidadNombre();
  }

  /// Carga el nombre de la localidad del paciente desde Supabase
  Future<void> _loadLocalidadNombre() async {
    final String? localidadId = widget.servicio.paciente?.localidadId;

    debugPrint('🔍 _loadLocalidadNombre - localidadId: $localidadId');
    debugPrint('🔍 _loadLocalidadNombre - paciente completo: ${widget.servicio.paciente}');

    if (localidadId == null || localidadId.isEmpty) {
      debugPrint('⚠️ localidadId es null o vacío');
      return;
    }

    try {
      debugPrint('📡 Consultando tpoblaciones con id: $localidadId');
      final Map<String, dynamic>? response = await Supabase.instance.client
          .from('tpoblaciones')
          .select('nombre')
          .eq('id', localidadId)
          .maybeSingle();

      debugPrint('📥 Respuesta de Supabase: $response');

      if (response != null && mounted) {
        final String? nombre = response['nombre'] as String?;
        debugPrint('✅ Localidad encontrada: $nombre');
        setState(() {
          _localidadNombre = nombre;
        });
      } else {
        debugPrint('⚠️ No se encontró localidad o widget no montado');
      }
    } catch (e) {
      debugPrint('❌ Error al cargar localidad: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final DateFormat dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxHeight: 800),
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSizes.spacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Análisis Detallado del Trayecto',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        'Código: ${widget.trayecto.codigo}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacing),
            const Divider(),
            const SizedBox(height: AppSizes.spacing),

            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // SECCIÓN: Información General y Recursos Asignados (lado a lado)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: _buildSection(
                            title: '📋 Información General',
                            children: <Widget>[
                              _buildInfoRow('Estado', EstadoTraslado.fromValue(widget.trayecto.estado)?.label ?? widget.trayecto.estado ?? 'Desconocido'),
                              _buildInfoRow('Tipo', widget.trayecto.tipoTraslado ?? 'Sin tipo'),
                              _buildInfoRow('Fecha', widget.trayecto.fecha != null ? dateFormat.format(widget.trayecto.fecha!) : 'Sin fecha'),
                              _buildInfoRow('Hora Programada', widget.trayecto.horaProgramada != null ? DateFormat('HH:mm').format(widget.trayecto.horaProgramada!) : 'Sin hora'),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.spacing),
                        Expanded(
                          child: _buildSection(
                            title: '👥 Recursos Asignados',
                            children: <Widget>[
                              _buildInfoRow('Conductor', widget.trayecto.conductorNombre ?? widget.trayecto.idConductor ?? 'Sin asignar'),
                              _buildInfoRow('Vehículo', widget.trayecto.vehiculoMatricula ?? widget.trayecto.idVehiculo ?? 'Sin asignar'),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // SECCIÓN: Origen y Destino
                    _buildSection(
                      title: '📍 Origen y Destino',
                      children: <Widget>[
                        _buildInfoRow(
                          'Origen',
                          _formatUbicacion(
                            tipo: widget.trayecto.tipoOrigen,
                            ubicacion: widget.trayecto.origen,
                            domicilioPaciente: widget.servicio.paciente?.domicilioDireccion,
                            localidadNombre: _localidadNombre,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingSmall),
                        _buildInfoRow(
                          'Destino',
                          _formatUbicacion(
                            tipo: widget.trayecto.tipoDestino,
                            ubicacion: widget.trayecto.destino,
                            domicilioPaciente: widget.servicio.paciente?.domicilioDireccion,
                            localidadNombre: _localidadNombre,
                          ),
                        ),
                      ],
                    ),

                    // SECCIÓN: Kilometraje y Duración
                    if (widget.trayecto.kilometrosRecorridos != null || widget.trayecto.tiempoViajeMinutos != null || widget.trayecto.tiempoEsperaOrigenMinutos != null)
                      _buildSection(
                        title: '🛣️ Métricas del Trayecto',
                        children: <Widget>[
                          if (widget.trayecto.kilometrosRecorridos != null)
                            _buildInfoRow('KM Recorridos', widget.trayecto.kilometrosRecorridos!.toStringAsFixed(2)),
                          if (widget.trayecto.tiempoViajeMinutos != null)
                            _buildInfoRow('Tiempo de Viaje', '${widget.trayecto.tiempoViajeMinutos} min'),
                          if (widget.trayecto.tiempoEsperaOrigenMinutos != null)
                            _buildInfoRow('Tiempo de Espera', '${widget.trayecto.tiempoEsperaOrigenMinutos} min'),
                        ],
                      ),

                    // SECCIÓN: Cronología del Trayecto (COMPLETA - siempre visible)
                    _buildSection(
                      title: '📅 Cronología del Trayecto',
                      children: <Widget>[
                        // Estados activos del ciclo de vida normal
                        _buildInfoRow(
                          'Enviado',
                          widget.trayecto.fechaEnviado != null
                              ? dateTimeFormat.format(widget.trayecto.fechaEnviado!)
                              : 'Pendiente',
                        ),
                        _buildInfoRow(
                          'Recibido por Conductor',
                          widget.trayecto.fechaRecibidoConductor != null
                              ? dateTimeFormat.format(widget.trayecto.fechaRecibidoConductor!)
                              : 'Pendiente',
                        ),
                        _buildInfoRow(
                          'En Origen',
                          widget.trayecto.fechaEnOrigen != null
                              ? dateTimeFormat.format(widget.trayecto.fechaEnOrigen!)
                              : 'Pendiente',
                        ),
                        _buildInfoRow(
                          'Saliendo de Origen',
                          widget.trayecto.fechaSaliendoOrigen != null
                              ? dateTimeFormat.format(widget.trayecto.fechaSaliendoOrigen!)
                              : 'Pendiente',
                        ),
                        _buildInfoRow(
                          'En Destino',
                          widget.trayecto.fechaEnDestino != null
                              ? dateTimeFormat.format(widget.trayecto.fechaEnDestino!)
                              : 'Pendiente',
                        ),
                        _buildInfoRow(
                          'Finalizado',
                          widget.trayecto.fechaFinalizado != null
                              ? dateTimeFormat.format(widget.trayecto.fechaFinalizado!)
                              : 'Pendiente',
                        ),

                        // Separador visual para estados anormales
                        const Divider(height: 20, color: AppColors.gray300),
                        const SizedBox(height: 8),

                        // Estados de finalización anormal
                        _buildInfoRow(
                          'Cancelado',
                          widget.trayecto.fechaCancelacion != null
                              ? dateTimeFormat.format(widget.trayecto.fechaCancelacion!)
                              : '-',
                        ),
                        _buildInfoRow(
                          'Suspendido',
                          widget.trayecto.fechaSuspendido != null
                              ? dateTimeFormat.format(widget.trayecto.fechaSuspendido!)
                              : '-',
                        ),
                        _buildInfoRow(
                          'No Realizado',
                          widget.trayecto.fechaNoRealizado != null
                              ? dateTimeFormat.format(widget.trayecto.fechaNoRealizado!)
                              : '-',
                        ),
                      ],
                    ),

                    // SECCIÓN: Observaciones
                    if (widget.trayecto.observaciones != null || widget.trayecto.observacionesMedicas != null)
                      _buildSection(
                        title: '📝 Observaciones',
                        children: <Widget>[
                          if (widget.trayecto.observaciones != null)
                            _buildInfoRow('Generales', widget.trayecto.observaciones!),
                          if (widget.trayecto.observacionesMedicas != null)
                            _buildInfoRow('Médicas', widget.trayecto.observacionesMedicas!),
                        ],
                      ),

                    // SECCIÓN: Motivos de Cancelación
                    if (widget.trayecto.motivoCancelacion != null || widget.trayecto.observacionesCancelacion != null)
                      _buildSection(
                        title: '⚠️ Motivos de Cancelación',
                        children: <Widget>[
                          if (widget.trayecto.motivoCancelacion != null)
                            _buildInfoRow('Motivo', widget.trayecto.motivoCancelacion!),
                          if (widget.trayecto.observacionesCancelacion != null)
                            _buildInfoRow('Observaciones', widget.trayecto.observacionesCancelacion!),
                        ],
                      ),

                    // SECCIÓN: Auditoría
                    _buildSection(
                      title: '🔍 Auditoría',
                      children: <Widget>[
                        if (widget.trayecto.usuarioAsignacion != null)
                          _buildInfoRow('Usuario Asignación', widget.trayecto.usuarioAsignacion!),
                        if (widget.trayecto.fechaAsignacion != null)
                          _buildInfoRow('Fecha Asignación', dateTimeFormat.format(widget.trayecto.fechaAsignacion!)),
                        if (widget.trayecto.usuarioEnvio != null)
                          _buildInfoRow('Usuario Envío', widget.trayecto.usuarioEnvio!),
                        if (widget.trayecto.fechaEnviado != null)
                          _buildInfoRow('Fecha Envío', dateTimeFormat.format(widget.trayecto.fechaEnviado!.toLocal())),
                        if (widget.trayecto.usuarioCancelacion != null)
                          _buildInfoRow('Usuario Cancelación', widget.trayecto.usuarioCancelacion!),
                        if (widget.trayecto.createdAt != null)
                          _buildInfoRow('Creado', dateTimeFormat.format(widget.trayecto.createdAt!.toLocal())),
                        if (widget.trayecto.updatedAt != null)
                          _buildInfoRow('Actualizado', dateTimeFormat.format(widget.trayecto.updatedAt!.toLocal())),
                        if (widget.trayecto.createdBy != null)
                          _buildInfoRow('Creado Por', widget.trayecto.createdBy!),
                        if (widget.trayecto.updatedBy != null)
                          _buildInfoRow('Actualizado Por', widget.trayecto.updatedBy!),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Footer con botón cerrar
            const SizedBox(height: AppSizes.spacing),
            const Divider(),
            const SizedBox(height: AppSizes.spacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                AppButton(
                  onPressed: () => Navigator.of(context).pop(),
                  label: 'Cerrar',
                  variant: AppButtonVariant.text,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacing),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacing),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Formatea una ubicación (origen/destino) mostrando la dirección completa
  /// Si es domicilio del paciente y hay dirección disponible, la incluye con la población
  String _formatUbicacion({
    required String? tipo,
    required String? ubicacion,
    required String? domicilioPaciente,
    String? localidadNombre,
  }) {
    debugPrint('🗺️ _formatUbicacion llamado:');
    debugPrint('   - tipo: $tipo');
    debugPrint('   - ubicacion: $ubicacion');
    debugPrint('   - domicilioPaciente: $domicilioPaciente');
    debugPrint('   - localidadNombre: $localidadNombre');

    // Si es domicilio del paciente, intentar agregar localidad
    if (tipo == 'domicilio_paciente') {
      // Obtener la dirección (priorizar ubicacion explícita, luego domicilioPaciente)
      final String? direccion = (ubicacion != null && ubicacion.isNotEmpty)
          ? ubicacion
          : domicilioPaciente;

      if (direccion != null && direccion.isNotEmpty) {
        // Si hay localidad disponible, agregarla entre paréntesis
        if (localidadNombre != null && localidadNombre.isNotEmpty) {
          final String resultado = '$direccion ($localidadNombre)';
          debugPrint('   ✅ Retornando con localidad: $resultado');
          return resultado;
        }
        debugPrint('   ⚠️ Retornando sin localidad (localidad vacía/null): $direccion');
        return direccion;
      }
      // Si no hay dirección, mostrar solo "Domicilio del Paciente"
      debugPrint('   ⚠️ Retornando texto genérico: Domicilio del Paciente');
      return 'Domicilio del Paciente';
    }

    // Para otros tipos, usar ubicación tal cual
    if (ubicacion != null && ubicacion.isNotEmpty) {
      debugPrint('   ✅ Retornando ubicacion: $ubicacion');
      return ubicacion;
    }

    // Para otros tipos sin ubicación
    debugPrint('   ⚠️ Retornando "-" (sin datos)');
    return '-';
  }
}
