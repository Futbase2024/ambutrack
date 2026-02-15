import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/locator.dart';
import '../../../../core/services/pdf_ruta_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/widgets/dropdowns/app_searchable_dropdown.dart';
import '../../../../core/widgets/loading/app_loading_indicator.dart';
import '../bloc/rutas_bloc.dart';
import '../bloc/rutas_event.dart';
import '../bloc/rutas_state.dart';
import '../models/traslado_con_ruta_info.dart';
import '../widgets/rutas/lista_traslados_ruta_widget.dart';
import '../widgets/rutas/mapa_ruta_widget.dart';
import '../widgets/rutas/resumen_ruta_widget.dart';

/// Página para visualizar y gestionar rutas de técnicos
class RutasTecnicosPage extends StatelessWidget {
  const RutasTecnicosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RutasBloc>(
      create: (BuildContext context) => getIt<RutasBloc>(),
      child: const _RutasTecnicosView(),
    );
  }
}

class _RutasTecnicosView extends StatefulWidget {
  const _RutasTecnicosView();

  @override
  State<_RutasTecnicosView> createState() => _RutasTecnicosViewState();
}

class _RutasTecnicosViewState extends State<_RutasTecnicosView> {
  String? _tecnicoSeleccionadoId;
  DateTime _fechaSeleccionada = DateTime.now();
  String? _turnoSeleccionado;
  List<TPersonalEntity>? _tecnicos;
  bool _isLoadingTecnicos = true;

  final List<Map<String, String>> _turnosDisponibles = <Map<String, String>>[
    <String, String>{'value': '', 'label': 'Todo el día'},
    <String, String>{'value': 'mañana', 'label': 'Mañana (6:00 - 14:00)'},
    <String, String>{'value': 'tarde', 'label': 'Tarde (14:00 - 22:00)'},
    <String, String>{'value': 'noche', 'label': 'Noche (22:00 - 6:00)'},
  ];

  @override
  void initState() {
    super.initState();
    _cargarTecnicos();
  }

