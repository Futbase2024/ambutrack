import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Página de Partes Diarios
///
/// Informes de servicios realizados
class PartesDiariosPage extends StatelessWidget {
  const PartesDiariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partes Diarios'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.assignment,
                size: 100,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Partes Diarios',
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
                  // TODO: Implementar parte diario
                },
                icon: const Icon(Icons.add),
                label: const Text('Nuevo Parte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
