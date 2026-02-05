import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Página de Checklist de Ambulancia
///
/// Revisión pre-servicio de vehículo y equipamiento
class ChecklistAmbulanciaPage extends StatelessWidget {
  const ChecklistAmbulanciaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist de Ambulancia'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.checklist,
                size: 100,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Checklist de Ambulancia',
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
                  // TODO: Implementar checklist
                },
                icon: const Icon(Icons.add),
                label: const Text('Nuevo Checklist'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