  Future<void> _cargarTecnicos() async {
    try {
      final TPersonalDataSource dataSource = getIt<TPersonalDataSource>();
      final List<TPersonalEntity> todosPersonal = await dataSource.getActivos();

      // Filtrar solo técnicos que sean conductores (tienen traslados asignados potencialmente)
      // Por ahora cargamos todo el personal activo
      setState(() {
        _tecnicos = todosPersonal;
        _isLoadingTecnicos = false;
      });
    } catch (e) {
      debugPrint('❌ Error cargando técnicos: $e');
      setState(() {
        _tecnicos = <TPersonalEntity>[];
        _isLoadingTecnicos = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Rutas de Técnicos'),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.gray300,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Panel de filtros
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Seleccione técnico y fecha',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                  ),
                  const SizedBox(height: AppSizes.spacingMedium),
                  Row(
                    children: <Widget>[
                      // Selector de técnico
                      Expanded(
                        flex: 2,
                        child: _buildSelectorTecnico(),
                      ),
                      const SizedBox(width: AppSizes.spacingMedium),

                      // Selector de fecha
                      Expanded(
                        child: _buildSelectorFecha(context),
                      ),
                      const SizedBox(width: AppSizes.spacingMedium),

                      // Selector de turno
                      Expanded(
                        child: _buildSelectorTurno(),
                      ),
                      const SizedBox(width: AppSizes.spacingMedium),

                      // Botón de calcular ruta
                      SizedBox(
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: _tecnicoSeleccionadoId != null ? _calcularRuta : null,
                          icon: const Icon(Icons.route),
                          label: const Text('Calcular Ruta'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Contenido principal
            Expanded(
              child: BlocBuilder<RutasBloc, RutasState>(
                builder: (BuildContext context, RutasState state) {
                  return state.when(
                    initial: _buildEstadoInicial,
                    loading: () => const Center(child: AppLoadingIndicator()),
                    loaded: (String tecnicoId, String tecnicoNombre, String? vehiculoMatricula, DateTime fecha, String? turno, List<TrasladoConRutaInfo> trasladosConRuta, RutaResumen resumen, bool isOptimizando, RutaResumen? resumenAnterior) =>
                        _buildRutaCargada(
                      context,
                      tecnicoNombre: tecnicoNombre,
                      vehiculoMatricula: vehiculoMatricula,
                      trasladosConRuta: trasladosConRuta,
                      resumen: resumen,
                      resumenAnterior: resumenAnterior,
                    ),
                    empty: (String? mensaje, String? tecnicoNombre, DateTime? fecha) =>
                        _buildEstadoVacio(mensaje ?? 'No hay traslados para mostrar'),
                    error: (String message, String? tecnicoId, DateTime? fecha) =>
                        _buildEstadoError(message),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorTecnico() {
    if (_isLoadingTecnicos) {
      return const SizedBox(
        height: 48,
        child: Center(child: AppLoadingIndicator()),
      );
    }

    if (_tecnicos == null || _tecnicos!.isEmpty) {
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray400),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: const Center(
          child: Text(
            'No hay técnicos disponibles',
            style: TextStyle(color: AppColors.gray600),
          ),
        ),
      );
    }

    // Si hay más de 10 técnicos, usar dropdown con búsqueda
    if (_tecnicos!.length > 10) {
      return AppSearchableDropdown<String>(
        value: _tecnicoSeleccionadoId,
        items: _tecnicos!
            .map((TPersonalEntity tecnico) => AppSearchableDropdownItem<String>(
                  value: tecnico.id,
                  label: tecnico.nombreCompleto,
                  icon: Icons.person,
                  iconColor: AppColors.primary,
                ))
            .toList(),
        onChanged: (String? value) {
          setState(() {
            _tecnicoSeleccionadoId = value;
          });
        },
        label: 'Técnico *',
        hint: 'Seleccione un técnico',
        searchHint: 'Buscar técnico por nombre...',
        prefixIcon: Icons.badge,
      );
    }

    // Si hay 10 o menos técnicos, usar dropdown normal
    return DropdownButtonFormField<String>(
      initialValue: _tecnicoSeleccionadoId,
      decoration: InputDecoration(
        labelText: 'Técnico *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
      ),
      items: _tecnicos!
          .map((TPersonalEntity tecnico) => DropdownMenuItem<String>(
                value: tecnico.id,
                child: Text(tecnico.nombreCompleto),
              ))
          .toList(),
      onChanged: (String? value) {
        setState(() {
          _tecnicoSeleccionadoId = value;
        });
      },
      hint: const Text('Seleccione un técnico'),
    );
  }

  Widget _buildSelectorFecha(BuildContext context) {
    return InkWell(
      onTap: () => _seleccionarFecha(context),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray400),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.calendar_today,
              size: 20,
              color: AppColors.gray700,
            ),
            const SizedBox(width: AppSizes.spacingSmall),
            Expanded(
              child: Text(
                _formatFecha(_fechaSeleccionada),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray900,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorTurno() {
    return DropdownButtonFormField<String>(
      initialValue: _turnoSeleccionado,
      decoration: InputDecoration(
        labelText: 'Turno',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
      ),
      items: _turnosDisponibles
          .map((Map<String, String> turno) => DropdownMenuItem<String>(
                value: turno['value']!.isEmpty ? null : turno['value'],
                child: Text(turno['label']!),
              ))
          .toList(),
      onChanged: (String? value) {
        setState(() {
          _turnoSeleccionado = value;
        });
      },
    );
  }

  Widget _buildEstadoInicial() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.route,
            size: 80,
            color: AppColors.gray400,
          ),
          const SizedBox(height: AppSizes.spacingLarge),
          Text(
            'Seleccione un técnico y fecha',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.gray600,
                ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            'Calcule la ruta para visualizar los traslados asignados',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRutaCargada(
    BuildContext context, {
    required String tecnicoNombre,
    required String? vehiculoMatricula,
    required List<TrasladoConRutaInfo> trasladosConRuta,
    required RutaResumen resumen,
    RutaResumen? resumenAnterior,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Panel izquierdo: Resumen y lista
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Información del técnico
                _buildInfoTecnico(tecnicoNombre, vehiculoMatricula),
                const SizedBox(height: AppSizes.spacingMedium),

                // Resumen
                ResumenRutaWidget(resumen: resumen),
                const SizedBox(height: AppSizes.spacingMedium),

                // Comparativa de optimización (si existe)
                if (resumenAnterior != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacingMedium),
                    child: _buildComparativaOptimizacion(resumen, resumenAnterior),
                  ),

                // Botones de acción
                _buildBotonesAccion(context),
                const SizedBox(height: AppSizes.spacingLarge),

                // Título de lista
                Text(
                  'Traslados en orden (${trasladosConRuta.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                ),
                const SizedBox(height: AppSizes.spacingMedium),

                // Lista de traslados
                Expanded(
                  child: ListaTrasladosRutaWidget(traslados: trasladosConRuta),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spacingLarge),

          // Panel derecho: Mapa interactivo
          Expanded(
            flex: 3,
            child: MapaRutaWidget(traslados: trasladosConRuta),
          ),
        ],
      ),
    );
  }

  Widget _buildComparativaOptimizacion(RutaResumen actual, RutaResumen anterior) {
    final double mejoraDistancia = anterior.distanciaTotalKm - actual.distanciaTotalKm;
    final int mejoraTiempo = anterior.tiempoTotalMinutos - actual.tiempoTotalMinutos;
    final int retrasosSolucionados = anterior.trasladosConRetraso.length - actual.trasladosConRetraso.length;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: BorderSide(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      color: AppColors.success.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Ruta Optimizada',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray900,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mejoras después de optimizar',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingMedium),

            // Métricas de mejora
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildMetricaMejora(
                    context,
                    icon: Icons.straighten,
                    label: 'Distancia',
                    valor: '${mejoraDistancia >= 0 ? '-' : '+'}${mejoraDistancia.abs().toStringAsFixed(1)} km',
                    mejora: mejoraDistancia >= 0,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingMedium),
                Expanded(
                  child: _buildMetricaMejora(
                    context,
                    icon: Icons.access_time,
                    label: 'Tiempo',
                    valor: '${mejoraTiempo >= 0 ? '-' : '+'}${mejoraTiempo.abs()} min',
                    mejora: mejoraTiempo >= 0,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingMedium),
                Expanded(
                  child: _buildMetricaMejora(
                    context,
                    icon: Icons.check_circle,
                    label: 'Retrasos',
                    valor: retrasosSolucionados > 0
                        ? '-$retrasosSolucionados'
                        : (retrasosSolucionados == 0 ? '=' : '+${retrasosSolucionados.abs()}'),
                    mejora: retrasosSolucionados >= 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricaMejora(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String valor,
    required bool mejora,
  }) {
    final Color color = mejora ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.gray700,
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonesAccion(BuildContext context) {
    return BlocBuilder<RutasBloc, RutasState>(
      builder: (BuildContext context, RutasState state) {
        return state.maybeWhen(
          loaded: (String tecnicoId, String tecnicoNombre, String? vehiculoMatricula, DateTime fecha, String? turno, List<TrasladoConRutaInfo> traslados, RutaResumen resumen, bool isOptimizando, RutaResumen? resumenAnterior) {
            return Wrap(
              spacing: AppSizes.spacingMedium,
              runSpacing: AppSizes.spacingSmall,
              children: <Widget>[
                // Botón Optimizar Ruta
                FilledButton.icon(
                  onPressed: isOptimizando
                      ? null
                      : () {
                          context.read<RutasBloc>().add(
                                const RutasEvent.optimizarRutaRequested(),
                              );
                        },
                  icon: isOptimizando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.route, size: 18),
                  label: Text(isOptimizando ? 'Optimizando...' : 'Optimizar Ruta'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMedium,
                      vertical: AppSizes.paddingSmall,
                    ),
                  ),
                ),

                // Botón Exportar PDF
                OutlinedButton.icon(
                  onPressed: isOptimizando
                      ? null
                      : () => _exportarPdf(
                            context,
                            tecnicoNombre: tecnicoNombre,
                            vehiculoMatricula: vehiculoMatricula,
                            fecha: fecha,
                            traslados: traslados,
                            resumen: resumen,
                          ),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('Exportar PDF'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMedium,
                      vertical: AppSizes.paddingSmall,
                    ),
                  ),
                ),

                // Botón Refrescar
                OutlinedButton.icon(
                  onPressed: isOptimizando
                      ? null
                      : () {
                          context.read<RutasBloc>().add(
                                const RutasEvent.refreshRequested(),
                              );
                        },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refrescar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMedium,
                      vertical: AppSizes.paddingSmall,
                    ),
                  ),
                ),
              ],
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildInfoTecnico(String nombre, String? vehiculoMatricula) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSizes.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    nombre,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                  ),
                  if (vehiculoMatricula != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.local_shipping,
                          size: 16,
                          color: AppColors.gray700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Vehículo: $vehiculoMatricula',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.gray700,
                              ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildEstadoVacio(String mensaje) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.info_outline,
            size: 80,
            color: AppColors.warning,
          ),
          const SizedBox(height: AppSizes.spacingLarge),
          Text(
            mensaje,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.gray700,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoError(String mensaje) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSizes.spacingLarge),
          Text(
            'Error',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            mensaje,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray700,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _exportarPdf(
    BuildContext context, {
    required String tecnicoNombre,
    required String? vehiculoMatricula,
    required DateTime fecha,
    required List<TrasladoConRutaInfo> traslados,
    required RutaResumen resumen,
  }) async {
    try {
      final PdfRutaService pdfService = getIt<PdfRutaService>();

      await pdfService.generarPdfRuta(
        tecnicoNombre: tecnicoNombre,
        vehiculoMatricula: vehiculoMatricula,
        fecha: fecha,
        traslados: traslados,
        resumen: resumen,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF generado exitosamente'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al generar PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  void _calcularRuta() {
    if (_tecnicoSeleccionadoId == null) return;

    context.read<RutasBloc>().add(
          RutasEvent.cargarRutaRequested(
            tecnicoId: _tecnicoSeleccionadoId!,
            fecha: _fechaSeleccionada,
            turno: _turnoSeleccionado,
          ),
        );
  }

  String _formatFecha(DateTime fecha) {
    const List<String> meses = <String>[
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }
}
