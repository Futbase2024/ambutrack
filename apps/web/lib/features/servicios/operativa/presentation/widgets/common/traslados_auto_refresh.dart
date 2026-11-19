import 'dart:async';

import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_bloc.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Mixin para vistas de monitorización: refresca en segundo plano
/// la última consulta de `TrasladosConsultaBloc` cada [autoRefreshInterval]
mixin TrasladosAutoRefresh<T extends StatefulWidget> on State<T> {
  Timer? _timer;
  bool autoRefresh = true;

  Duration get autoRefreshInterval => const Duration(seconds: 60);

  void startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(autoRefreshInterval, (Timer _) {
      if (autoRefresh && mounted) {
        context
            .read<TrasladosConsultaBloc>()
            .add(const TrasladosConsultaRefreshRequested(silent: true));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
