import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/menus/action_menu.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/ficha/trayecto_analisis_dialog.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/servicio_fechas_excepcion_panel.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/trayecto_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Pestaña de trayectos generados y excepciones del servicio
class ServicioTrayectosTab extends StatefulWidget {
  const ServicioTrayectosTab({required this.servicio, super.key});

  final ServicioEntity servicio;

  @override
  State<ServicioTrayectosTab> createState() => ServicioTrayectosTabState();
}

class ServicioTrayectosTabState extends State<ServicioTrayectosTab>
    with TickerProviderStateMixin {
  late TabController _trayectosTabController;
  final TrasladoDataSource _trasladoDataSource = TrasladoDataSourceFactory.createSupabase();

  List<TrasladoEntity> _trayectosActivos = <TrasladoEntity>[];
  List<TrasladoEntity> _trayectosHistorico = <TrasladoEntity>[];
  List<TrasladoEntity> _todosTrayectos = <TrasladoEntity>[];
  bool _isLoading = true;
  String? _error;
  int _selectedTrayectoTab = 0;
  int? _selectedRowIndex;
  bool _sortAscending = true; // Ordenación ascendente por defecto

  @override
  void initState() {
    super.initState();
    _trayectosTabController = TabController(length: 3, vsync: this);
    _trayectosTabController.addListener(() {
      if (_trayectosTabController.indexIsChanging) {
        setState(() {
          _selectedTrayectoTab = _trayectosTabController.index;
          _selectedRowIndex = null; // Resetear selección al cambiar de tab
        });
      }
    });
    _loadTrayectos();
  }

  @override
  void dispose() {
    _trayectosTabController.dispose();
    super.dispose();
  }

  Future<void> _loadTrayectos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final String servicioId = widget.servicio.id ?? '';
      debugPrint('🔍 Cargando trayectos para servicio ID: "$servicioId"');
      debugPrint('🔍 Servicio codigo: ${widget.servicio.codigo}');
      debugPrint('🔍 Tipo de recurrencia: ${widget.servicio.tipoRecurrencia}');

      List<TrasladoEntity> trayectos = <TrasladoEntity>[];

      // Buscar traslados directamente por id_servicio (funciona para ambos: únicos y recurrentes)
      debugPrint('🔍 Buscando traslados por id_servicio: "$servicioId"');
      final List<PostgrestMap> trasladosResponse = await Supabase.instance.client
          .from('traslados')
          .select()
          .eq('id_servicio', servicioId)
          .order('fecha', ascending: true);

      if (trasladosResponse.isNotEmpty) {
        debugPrint('📄 Primer traslado JSON: ${trasladosResponse.first}');
        trayectos = trasladosResponse
            .map((PostgrestMap json) => TrasladoSupabaseModel.fromJson(json).toEntity())
            .toList();
        debugPrint('✅ Trayectos cargados: ${trayectos.length}');
      } else {
        debugPrint('⚠️ No se encontraron trayectos para este servicio');
      }

      if (trayectos.isNotEmpty) {
        debugPrint('📋 Primeros trayectos:');
        for (final TrasladoEntity t in trayectos.take(3)) {
          debugPrint('  - ${t.codigo}: ${t.origen} → ${t.destino} (Estado: ${t.estado})');
        }
      }

      // Estados considerados "en curso" (activos)
      const Set<String> estadosEnCurso = <String>{
        'pendiente',
        'asignado',
        'recibido_conductor',
        'en_origen',
        'saliendo_origen',
        'en_destino',
      };
      final List<TrasladoEntity> activos = trayectos.where((TrasladoEntity t) => estadosEnCurso.contains(t.estado)).toList();
      final List<TrasladoEntity> historico = trayectos.where((TrasladoEntity t) => !estadosEnCurso.contains(t.estado)).toList();

      setState(() {
        _trayectosActivos = activos;
        _trayectosHistorico = historico;
        _todosTrayectos = trayectos;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error al cargar trayectos: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Verifica si dos fechas son del mismo día
  bool _isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) {
      return false;
    }
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Sección de TRAYECTOS (arriba)
        Expanded(
          flex: 2,
          child: _buildTrayectosSection(),
        ),

        const SizedBox(height: AppSizes.spacing),

        // Sección de fechas excluidas/incluidas (abajo)
        Expanded(
          child: ServicioFechasExcepcionPanel(
            servicioId: widget.servicio.id ?? '',
            onChanged: _loadTrayectos,
          ),
        ),
      ],
    );
  }

  /// Sección de trayectos con tabla
  Widget _buildTrayectosSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header de sección con tabs
          Row(
            children: <Widget>[
              const Text(
                'TRAYECTOS',
                style: TextStyle(
                  fontSize: AppSizes.fontSmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              // Tabs de filtro
              InkWell(
                onTap: () => _trayectosTabController.animateTo(0),
                child: _buildFilterChip(
                  'Trayectos Activos: ${_trayectosActivos.length}',
                  isActive: _selectedTrayectoTab == 0,
                ),
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              InkWell(
                onTap: () => _trayectosTabController.animateTo(1),
                child: _buildFilterChip(
                  'Histórico de Trayectos',
                  isActive: _selectedTrayectoTab == 1,
                ),
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              InkWell(
                onTap: () => _trayectosTabController.animateTo(2),
                child: _buildFilterChip(
                  'Todos los Trayectos',
                  isActive: _selectedTrayectoTab == 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing),

          // Contenido de tabla
          Expanded(
            child: _isLoading
                ? const Center(child: AppLoadingIndicator(message: 'Cargando trayectos...'))
                : _error != null
                    ? _buildErrorView()
                    : _buildTrayectosTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AppSizes.spacing),
          const Text(
            'Error al cargar trayectos',
            style: TextStyle(
              fontSize: AppSizes.fontMedium,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            _error ?? 'Error desconocido',
            style: const TextStyle(
              fontSize: AppSizes.fontSmall,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spacing),
          ElevatedButton.icon(
            onPressed: _loadTrayectos,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrayectosTable() {
    return TabBarView(
      controller: _trayectosTabController,
      children: <Widget>[
        _buildTrayectosList(_trayectosActivos),
        _buildTrayectosList(_trayectosHistorico),
        _buildTrayectosList(_todosTrayectos),
      ],
    );
  }

  /// Maneja las acciones del menú de trayectos
  Future<void> _handleTrayectoAction(String action, TrasladoEntity trayecto) async {
    debugPrint('🎬 Acción seleccionada: $action para trayecto ${trayecto.id}');

    try {
      String nuevoEstado;

      switch (action) {
        case 'cancelar':
          nuevoEstado = 'cancelado';
          break;
        case 'anular':
          // Anular: marcarlo como anulado (definitivo)
          nuevoEstado = 'anulado';
          break;
        case 'recuperar':
          // Recuperar: volver a pendiente para que pueda ser reasignado
          nuevoEstado = 'pendiente';
          break;
        case 'analizar':
          // Mostrar diálogo de análisis del trayecto
          if (mounted) {
            await showDialog<void>(
              context: context,
              builder: (BuildContext context) => TrayectoAnalisisDialog(
                trayecto: trayecto,
                servicio: widget.servicio,
              ),
            );
          }
          return;
        case 'eliminar':
          // Confirmar antes de eliminar (con diálogo profesional de doble confirmación)
          final bool? confirmado = await showConfirmationDialog(
            context: context,
            title: 'Confirmar Eliminación',
            message: '¿Estás seguro de que deseas eliminar este trayecto? Esta acción no se puede deshacer.',
            itemDetails: <String, String>{
              'Código': trayecto.codigo ?? 'Sin código',
              'Tipo': trayecto.tipoTraslado ?? 'Sin tipo',
              if (trayecto.fecha != null)
                'Fecha': DateFormat('dd/MM/yyyy').format(trayecto.fecha!),
              if (trayecto.horaProgramada != null)
                'Hora': DateFormat('HH:mm').format(trayecto.horaProgramada!),
              if (trayecto.origen != null && trayecto.origen!.isNotEmpty)
                'Origen': trayecto.origen!,
              if (trayecto.destino != null && trayecto.destino!.isNotEmpty)
                'Destino': trayecto.destino!,
              'Estado': (EstadoTraslado.fromValue(trayecto.estado)?.label ?? trayecto.estado ?? 'Desconocido').toUpperCase(),
            },
            warningMessage: '⚠️ El trayecto será eliminado permanentemente de la base de datos.',
          );

          if (confirmado != true) {
            return;
          }

          // Eliminar (hard delete - elimina de la base de datos)
          await _trasladoDataSource.hardDelete(trayecto.id);

          if (mounted) {
            // ✅ OPTIMIZACIÓN: Eliminar solo el trayecto de las listas locales
            setState(() {
              _trayectosActivos.removeWhere((TrasladoEntity t) => t.id == trayecto.id);
              _trayectosHistorico.removeWhere((TrasladoEntity t) => t.id == trayecto.id);
              _todosTrayectos.removeWhere((TrasladoEntity t) => t.id == trayecto.id);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Trayecto eliminado exitosamente'),
                backgroundColor: AppColors.success,
              ),
            );
          }

          return;
        case 'editar':
          // Mostrar formulario de edición
          if (mounted) {
            await showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext dialogContext) {
                return TrayectoFormDialog(
                  trayecto: trayecto,
                  onSave: (TrasladoEntity trayectoActualizado) {
                    // ✅ OPTIMIZACIÓN: Actualizar solo el trayecto modificado
                    setState(() {
                      final int indexActivos = _trayectosActivos.indexWhere((TrasladoEntity t) => t.id == trayectoActualizado.id);
                      final int indexHistorico = _trayectosHistorico.indexWhere((TrasladoEntity t) => t.id == trayectoActualizado.id);
                      final int indexTodos = _todosTrayectos.indexWhere((TrasladoEntity t) => t.id == trayectoActualizado.id);

                      if (indexActivos != -1) {
                        _trayectosActivos[indexActivos] = trayectoActualizado;
                      }
                      if (indexHistorico != -1) {
                        _trayectosHistorico[indexHistorico] = trayectoActualizado;
                      }
                      if (indexTodos != -1) {
                        _todosTrayectos[indexTodos] = trayectoActualizado;
                      }
                    });

                    // Mostrar mensaje de éxito
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Trayecto actualizado exitosamente'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                );
              },
            );
          }
          return;
        default:
          debugPrint('⚠️ Acción no reconocida: $action');
          return;
      }

      // Actualizar estado del trayecto
      final TrasladoEntity trayectoActualizado = await _trasladoDataSource.updateEstado(
        id: trayecto.id,
        nuevoEstado: nuevoEstado,
      );

      debugPrint('✅ Trayecto ${trayecto.codigo} actualizado a estado: $nuevoEstado');

      // ✅ OPTIMIZACIÓN: Actualizar solo el trayecto modificado en lugar de recargar todo
      if (mounted) {
        setState(() {
          // Actualizar en todas las listas
          final int indexActivos = _trayectosActivos.indexWhere((TrasladoEntity t) => t.id == trayecto.id);
          final int indexHistorico = _trayectosHistorico.indexWhere((TrasladoEntity t) => t.id == trayecto.id);
          final int indexTodos = _todosTrayectos.indexWhere((TrasladoEntity t) => t.id == trayecto.id);

          // Actualizar en lista correspondiente
          if (indexActivos != -1) {
            _trayectosActivos[indexActivos] = trayectoActualizado;
          }
          if (indexHistorico != -1) {
            _trayectosHistorico[indexHistorico] = trayectoActualizado;
          }
          if (indexTodos != -1) {
            _todosTrayectos[indexTodos] = trayectoActualizado;
          }

          // Si el estado cambió a inactivo (cancelado/anulado/finalizado), moverlo de activos a histórico
          final bool esInactivo = nuevoEstado == 'cancelado' ||
                                  nuevoEstado == 'anulado' ||
                                  nuevoEstado == 'finalizado';

          if (esInactivo && indexActivos != -1) {
            _trayectosActivos.removeAt(indexActivos);
            _trayectosHistorico.insert(0, trayectoActualizado);
          }

          // Si recuperamos (pendiente) y estaba en histórico, moverlo a activos
          if (nuevoEstado == 'pendiente' && indexHistorico != -1) {
            _trayectosHistorico.removeAt(indexHistorico);
            _trayectosActivos.insert(0, trayectoActualizado);
          }
        });

        // Si cancelamos, anulamos o finalizamos desde "Trayectos Activos", cambiar al tab "Todos los Trayectos"
        if (_selectedTrayectoTab == 0 && (nuevoEstado == 'cancelado' || nuevoEstado == 'anulado' || nuevoEstado == 'finalizado')) {
          _trayectosTabController.animateTo(2);
        }
      }
    } catch (e) {
      debugPrint('❌ Error al ejecutar acción $action: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _toggleSort() {
    setState(() {
      _sortAscending = !_sortAscending;
    });
  }

  Widget _buildTrayectosList(List<TrasladoEntity> trayectos) {
    if (trayectos.isEmpty) {
      return const Center(
        child: Text(
          'No hay trayectos',
          style: TextStyle(
            fontSize: AppSizes.fontSmall,
            color: AppColors.textSecondaryLight,
          ),
        ),
      );
    }

    // Ordenar trayectos por fecha y hora programada
    final List<TrasladoEntity> trayectosOrdenados = List<TrasladoEntity>.from(trayectos)
      ..sort((TrasladoEntity a, TrasladoEntity b) {
        // Primero ordenar por fecha
        final DateTime fechaA = a.fecha ?? DateTime(2000);
        final DateTime fechaB = b.fecha ?? DateTime(2000);
        final int fechaComparison = fechaA.compareTo(fechaB);

        // Si las fechas son iguales, ordenar por hora programada
        if (fechaComparison == 0) {
          final DateTime horaA = a.horaProgramada ?? DateTime(2000);
          final DateTime horaB = b.horaProgramada ?? DateTime(2000);
          final int horaComparison = horaA.compareTo(horaB);
          return _sortAscending ? horaComparison : -horaComparison;
        }

        return _sortAscending ? fechaComparison : -fechaComparison;
      });

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Column(
        children: <Widget>[
          // Header de tabla
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingSmall,
              vertical: AppSizes.paddingSmall,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusSmall),
                topRight: Radius.circular(AppSizes.radiusSmall),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: _toggleSort,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          'Fecha',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppSizes.fontSmall,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                const Expanded(flex: 2, child: _TrayectoHeaderCell('Estado')),
                const Expanded(child: _TrayectoHeaderCell('I/V')),
                const Expanded(child: _TrayectoHeaderCell('H. Prog')),
                const Expanded(child: _TrayectoHeaderCell('H. Rec')),
                const Expanded(child: _TrayectoHeaderCell('H. Tras')),
                const Expanded(child: _TrayectoHeaderCell('Vehículo')),
                const Expanded(child: _TrayectoHeaderCell('Conductor')),
                const Expanded(child: _TrayectoHeaderCell('Acciones')),
              ],
            ),
          ),

          // Filas de datos agrupadas por fecha
          Expanded(
            child: ListView.builder(
              itemCount: trayectosOrdenados.length,
              itemBuilder: (BuildContext context, int index) {
                final TrasladoEntity trayecto = trayectosOrdenados[index];
                final TrasladoEntity? prevTrayecto = index > 0 ? trayectosOrdenados[index - 1] : null;

                // Verificar si es un nuevo grupo de fecha
                final bool isNewGroup = prevTrayecto == null ||
                    !_isSameDay(prevTrayecto.fecha, trayecto.fecha);

                // Alternar color solo dentro del mismo grupo de fecha
                final bool isEven = index % 2 == 0;

                return Column(
                  children: <Widget>[
                    // Separador visual entre grupos de fechas
                    if (isNewGroup && index > 0)
                      Container(
                        height: 3,
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    _buildTrayectoRow(trayecto, index, isEven),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.gray200,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isActive ? Colors.white : AppColors.textSecondaryLight,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTrayectoRow(TrasladoEntity trayecto, int index, bool isEven) {
    final bool isSelected = _selectedRowIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRowIndex = isSelected ? null : index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : (isEven ? AppColors.surfaceLight : Colors.white),
          border: Border(
            bottom: const BorderSide(color: AppColors.gray200),
            left: isSelected
                ? const BorderSide(color: AppColors.primary, width: 3)
                : BorderSide.none,
          ),
        ),
        child: Row(
        children: <Widget>[
          // Fecha
          Expanded(
            flex: 2,
            child: _TrayectoDataCell(
              trayecto.fecha != null
                  ? DateFormat('dd/MM/yyyy').format(trayecto.fecha!)
                  : 'Sin fecha',
            ),
          ),
          // Estado
          Expanded(
            flex: 2,
            child: _TrayectoStatusCell(
              EstadoTraslado.fromValue(trayecto.estado)?.label ?? trayecto.estado ?? 'Desconocido'
            ),
          ),
          // Ida/Vuelta
          Expanded(
            child: _TrayectoIdaVueltaCell(
              trayecto.tipoTraslado ?? 'Sin tipo',
            ),
          ),
          // Hora Programada
          Expanded(
            child: _TrayectoDataCell(
              trayecto.horaProgramada != null
                  ? DateFormat('HH:mm').format(trayecto.horaProgramada!)
                  : 'Sin hora',
              textAlign: TextAlign.center,
            ),
          ),
          // H. Recogida
          Expanded(
            child: _TrayectoDataCell(
              trayecto.fechaSaliendoOrigen != null
                  ? DateFormat('HH:mm').format(trayecto.fechaSaliendoOrigen!.toLocal())
                  : '-',
              textAlign: TextAlign.center,
            ),
          ),
          // H. Llegada
          Expanded(
            child: _TrayectoDataCell(
              trayecto.fechaEnDestino != null
                  ? DateFormat('HH:mm').format(trayecto.fechaEnDestino!.toLocal())
                  : '-',
              textAlign: TextAlign.center,
            ),
          ),
          // Vehículo
          Expanded(
            child: _TrayectoDataCell(trayecto.idVehiculo ?? '-'),
          ),
          // Conductor
          Expanded(
            child: _TrayectoDataCell(trayecto.conductorNombre ?? trayecto.idConductor ?? '-'),
          ),
          // Acciones
          Expanded(
            child: _TrayectoAccionesCell(
              trayecto: trayecto,
              onAction: (String action) => _handleTrayectoAction(action, trayecto),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

/// Celda de header de tabla de trayectos
class _TrayectoHeaderCell extends StatelessWidget {
  const _TrayectoHeaderCell(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Celda de datos de tabla de trayectos
class _TrayectoDataCell extends StatelessWidget {
  const _TrayectoDataCell(this.text, {this.textAlign});

  final String text;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textPrimaryLight,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Celda de estado con color
class _TrayectoStatusCell extends StatelessWidget {
  const _TrayectoStatusCell(this.estado);

  final String estado;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (estado) {
      // Estados inactivos/cancelados - ROJO
      case 'Cancelado':
      case 'Anulado':
        color = AppColors.error;
        icon = Icons.cancel;

      // Estado pendiente - GRIS
      case 'Pendiente':
        color = AppColors.textSecondaryLight;
        icon = Icons.schedule;

      // Estados activos/en curso - VERDE
      case 'Asignado':
        color = AppColors.success;
        icon = Icons.assignment_turned_in;
      case 'Enviado':
        color = AppColors.success;
        icon = Icons.send;
      case 'Recibido por Conductor':
        color = AppColors.success;
        icon = Icons.check_circle;
      case 'En Origen':
        color = AppColors.success;
        icon = Icons.location_on;
      case 'Saliendo de Origen':
        color = AppColors.success;
        icon = Icons.directions_car;
      case 'En Tránsito':
        color = AppColors.success;
        icon = Icons.drive_eta;
      case 'En Destino':
        color = AppColors.success;
        icon = Icons.place;
      case 'Finalizado':
        color = AppColors.success;
        icon = Icons.check_circle;

      // No realizado - AMARILLO
      case 'No Realizado':
        color = AppColors.warning;
        icon = Icons.warning;

      default:
        color = AppColors.textSecondaryLight;
        icon = Icons.info;
    }

    return Row(
      children: <Widget>[
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            estado,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Celda de Ida/Vuelta con colores
class _TrayectoIdaVueltaCell extends StatelessWidget {
  const _TrayectoIdaVueltaCell(this.tipoTraslado);

  final String tipoTraslado;

  @override
  Widget build(BuildContext context) {
    final bool isIda = tipoTraslado.toLowerCase() == 'ida';
    final Color color = isIda ? AppColors.success : AppColors.error;

    return Text(
      tipoTraslado.toUpperCase(),
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 12,
        color: color,
        fontWeight: FontWeight.w600,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Celda de acciones con menú desplegable
class _TrayectoAccionesCell extends StatelessWidget {
  const _TrayectoAccionesCell({
    required this.trayecto,
    required this.onAction,
  });

  final TrasladoEntity trayecto;
  final void Function(String action) onAction;

  @override
  Widget build(BuildContext context) {
    // Determinar estado del trayecto
    final bool estaCancelado = trayecto.estado == EstadoTraslado.cancelado.value;
    final bool estaAnulado = trayecto.estado == EstadoTraslado.noRealizado.value;
    final bool estaFinalizado = trayecto.estado == EstadoTraslado.finalizado.value;

    // Estado inactivo: cancelado o anulado
    final bool estaInactivo = estaCancelado || estaAnulado;

    // Estado activo: NO está cancelado, anulado ni finalizado
    final bool estaActivo = !estaCancelado && !estaAnulado && !estaFinalizado;

    final List<ActionMenuItem> items = <ActionMenuItem>[
      // Editar (siempre disponible) - ✏️
      const ActionMenuItem(
        value: 'editar',
        label: '✏️ Editar',
      ),
    ];

    if (estaInactivo) {
      // Está cancelado o anulado → Mostrar Recuperar - ♻️
      items.add(
        const ActionMenuItem(
          value: 'recuperar',
          label: '♻️ Recuperar',
          description: 'Recuperar trayecto',
        ),
      );
    } else if (estaActivo) {
      // Está activo → Mostrar Cancelar y Anular
      // Cancelar - 🚫
      items
        ..add(
          const ActionMenuItem(
            value: 'cancelar',
            label: '🚫 Cancelar',
            description: 'Cancelar este trayecto',
          ),
        )
        // Anular - ⛔
        ..add(
          const ActionMenuItem(
            value: 'anular',
            label: '⛔ Anular',
            isDanger: true,
            description: 'Anular este trayecto',
          ),
        );
    }

    // Analizar (siempre disponible) - 📊
    items.add(
      const ActionMenuItem(
        value: 'analizar',
        label: '📊 Analizar',
        description: 'Analizar trayecto',
      ),
    );

    return ActionMenu(
      items: items,
      onSelected: onAction,
      tooltip: 'Acciones del trayecto',
    );
  }
}
