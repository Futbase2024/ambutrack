import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ambutrack_core/ambutrack_core.dart';
import '../bloc/traslados_bloc.dart';
import '../bloc/traslados_state.dart';
import 'traslado_card.dart';

/// Contenedor inteligente que envuelve TrasladoCard y solo la reconstruye
/// cuando el traslado específico cambia, no cuando cambia toda la lista.
///
/// Esto optimiza el rendimiento evitando rebuilds innecesarios.
class TrasladoCardContainer extends StatelessWidget {
  const TrasladoCardContainer({
    required this.trasladoId,
    required this.onTap,
    required this.onCambiarEstado,
    super.key,
  });

  final String trasladoId;
  final VoidCallback onTap;
  final void Function(EstadoTraslado)? onCambiarEstado;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrasladosBloc, TrasladosState>(
      buildWhen: (previous, current) {
        // Solo reconstruir cuando el traslado ESPECÍFICO cambió

        // Si no es TrasladosLoaded, no mostrar nada (no reconstruir)
        if (current is! TrasladosLoaded) {
          return false;
        }

        // Si es la primera carga
        if (previous is! TrasladosLoaded) {
          return true;
        }

        // Buscar el traslado específico en ambas listas
        TrasladoEntity? previousTraslado;
        TrasladoEntity? currentTraslado;

        try {
          previousTraslado = previous.traslados.firstWhere((t) => t.id == trasladoId);
        } catch (e) {
          previousTraslado = null;
        }

        try {
          currentTraslado = current.traslados.firstWhere((t) => t.id == trasladoId);
        } catch (e) {
          currentTraslado = null;
        }

        // Reconstruir solo si el traslado cambió
        if (previousTraslado == null && currentTraslado != null) {
          debugPrint('🆕 [CardContainer] Traslado $trasladoId añadido - reconstruyendo');
          return true; // Traslado añadido
        }
        if (previousTraslado != null && currentTraslado == null) {
          debugPrint('🗑️ [CardContainer] Traslado $trasladoId eliminado - reconstruyendo');
          return true; // Traslado eliminado
        }
        if (previousTraslado != null && currentTraslado != null) {
          // Comparar usando Equatable
          final cambio = previousTraslado != currentTraslado;
          if (cambio) {
            debugPrint('🔄 [CardContainer] Traslado $trasladoId cambió - reconstruyendo');
            debugPrint('   - Estado anterior: ${previousTraslado.estado.label}');
            debugPrint('   - Estado actual: ${currentTraslado.estado.label}');
          }
          return cambio;
        }

        return false;
      },
      builder: (context, state) {
        if (state is! TrasladosLoaded) {
          // Si no hay traslados cargados, no mostrar nada
          return const SizedBox.shrink();
        }

        // Buscar el traslado en la lista actual
        final traslado = state.traslados
            .cast<TrasladoEntity?>()
            .firstWhere((t) => t?.id == trasladoId, orElse: () => null);

        if (traslado == null) {
          // Si el traslado no existe (fue eliminado), no mostrar nada
          return const SizedBox.shrink();
        }

        // Renderizar la tarjeta con el traslado actualizado
        return TrasladoCard(
          traslado: traslado,
          onTap: onTap,
          onCambiarEstado: onCambiarEstado,
        );
      },
    );
  }
}
