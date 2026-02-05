import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/excel_data_grid_filtered.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_bloc.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_event.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Tabla de servicios con filtros estilo Excel
class ServiciosTable extends StatefulWidget {
  const ServiciosTable({
    required this.onServicioSelected,
    super.key,
  });

  final void Function(String?) onServicioSelected;

  @override
  State<ServiciosTable> createState() => _ServiciosTableState();
}

class _ServiciosTableState extends State<ServiciosTable> {
  String? _selectedServicioId;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: BlocBuilder<ServiciosBloc, ServiciosState>(
        builder: (BuildContext context, ServiciosState state) {
          return state.when(
            initial: () => const Center(child: AppLoadingIndicator(message: 'Inicializando...')),
            loading: () => const Center(child: AppLoadingIndicator(message: 'Cargando servicios...')),
            loaded: (
              List<ServicioEntity> servicios,
              String searchQuery,
              int? yearFilter,
              String? estadoFilter,
              bool isRefreshing,
              ServicioEntity? selectedServicio,
              bool isLoadingDetails,
            ) {
              if (servicios.isEmpty) {
                return _buildEmptyState();
              }

              return Padding(
                padding: const EdgeInsets.all(3),
                child: ExcelDataGridFiltered<ServicioEntity>(
                  columns: _buildColumns(),
                  rows: servicios,
                  buildCells: _buildCells,
                  getColumnValue: _getColumnValue,
                  selectedItem: servicios.firstWhere(
                    (ServicioEntity s) => s.id == _selectedServicioId,
                    orElse: () => servicios.first,
                  ),
                  getItemId: (ServicioEntity servicio) => servicio.id ?? '',
                  onRowTap: (ServicioEntity servicio) {
                    if (servicio.id != null) {
                      setState(() {
                        _selectedServicioId = servicio.id;
                      });
                      widget.onServicioSelected(_selectedServicioId);

                      // Disparar evento para cargar detalles
                      context.read<ServiciosBloc>().add(
                            ServiciosEvent.loadServicioDetailsRequested(
                              id: servicio.id!,
                            ),
                          );
                    }
                  },
                  emptyMessage: 'No hay servicios para mostrar',
                ),
              );
            },
            error: (String message, List<ServicioEntity>? previousServicios) =>
                _buildErrorState(message),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.medical_services_outlined,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: AppSizes.spacing),
          Text(
            'No hay servicios registrados',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            'Crea un nuevo servicio para comenzar',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSizes.spacing),
          Text(
            'Error al cargar servicios',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
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

  /// Obtiene el valor de una columna para filtrado
  String _getColumnValue(ServicioEntity servicio, int columnIndex) {
    switch (columnIndex) {
      case 0:
        return servicio.codigo ?? '';
      case 1:
        return servicio.paciente?.nombreCompleto ?? '';
      case 2:
        return servicio.paciente?.domicilioDireccion ?? '';
      case 3:
        return servicio.paciente?.fechaNacimiento != null
            ? DateFormat('dd/MM/yyyy').format(servicio.paciente!.fechaNacimiento)
            : '';
      case 4:
        return (servicio.tipoRecurrencia ?? '').toUpperCase();
      case 5:
        return _getOrigenText(servicio);
      case 6:
        return _getDestinoText(servicio);
      case 7:
        return servicio.estado;
      default:
        return '';
    }
  }

  String _getOrigenText(ServicioEntity servicio) {
    // Si es domicilio del paciente, mostrar "DOMICILIO" o la dirección si existe
    if (servicio.tipoOrigen == 'domicilio_paciente') {
      final String? domicilio = servicio.paciente?.domicilioDireccion;
      return domicilio != null && domicilio.isNotEmpty ? domicilio : 'DOMICILIO';
    }

    // Si es centro hospitalario, usar el campo 'origen'
    return servicio.origen ?? '';
  }

  String _getDestinoText(ServicioEntity servicio) {
    // Si es domicilio del paciente, mostrar "DOMICILIO" o la dirección si existe
    if (servicio.tipoDestino == 'domicilio_paciente') {
      final String? domicilio = servicio.paciente?.domicilioDireccion;
      return domicilio != null && domicilio.isNotEmpty ? domicilio : 'DOMICILIO';
    }

    // Si es centro hospitalario, usar el campo 'destino'
    return servicio.destino ?? '';
  }

  List<ExcelColumnFiltered> _buildColumns() {
    return <ExcelColumnFiltered>[
      const ExcelColumnFiltered(
        label: 'Código',
        width: 120,
        sortable: true,
        searchable: true,
      ),
      const ExcelColumnFiltered(
        label: 'Paciente',
        minWidth: 180,
        sortable: true,
        filterable: true,
        searchable: true,
      ),
      const ExcelColumnFiltered(
        label: 'Domicilio',
        minWidth: 200,
        searchable: true,
      ),
      const ExcelColumnFiltered(
        label: 'F. Nacimiento',
        width: 120,
        sortable: true,
      ),
      const ExcelColumnFiltered(
        label: 'Tipo Recurrencia',
        width: 150,
        sortable: true,
        filterable: true,
        searchable: true,
      ),
      const ExcelColumnFiltered(
        label: 'Origen',
        width: 160,
        filterable: true,
        searchable: true,
      ),
      const ExcelColumnFiltered(
        label: 'Destino',
        width: 160,
        filterable: true,
        searchable: true,
      ),
      const ExcelColumnFiltered(
        label: 'Estado',
        width: 120,
        sortable: true,
        filterable: true,
        searchable: true,
      ),
    ];
  }

  List<Widget> _buildCells(ServicioEntity servicio) {
    final bool isSelected = _selectedServicioId == servicio.id;
    final String estado = servicio.estado.toUpperCase();

    // Determinar el color del texto según el estado
    Color? textColor;
    if (estado == 'ELIMINADO') {
      textColor = AppColors.error; // Rojo
    } else if (estado == 'SUSPENDIDO') {
      textColor = AppColors.warning; // Naranja
    }

    return <Widget>[
      _buildTextCell(servicio.codigo ?? '', isSelected, textColor),
      _buildTextCell(
        servicio.paciente?.nombreCompleto ?? '',
        isSelected,
        textColor,
      ),
      _buildTextCell(servicio.paciente?.domicilioDireccion ?? '', isSelected, textColor),
      if (servicio.paciente?.fechaNacimiento != null)
        _buildDateCell(servicio.paciente!.fechaNacimiento, isSelected, textColor)
      else
        _buildTextCell('', isSelected, textColor),
      _buildTextCell((servicio.tipoRecurrencia ?? '').toUpperCase(), isSelected, textColor),
      _buildTextCell(_getOrigenText(servicio), isSelected, textColor),
      _buildTextCell(_getDestinoText(servicio), isSelected, textColor),
      _buildEstadoBadge(servicio.estado, isSelected),
    ];
  }

  Widget _buildTextCell(String text, bool isSelected, [Color? customTextColor]) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppSizes.fontSmall,
          color: customTextColor ?? (isSelected ? AppColors.primary : AppColors.textPrimaryLight),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDateCell(DateTime date, bool isSelected, [Color? customTextColor]) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
        style: TextStyle(
          fontSize: AppSizes.fontSmall,
          color: customTextColor ?? (isSelected ? AppColors.primary : AppColors.textPrimaryLight),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEstadoBadge(String estado, bool isSelected) {
    Color badgeColor;
    switch (estado.toUpperCase()) {
      case 'ACTIVO':
        badgeColor = AppColors.success;
      case 'SUSPENDIDO':
        badgeColor = AppColors.warning;
      case 'FINALIZADO':
        badgeColor = AppColors.info;
      case 'ELIMINADO':
        badgeColor = AppColors.error;
      default:
        badgeColor = AppColors.gray500;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(
              color: badgeColor.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            estado.toUpperCase(),
            style: TextStyle(
              fontSize: AppSizes.fontSmall - 1,
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
