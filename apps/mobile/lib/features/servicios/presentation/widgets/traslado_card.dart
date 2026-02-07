import 'package:flutter/material.dart';

import 'package:ambutrack_core/ambutrack_core.dart';
import '../../../../core/theme/app_colors.dart';

/// Card responsivo para mostrar un traslado en la lista
/// - Móvil estrecho (<400px): Layout vertical compacto
/// - Tablet/móvil ancho (≥400px): Layout horizontal 2 columnas
class TrasladoCard extends StatelessWidget {
  const TrasladoCard({
    required this.traslado,
    required this.onTap,
    this.onCambiarEstado,
    super.key,
  });

  final TrasladoEntity traslado;
  final VoidCallback onTap;
  final void Function(EstadoTraslado)? onCambiarEstado;

  /// Obtiene el label a mostrar en el badge
  /// Si el estado es "SALIENDO", muestra "EN RUTA" en su lugar
  String _getBadgeLabel(EstadoTraslado estado) {
    if (estado == EstadoTraslado.saliendoOrigen) {
      return 'EN RUTA';
    }
    return estado.label;
  }

  @override
  Widget build(BuildContext context) {
    final estadoColor = _getColorFromHex(traslado.estado.colorHex);
    final screenWidth = MediaQuery.of(context).size.width;
    // Usar layout vertical (narrow) para móviles < 600px
    // Layout horizontal (wide) solo para tablets >= 600px
    final isNarrow = screenWidth < 600;

    // Color del borde según tipo de traslado
    final bool esIda = traslado.tipoTraslado.toUpperCase() == 'IDA';
    final Color colorBorde = esIda ? AppColors.primary : AppColors.emergency;

    // Obtener siguiente estado si existe y hay callback
    final EstadoTraslado? siguienteEstado = _obtenerSiguienteEstado(traslado.estado);
    final bool mostrarBotonAccion = onCambiarEstado != null &&
                                     siguienteEstado != null &&
                                     traslado.estado.isActivo;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: colorBorde,
                  width: 4,
                ),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contenido principal de la tarjeta
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: isNarrow
                      ? _buildNarrowLayout(estadoColor)
                      : _buildWideLayout(estadoColor),
                ),

                // Botón de acción rápida en la parte inferior (si aplica)
                if (mostrarBotonAccion && siguienteEstado != null)
                  _buildBotonAccionInferior(siguienteEstado),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Layout para pantallas estrechas (móvil)
  Widget _buildNarrowLayout(Color estadoColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila 1: Hora (30%) + Estado (40%) + Requisitos (30%)
        SizedBox(
          height: 52, // Altura fija para toda la fila
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hora (30%)
              Flexible(
                flex: 30,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        estadoColor,
                        estadoColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: estadoColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      traslado.horaProgramada.substring(0, 5),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Estado (40%)
              Flexible(
                flex: 40,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  decoration: BoxDecoration(
                    color: estadoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: estadoColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _getBadgeLabel(traslado.estado),
                        style: TextStyle(
                          color: estadoColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Requisitos (30%)
              Flexible(
                flex: 30,
                child: traslado.requiereEquipamientoEspecial
                    ? Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (traslado.requiereCamilla)
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Icon(Icons.bed, color: AppColors.info),
                                ),
                              ),
                            if (traslado.requiereSillaRuedas)
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Icon(Icons.accessible, color: AppColors.info),
                                ),
                              ),
                            if (traslado.requiereAyuda)
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Icon(Icons.people, color: AppColors.info),
                                ),
                              ),
                            if (traslado.requiereAcompanante)
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Icon(Icons.person_add, color: AppColors.info),
                                ),
                              ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Paciente
        Row(
          children: [
            const Icon(
              Icons.person,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                traslado.pacienteNombre ?? 'No especificado',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Origen (full width)
        _buildUbicacionCompacta(
          icono: Icons.trip_origin,
          color: AppColors.success,
          label: 'ORIGEN',
          direccion: traslado.origenCompleto,
          poblacion: traslado.poblacionOrigen,
        ),
        const SizedBox(height: 12),

        // Destino (full width)
        _buildUbicacionCompacta(
          icono: Icons.location_on,
          color: AppColors.emergency,
          label: 'DESTINO',
          direccion: traslado.destinoCompleto,
          poblacion: traslado.poblacionDestino,
        ),
      ],
    );
  }

  /// Layout para pantallas anchas (tablet/móvil grande)
  Widget _buildWideLayout(Color estadoColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FILA 1: Hora + Código + Estado | Requisitos
        SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // IZQUIERDA 50%: Hora + Código + Estado
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hora
                    Container(
                      width: 90,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            estadoColor,
                            estadoColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: estadoColor.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          traslado.horaProgramada.substring(0, 5),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Código y Estado
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              traslado.codigo,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.gray700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: estadoColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: estadoColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _getBadgeLabel(traslado.estado),
                                    style: TextStyle(
                                      color: estadoColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Prioridad
                    if (traslado.prioridad <= 3) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.highPriority,
                          shape: BoxShape.circle,
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Icon(
                            Icons.priority_high,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // DERECHA 50%: Requisitos
              Expanded(
                child: traslado.requiereEquipamientoEspecial
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (traslado.requiereCamilla)
                            _buildRequisitoCircularLarge(Icons.bed),
                          if (traslado.requiereSillaRuedas)
                            _buildRequisitoCircularLarge(Icons.accessible),
                          if (traslado.requiereAyuda)
                            _buildRequisitoCircularLarge(Icons.people),
                          if (traslado.requiereAcompanante)
                            _buildRequisitoCircularLarge(Icons.person_add),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Paciente
        Row(
          children: [
            const Icon(
              Icons.person,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                traslado.pacienteNombre ?? 'No especificado',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // FILA 2: Origen | Destino (50/50)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IZQUIERDA 50%: Origen
            Expanded(
              child: _buildUbicacionCompacta(
                icono: Icons.trip_origin,
                color: AppColors.success,
                label: 'ORIGEN',
                direccion: traslado.origenCompleto,
                poblacion: traslado.poblacionOrigen,
              ),
            ),
            const SizedBox(width: 10),
            // DERECHA 50%: Destino
            Expanded(
              child: _buildUbicacionCompacta(
                icono: Icons.location_on,
                color: AppColors.emergency,
                label: 'DESTINO',
                direccion: traslado.destinoCompleto,
                poblacion: traslado.poblacionDestino,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Widget de ubicación compacto
  Widget _buildUbicacionCompacta({
    required IconData icono,
    required Color color,
    required String label,
    required String direccion,
    String? poblacion,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icono,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                direccion,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (poblacion != null && poblacion.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  poblacion,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Icono circular de requisito grande (para tablet)
  Widget _buildRequisitoCircularLarge(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(left: 6),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Icon(
          icon,
          size: 24,
          color: AppColors.info,
        ),
      ),
    );
  }

  /// Botón de acción inferior para cambiar estado
  Widget _buildBotonAccionInferior(EstadoTraslado siguienteEstado) {
    final color = _getColorFromHex(siguienteEstado.colorHex);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.gray200,
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onCambiarEstado?.call(siguienteEstado),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIconForEstado(siguienteEstado),
                  size: 18,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cambiar a ${siguienteEstado.label}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Obtiene el siguiente estado posible
  EstadoTraslado? _obtenerSiguienteEstado(EstadoTraslado estadoActual) {
    switch (estadoActual) {
      case EstadoTraslado.asignado:
      case EstadoTraslado.pendiente:
      case EstadoTraslado.enviado:
        return EstadoTraslado.recibido;
      case EstadoTraslado.recibido:
        return EstadoTraslado.enOrigen;
      case EstadoTraslado.enOrigen:
        return EstadoTraslado.saliendoOrigen;
      case EstadoTraslado.saliendoOrigen:
        return EstadoTraslado.enDestino;
      case EstadoTraslado.enDestino:
        return EstadoTraslado.finalizado;
      default:
        return null;
    }
  }

  /// Obtiene el icono apropiado para cada estado
  IconData _getIconForEstado(EstadoTraslado estado) {
    switch (estado) {
      case EstadoTraslado.enviado:
        return Icons.send_outlined;
      case EstadoTraslado.recibido:
        return Icons.check_circle_outline;
      case EstadoTraslado.enOrigen:
        return Icons.location_on;
      case EstadoTraslado.saliendoOrigen:
        return Icons.drive_eta;
      case EstadoTraslado.enTransito:
        return Icons.local_shipping_outlined;
      case EstadoTraslado.enDestino:
        return Icons.place;
      case EstadoTraslado.finalizado:
        return Icons.check_circle;
      default:
        return Icons.arrow_forward;
    }
  }

  /// Convierte hex string a Color
  Color _getColorFromHex(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
