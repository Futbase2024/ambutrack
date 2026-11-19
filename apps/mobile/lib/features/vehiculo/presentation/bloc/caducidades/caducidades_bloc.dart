import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/stock_repository.dart';
import 'caducidades_event.dart';
import 'caducidades_state.dart';

/// Bloc para gestionar caducidades de productos en vehículos
class CaducidadesBloc extends Bloc<CaducidadesEvent, CaducidadesState> {
  final StockRepository _stockRepository;

  CaducidadesBloc({required StockRepository stockRepository})
      : _stockRepository = stockRepository,
        super(const CaducidadesInitial()) {
    on<LoadCaducidades>(_onLoadCaducidades);
    on<RefreshCaducidades>(_onRefreshCaducidades);
  }

  Future<void> _onLoadCaducidades(
    LoadCaducidades event,
    Emitter<CaducidadesState> emit,
  ) async {
    try {
      emit(const CaducidadesLoading());

      debugPrint('🔔 CaducidadesBloc: Cargando stock del vehículo: ${event.vehiculoId}');

      // Obtener stock del vehículo
      final stock = await _stockRepository.getStockVehiculo(event.vehiculoId);

      debugPrint('🔔 CaducidadesBloc: Stock obtenido: ${stock.length} items');

      // Filtrar solo items con caducidad
      final itemsConCaducidad = stock
          .where((item) => item.fechaCaducidad != null)
          .toList()
        ..sort((a, b) => a.fechaCaducidad!.compareTo(b.fechaCaducidad!));

      debugPrint('🔔 CaducidadesBloc: Items con caducidad: ${itemsConCaducidad.length}');

      // Calcular contadores por estado
      final hoy = DateTime.now();
      int vencidos = 0;
      int proximosAVencer = 0;
      int vigentes = 0;

      for (final item in itemsConCaducidad) {
        final diasRestantes = item.fechaCaducidad!.difference(hoy).inDays;

        if (diasRestantes < 0) {
          vencidos++;
        } else if (diasRestantes <= 30) {
          proximosAVencer++;
        } else {
          vigentes++;
        }
      }

      debugPrint('🔔 CaducidadesBloc: Vencidos: $vencidos, Próximos: $proximosAVencer, Vigentes: $vigentes');

      emit(CaducidadesLoaded(
        items: itemsConCaducidad,
        vencidos: vencidos,
        proximosAVencer: proximosAVencer,
        vigentes: vigentes,
      ));
    } catch (e, stack) {
      debugPrint('🔔 CaducidadesBloc: ❌ Error al cargar caducidades: $e');
      debugPrint('Stack: $stack');
      emit(CaducidadesError('Error al cargar caducidades: $e'));
    }
  }

  Future<void> _onRefreshCaducidades(
    RefreshCaducidades event,
    Emitter<CaducidadesState> emit,
  ) async {
    // Mismo comportamiento que LoadCaducidades
    await _onLoadCaducidades(LoadCaducidades(event.vehiculoId), emit);
  }
}
