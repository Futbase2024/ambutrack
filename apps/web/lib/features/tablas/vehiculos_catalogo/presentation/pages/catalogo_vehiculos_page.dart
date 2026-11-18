import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Página índice del catálogo de vehículos.
///
/// El catálogo ya está cubierto por tablas maestras independientes; esta página
/// solo enlaza con ellas.
class CatalogoVehiculosPage extends StatelessWidget {
  const CatalogoVehiculosPage({super.key});

  static const List<_CatalogoEntrada> _entradas = <_CatalogoEntrada>[
    _CatalogoEntrada(
      titulo: 'Tipos de Vehículo',
      descripcion: 'SVB, SVA, colectiva... Clasificación funcional de las unidades.',
      icon: Icons.local_shipping,
      ruta: '/tablas/tipos-vehiculo',
    ),
    _CatalogoEntrada(
      titulo: 'Categorías de Vehículos',
      descripcion: 'Categorías de la flota usadas en planificación y filtros.',
      icon: Icons.category,
      ruta: '/tablas/categorias-vehiculos',
    ),
    _CatalogoEntrada(
      titulo: 'Plantillas de Equipamiento',
      descripcion: 'Dotación estándar de material por tipo de vehículo.',
      icon: Icons.inventory,
      ruta: '/tablas/plantillas-equipamiento',
    ),
    _CatalogoEntrada(
      titulo: 'Flota de Vehículos',
      descripcion: 'Alta y gestión de los vehículos de la empresa.',
      icon: Icons.directions_car,
      ruta: '/vehiculos',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Catálogo de Vehículos',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.gray900),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tablas maestras relacionadas con la flota',
                style: TextStyle(fontSize: 14, color: AppColors.gray600),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _entradas.map((_CatalogoEntrada e) => _CatalogoCard(entrada: e)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogoEntrada {
  const _CatalogoEntrada({
    required this.titulo,
    required this.descripcion,
    required this.icon,
    required this.ruta,
  });

  final String titulo;
  final String descripcion;
  final IconData icon;
  final String ruta;
}

class _CatalogoCard extends StatelessWidget {
  const _CatalogoCard({required this.entrada});

  final _CatalogoEntrada entrada;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go(entrada.ruta),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(entrada.icon, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        entrada.titulo,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entrada.descripcion,
                        style: const TextStyle(fontSize: 12.5, color: AppColors.gray600, height: 1.35),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.gray400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
