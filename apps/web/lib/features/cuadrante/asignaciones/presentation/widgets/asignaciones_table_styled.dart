import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_event.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_state.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/asignacion_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Tabla de gestión de Asignaciones estilo transporte pacientes
///
/// Inspirada en diseño de referencia con:
/// - Agrupación por fecha (collapsible como I/V)
/// - Filas alternantes (blanco/verde claro)
/// - Estados con badges
/// - Checkboxes para confirmación
/// - Campos SI/NO con colores
/// - Header azul claro
class AsignacionesTableStyled extends StatefulWidget {
  const AsignacionesTableStyled({super.key});

  @override
  State<AsignacionesTableStyled> createState() => _AsignacionesTableStyledState();
}

class _AsignacionesTableStyledState extends State<AsignacionesTableStyled> {
  String _searchQuery = '';
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  /// Mapa de grupos expandidos por fecha
  final Map<String, bool> _expandedGroups = <String, bool>{};

  @override
  Widget build(BuildContext context) {
    return BlocListener<AsignacionesBloc, AsignacionesState>(
      listener: (BuildContext context, Object? state) async {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is AsignacionesLoaded || state is AsignacionesError || state is AsignacionOperationSuccess) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            if (state is AsignacionesError) {
              await CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Asignación',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else if (state is AsignacionOperationSuccess) {
              await CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Asignación',
                durationMs: elapsed.inMilliseconds,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            }
          }
        }
      },
      child: BlocBuilder<AsignacionesBloc, AsignacionesState>(
        builder: (BuildContext context, Object? state) {
          if (state is AsignacionesLoading) {
            return const _LoadingView();
          }

          if (state is AsignacionesError) {
            return _ErrorView(message: state.message);
          }

          if (state is AsignacionesLoaded || state is AsignacionOperationSuccess) {
            final List<AsignacionVehiculoTurnoEntity> asignaciones = state is AsignacionesLoaded
                ? state.asignaciones
                : (state as AsignacionOperationSuccess).asignaciones;

            final List<AsignacionVehiculoTurnoEntity> filtradas = _filterAsignaciones(asignaciones);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildHeader(context),
                const SizedBox(height: AppSizes.spacing),

                if (asignaciones.length != filtradas.length)
                  _buildFilterInfo(asignaciones.length, filtradas.length),

                Expanded(
                  child: _buildGroupedTable(filtradas),
                ),

                const SizedBox(height: AppSizes.spacing),
                _buildPagination(filtradas.length),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'Listado de Asignaciones',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ),
        SizedBox(
          width: 300,
          child: _SearchField(
            searchQuery: _searchQuery,
            onSearchChanged: (String query) {
              setState(() {
                _searchQuery = query;
                _currentPage = 0;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterInfo(int total, int filtradas) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing),
      child: Text(
        'Mostrando $filtradas de $total asignaciones',
        style: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildGroupedTable(List<AsignacionVehiculoTurnoEntity> asignaciones) {
    if (asignaciones.isEmpty) {
      return _buildEmptyState();
    }

    // Agrupar por fecha
    final Map<String, List<AsignacionVehiculoTurnoEntity>> grouped = _groupByFecha(asignaciones);

    // Ordenar fechas descendente
    final List<String> sortedDates = grouped.keys.toList()
      ..sort((String a, String b) => b.compareTo(a));

    // Paginar grupos
    final int startIndex = _currentPage * _itemsPerPage;
    int currentIndex = 0;
    final List<MapEntry<String, List<AsignacionVehiculoTurnoEntity>>> paginatedGroups = <MapEntry<String, List<AsignacionVehiculoTurnoEntity>>>[];

    for (final String date in sortedDates) {
      if (currentIndex >= startIndex && paginatedGroups.length < _itemsPerPage) {
        paginatedGroups.add(MapEntry<String, List<AsignacionVehiculoTurnoEntity>>(date, grouped[date]!));
      }
      currentIndex += grouped[date]!.length;
      if (paginatedGroups.length >= _itemsPerPage) {
        break;
      }
    }

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // Header de tabla
          _buildTableHeader(),

          // Grupos
          ...paginatedGroups.map((MapEntry<String, List<AsignacionVehiculoTurnoEntity>> entry) {
            return _buildGroup(entry.key, entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFFE3F2FD), // Azul claro como en la imagen
        border: Border(
          bottom: BorderSide(color: AppColors.gray300),
        ),
      ),
      child: const Row(
        children: <Widget>[
          // Grupo (I/V) -> Fecha
          SizedBox(
            width: 80,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'FECHA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),

          // Hora -> Vehículo
          SizedBox(
            width: 150,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'VEHÍCULO',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),

          // Paciente -> Dotación
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'DOTACIÓN',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),

          // Domicilio Origen -> Turno
          SizedBox(
            width: 120,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'TURNO',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),

          // Localidad Origen -> Estado
          SizedBox(
            width: 120,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'ESTADO',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),

          // Origen -> Destino
          SizedBox(
            width: 200,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'DESTINO',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),

          // Domicilio Destino -> Confirmado (checkbox)
          SizedBox(
            width: 100,
            child: Center(
              child: Text(
                'CONF.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),

          // Estatus -> Kms real (SI/NO)
          SizedBox(
            width: 80,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'KM REAL',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),

          // Conductor -> Completado (SI/NO)
          SizedBox(
            width: 80,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'COMP.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),

          // Estatus -> Kms
          SizedBox(
            width: 100,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'KMS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),

          // Destino -> Servicios
          SizedBox(
            width: 100,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'SERV.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),

          // Terápia -> Horas
          SizedBox(
            width: 100,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'HORAS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),

          // Acciones
          SizedBox(
            width: 80,
            child: Center(
              child: Text(
                'ACC.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(String fechaStr, List<AsignacionVehiculoTurnoEntity> items) {
    final bool isExpanded = _expandedGroups[fechaStr] ?? true;

    return Column(
      children: <Widget>[
        // Header de grupo (como I/V)
        InkWell(
          onTap: () {
            setState(() {
              _expandedGroups[fechaStr] = !isExpanded;
            });
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              border: Border.all(color: AppColors.gray300),
            ),
            child: Row(
              children: <Widget>[
                const SizedBox(width: 12),
                Icon(
                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 20,
                  color: AppColors.gray700,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.parse(fechaStr)),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${items.length}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Filas del grupo
        if (isExpanded)
          ...items.asMap().entries.map((MapEntry<int, AsignacionVehiculoTurnoEntity> entry) {
            final bool isEven = entry.key % 2 == 0;
            return _buildRow(entry.value, isEven);
          }),
      ],
    );
  }

  Widget _buildRow(AsignacionVehiculoTurnoEntity asignacion, bool isEven) {
    final Color bgColor = isEven ? Colors.white : const Color(0xFFF0FDF4); // Verde claro muy sutil

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: bgColor,
        border: const Border(
          bottom: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Row(
        children: <Widget>[
          // Fecha (vacío, ya está en el grupo)
          const SizedBox(width: 80),

          // Vehículo
          SizedBox(
            width: 150,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.directions_car, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      asignacion.vehiculoId,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Dotación
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                asignacion.dotacionId,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textPrimaryLight,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Turno
          SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                asignacion.plantillaTurnoId ?? 'Sin turno',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: asignacion.plantillaTurnoId != null
                      ? AppColors.textPrimaryLight
                      : AppColors.textSecondaryLight,
                  fontStyle: asignacion.plantillaTurnoId == null ? FontStyle.italic : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Estado (badge)
          SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildEstadoBadge(asignacion.estado),
            ),
          ),

          // Destino
          SizedBox(
            width: 200,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildDestinoCell(asignacion),
            ),
          ),

          // Confirmado (checkbox)
          SizedBox(
            width: 100,
            child: Center(
              child: Checkbox(
                value: asignacion.confirmadaPor != null,
                onChanged: (bool? value) {
                  _toggleConfirmacion(asignacion);
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),

          // Km Real (SI/NO)
          SizedBox(
            width: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildSiNoCell(asignacion.kmFinal != null && asignacion.kmFinal! > 0),
            ),
          ),

          // Completado (SI/NO)
          SizedBox(
            width: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildSiNoCell(asignacion.esCompletada),
            ),
          ),

          // Kms
          SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                asignacion.kmInicial != null && asignacion.kmFinal != null
                    ? (asignacion.kmFinal! - asignacion.kmInicial!).toStringAsFixed(0)
                    : '-',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),

          // Servicios
          SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '${asignacion.serviciosRealizados ?? 0}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),

          // Horas
          SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                asignacion.horasEfectivas != null
                    ? '${asignacion.horasEfectivas!.toStringAsFixed(1)}h'
                    : '-',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),

          // Km Real (SI/NO) - Deshabilitado visualmente, ya está antes de COMP
          // Se mantiene la posición actual para consistencia

          // Acciones
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _ActionButton(
                  icon: Icons.edit_outlined,
                  tooltip: 'Editar',
                  onPressed: () => _editAsignacion(context, asignacion),
                ),
                const SizedBox(width: 4),
                _ActionButton(
                  icon: Icons.delete_outline,
                  tooltip: 'Eliminar',
                  onPressed: () => _confirmDelete(context, asignacion),
                  color: AppColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoBadge(String estado) {
    final Color color = _getEstadoColor(estado);
    final String label = _getEstadoLabel(estado);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            _getEstadoIcon(estado),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinoCell(AsignacionVehiculoTurnoEntity asignacion) {
    if (asignacion.hospitalId != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.local_hospital, size: 14, color: AppColors.error),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'H: ${asignacion.hospitalId}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    if (asignacion.baseId != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.home_work, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'B: ${asignacion.baseId}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      'Sin asignar',
      style: GoogleFonts.inter(
        fontSize: 12,
        color: AppColors.textSecondaryLight,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildSiNoCell(bool valor) {
    final Color color = valor ? AppColors.success : AppColors.textSecondaryLight;
    final String label = valor ? 'SÍ' : 'NO';

    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'planificada':
        return AppColors.info;
      case 'confirmada':
        return AppColors.success;
      case 'en_curso':
        return AppColors.warning;
      case 'finalizada':
      case 'completada':
        return AppColors.textSecondaryLight;
      case 'cancelada':
        return AppColors.error;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'planificada':
        return Icons.schedule;
      case 'confirmada':
        return Icons.check_circle;
      case 'en_curso':
        return Icons.play_circle;
      case 'finalizada':
      case 'completada':
        return Icons.done_all;
      case 'cancelada':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getEstadoLabel(String estado) {
    switch (estado.toLowerCase()) {
      case 'planificada':
        return 'Planificada';
      case 'confirmada':
        return 'Confirmada';
      case 'en_curso':
        return 'En Curso';
      case 'finalizada':
      case 'completada':
        return 'Completada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return estado;
    }
  }

  Map<String, List<AsignacionVehiculoTurnoEntity>> _groupByFecha(List<AsignacionVehiculoTurnoEntity> asignaciones) {
    final Map<String, List<AsignacionVehiculoTurnoEntity>> grouped = <String, List<AsignacionVehiculoTurnoEntity>>{};

    for (final AsignacionVehiculoTurnoEntity asignacion in asignaciones) {
      final String fechaKey = DateFormat('yyyy-MM-dd').format(asignacion.fecha);
      grouped.putIfAbsent(fechaKey, () => <AsignacionVehiculoTurnoEntity>[]);
      grouped[fechaKey]!.add(asignacion);
    }

    return grouped;
  }

  List<AsignacionVehiculoTurnoEntity> _filterAsignaciones(List<AsignacionVehiculoTurnoEntity> asignaciones) {
    if (_searchQuery.isEmpty) {
      return asignaciones;
    }

    final String query = _searchQuery.toLowerCase();
    return asignaciones.where((AsignacionVehiculoTurnoEntity asignacion) {
      return asignacion.vehiculoId.toLowerCase().contains(query) ||
          asignacion.dotacionId.toLowerCase().contains(query) ||
          asignacion.estado.toLowerCase().contains(query) ||
          (asignacion.hospitalId?.toLowerCase().contains(query) ?? false) ||
          (asignacion.baseId?.toLowerCase().contains(query) ?? false) ||
          (asignacion.plantillaTurnoId?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  Widget _buildPagination(int totalItems) {
    final int totalPages = (totalItems / _itemsPerPage).ceil();

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Total: $totalItems asignaciones',
            style: AppTextStyles.bodySmallSecondary,
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: _currentPage > 0 ? () => setState(() => _currentPage = 0) : null,
                tooltip: 'Primera página',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                tooltip: 'Página anterior',
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  'Página ${_currentPage + 1} de ${totalPages.clamp(1, 999)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < totalPages.clamp(1, 999) - 1
                    ? () => setState(() => _currentPage++)
                    : null,
                tooltip: 'Página siguiente',
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: _currentPage < totalPages.clamp(1, 999) - 1
                    ? () => setState(() => _currentPage = totalPages.clamp(1, 999) - 1)
                    : null,
                tooltip: 'Última página',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      constraints: const BoxConstraints(minHeight: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray300),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.inbox_outlined,
              size: 64,
              color: AppColors.gray400,
            ),
            const SizedBox(height: AppSizes.spacing),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No se encontraron asignaciones con los filtros aplicados'
                  : 'No hay asignaciones registradas',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleConfirmacion(AsignacionVehiculoTurnoEntity asignacion) async {
    // Toggle de confirmación - aquí se implementaría la lógica
    debugPrint('🔄 Toggle confirmación: ${asignacion.id}');
  }

  Future<void> _editAsignacion(BuildContext context, AsignacionVehiculoTurnoEntity asignacion) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider<AsignacionesBloc>.value(
          value: context.read<AsignacionesBloc>(),
          child: AsignacionFormDialog(asignacion: asignacion),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, AsignacionVehiculoTurnoEntity asignacion) async {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar esta asignación? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Fecha': dateFormat.format(asignacion.fecha),
        'Vehículo': asignacion.vehiculoId,
        'Dotación': asignacion.dotacionId,
        'Estado': _getEstadoLabel(asignacion.estado),
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando asignación: ${asignacion.id}');

      unawaited(
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            _loadingDialogContext = dialogContext;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _isDeleting = true;
                  _deleteStartTime = DateTime.now();
                });
              }
            });

            return const AppLoadingOverlay(
              message: 'Eliminando asignación...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<AsignacionesBloc>().add(AsignacionesEvent.delete(asignacion.id));
      }
    }
  }
}

// ==================== WIDGETS AUXILIARES ====================

class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.searchQuery,
    required this.onSearchChanged,
  });

  final String searchQuery;
  final void Function(String) onSearchChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Buscar asignación...',
        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondaryLight),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondaryLight),
                onPressed: () {
                  _controller.clear();
                  widget.onSearchChanged('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        isDense: true,
      ),
      style: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textPrimaryLight,
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingMassive),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      constraints: const BoxConstraints(minHeight: 400),
      child: const Center(
        child: AppLoadingIndicator(
          message: 'Cargando asignaciones...',
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.error),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: AppSizes.spacing),
          Text(
            'Error al cargar asignaciones',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color = AppColors.secondaryLight,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color color;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _isHovered ? AppColors.gray100 : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Icon(
              widget.icon,
              size: 16,
              color: _isHovered ? widget.color : AppColors.gray500,
            ),
          ),
        ),
      ),
    );
  }
}
