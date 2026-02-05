import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Panel con 3 secciones:
/// 1. Trayectos reales (arriba)
/// 2. Fechas excluidas (medio)
/// 3. Fechas incluidas (abajo)
class TrayectosExcepcionesPanel extends StatefulWidget {
  const TrayectosExcepcionesPanel({
    required this.servicioId,
    super.key,
  });

  final String servicioId;

  @override
  State<TrayectosExcepcionesPanel> createState() =>
      _TrayectosExcepcionesPanelState();
}

class _TrayectosExcepcionesPanelState
    extends State<TrayectosExcepcionesPanel> {
  final TrasladoDataSource _trasladoDataSource =
      TrasladoDataSourceFactory.createSupabase();

  int _selectedTab = 0; // 0: Activos, 1: Histórico, 2: Todos

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.gray200),
              ),
            ),
            child: const Row(
              children: <Widget>[
                Icon(
                  Icons.alt_route,
                  size: 20,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppSizes.spacingSmall),
                Text(
                  'TRAYECTOS/EXCEPCIONES',
                  style: TextStyle(
                    fontSize: AppSizes.fontMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Contenido con StreamBuilder
          Expanded(
            child: StreamBuilder<List<TrasladoEntity>>(
              stream: _trasladoDataSource.watchByServicioRecurrente(widget.servicioId),
              builder: (BuildContext context, AsyncSnapshot<List<TrasladoEntity>> snapshot) {
                // Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error
                if (snapshot.hasError) {
                  return _buildError(snapshot.error.toString());
                }

                // Sin datos
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Sin trayectos',
                      style: TextStyle(
                        fontSize: AppSizes.fontSmall,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  );
                }

                // Datos cargados
                final List<TrasladoEntity> todosTrayectos = snapshot.data!;
                final List<TrasladoEntity> trayectosActivos =
                    todosTrayectos.where((TrasladoEntity t) => t.estaEnCurso).toList();
                final List<TrasladoEntity> trayectosHistorico =
                    todosTrayectos.where((TrasladoEntity t) => !t.estaEnCurso).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Tabs: Trayectos Activos | Histórico | Todos
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.gray200),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          _buildTabButton(
                            index: 0,
                            label: 'Trayectos Activos: ${trayectosActivos.length}',
                          ),
                          _buildTabButton(
                            index: 1,
                            label: 'Histórico de Trayectos',
                          ),
                          _buildTabButton(
                            index: 2,
                            label: 'Todos los Trayectos',
                          ),
                        ],
                      ),
                    ),

                    // Contenido
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          // 1. TRAYECTOS (arriba)
                          Expanded(
                            flex: 2,
                            child: _buildTrayectosContent(
                              trayectosActivos: trayectosActivos,
                              trayectosHistorico: trayectosHistorico,
                              todosTrayectos: todosTrayectos,
                            ),
                          ),

                          const Divider(height: 1),

                          // 2. FECHAS EXCLUIDAS (medio)
                          Expanded(
                            child: _buildFechasExcluidasContent(),
                          ),

                          const Divider(height: 1),

                          // 3. FECHAS INCLUIDAS (abajo)
                          Expanded(
                            child: _buildFechasIncluidasContent(),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({required int index, required String label}) {
    final bool isSelected = _selectedTab == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSizes.fontSmall,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrayectosContent({
    required List<TrasladoEntity> trayectosActivos,
    required List<TrasladoEntity> trayectosHistorico,
    required List<TrasladoEntity> todosTrayectos,
  }) {
    final List<TrasladoEntity> trayectos;

    switch (_selectedTab) {
      case 0:
        trayectos = trayectosActivos;
      case 1:
        trayectos = trayectosHistorico;
      case 2:
        trayectos = todosTrayectos;
      default:
        trayectos = <TrasladoEntity>[];
    }

    if (trayectos.isEmpty) {
      return const Center(
        child: Text(
          'Sin trayectos',
          style: TextStyle(
            fontSize: AppSizes.fontSmall,
            color: AppColors.textSecondaryLight,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: trayectos.length,
      itemBuilder: (BuildContext context, int index) {
        final TrasladoEntity trayecto = trayectos[index];
        return _buildTrayectoCard(trayecto);
      },
    );
  }

  Widget _buildTrayectoCard(TrasladoEntity trayecto) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final DateFormat timeFormat = DateFormat('HH:mm');

    // Color según estado
    Color estadoColor;
    switch (trayecto.estado) {
      case 'pendiente':
        estadoColor = AppColors.textSecondaryLight; // Gris
      case 'cancelado':
      case 'anulado':
        estadoColor = AppColors.error; // Rojo
      case 'asignado':
      case 'enviado':
      case 'recibido_conductor':
      case 'en_origen':
      case 'saliendo_origen':
      case 'en_transito':
      case 'en_destino':
      case 'finalizado':
        estadoColor = AppColors.success; // Verde
      case 'no_realizado':
        estadoColor = AppColors.warning; // Amarillo/naranja
      default:
        estadoColor = AppColors.textSecondaryLight;
    }

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
          // Cabecera: Fecha + Estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${trayecto.fecha != null ? dateFormat.format(trayecto.fecha!) : 'Sin fecha'} - ${trayecto.horaProgramada != null ? timeFormat.format(trayecto.horaProgramada!) : 'Sin hora'}',
                style: const TextStyle(
                  fontSize: AppSizes.fontSmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: estadoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(color: estadoColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  trayecto.estadoFormateado,
                  style: TextStyle(
                    fontSize: AppSizes.fontSmall,
                    color: estadoColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSmall),

          // Origen
          if (trayecto.origen != null)
            Row(
              children: <Widget>[
                const Icon(Icons.location_on,
                    size: 16, color: AppColors.success),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    trayecto.origen!,
                    style: const TextStyle(
                      fontSize: AppSizes.fontSmall,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ],
            ),

          // Destino
          if (trayecto.destino != null) ...<Widget>[
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                const Icon(Icons.flag, size: 16, color: AppColors.error),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    trayecto.destino!,
                    style: const TextStyle(
                      fontSize: AppSizes.fontSmall,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: AppSizes.spacingSmall),
          const Divider(),
          const SizedBox(height: AppSizes.spacingSmall),

          // Conductor y vehículo
          Row(
            children: <Widget>[
              if (trayecto.idPersonalConductor != null) ...<Widget>[
                const Icon(Icons.person,
                    size: 16, color: AppColors.textSecondaryLight),
                const SizedBox(width: 4),
                Text(
                  'Conductor: ${trayecto.idPersonalConductor}',
                  style: const TextStyle(
                    fontSize: AppSizes.fontSmall,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(width: AppSizes.spacing),
              ],
              if (trayecto.idVehiculo != null) ...<Widget>[
                const Icon(Icons.directions_car,
                    size: 16, color: AppColors.textSecondaryLight),
                const SizedBox(width: 4),
                Text(
                  'Vehículo: ${trayecto.idVehiculo}',
                  style: const TextStyle(
                    fontSize: AppSizes.fontSmall,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFechasExcluidasContent() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.event_busy, size: 16, color: AppColors.error),
              SizedBox(width: 4),
              Text(
                'FECHAS EXCLUIDAS',
                style: TextStyle(
                  fontSize: AppSizes.fontSmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacingSmall),
          Expanded(
            child: Center(
              child: Text(
                'Sin fechas excluidas',
                style: TextStyle(
                  fontSize: AppSizes.fontSmall,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFechasIncluidasContent() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.event_available, size: 16, color: AppColors.success),
              SizedBox(width: 4),
              Text(
                'FECHAS INCLUIDAS',
                style: TextStyle(
                  fontSize: AppSizes.fontSmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacingSmall),
          Expanded(
            child: Center(
              child: Text(
                'Sin fechas incluidas',
                style: TextStyle(
                  fontSize: AppSizes.fontSmall,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: AppSizes.spacing),
          const Text(
            'Error al cargar trayectos',
            style: TextStyle(
              fontSize: AppSizes.fontMedium,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            errorMessage,
            style: const TextStyle(
              fontSize: AppSizes.fontSmall,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
