import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Página de Incidencias
///
/// Reporte de problemas y eventos durante servicios
class IncidenciasPage extends StatelessWidget {
  const IncidenciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidencias'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.warning,
                size: 100,
                color: AppColors.warning,
              ),
              const SizedBox(height: 24),
              const Text(
                'Incidencias',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Feature en desarrollo',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implementar reporte de incidencia
                },
                icon: const Icon(Icons.add),
                label: const Text('Reportar Incidencia'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
