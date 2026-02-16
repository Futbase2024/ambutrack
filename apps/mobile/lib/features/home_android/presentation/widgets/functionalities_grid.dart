import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'functionality_card.dart';

/// Grid de funcionalidades mejorado para Home Dashboard
///
/// Características:
/// - Grid 2 columnas responsive
/// - 6 tarjetas de funcionalidad
/// - Estados dinámicos según el turno
/// - Diseño Material 3
class FunctionalitiesGrid extends StatelessWidget {
  const FunctionalitiesGrid({
    super.key,
    required this.isShiftActive,
    this.pendingServicesCount,
    this.vehiclePlate,
  });

  final bool isShiftActive;
  final int? pendingServicesCount;
  final String? vehiclePlate;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: [
        // 1. Turno - Siempre activo, muestra estado del turno
        FunctionalityCard(
          icon: Icons.timer_outlined,
          title: 'Mi Turno',
          badge: isShiftActive ? 'En Servicio' : null,
          state: isShiftActive
              ? FunctionalityCardState.active
              : FunctionalityCardState.enabled,
          onTap: () => _navigateTo(context, '/registro-horario'),
        ),

        // 2. Servicios - Requiere turno activo
        FunctionalityCard(
          icon: Icons.medical_services_outlined,
          title: 'Servicios',
          subtitle: pendingServicesCount != null
              ? '$pendingServicesCount pendientes'
              : null,
          state: isShiftActive
              ? FunctionalityCardState.enabled
              : FunctionalityCardState.disabled,
          onTap: isShiftActive
              ? () => _navigateTo(context, '/servicios')
              : null,
        ),

        // 3. Trámites - Requiere turno activo
        FunctionalityCard(
          icon: Icons.description_outlined,
          title: 'Trámites',
          subtitle: 'Gestión de partes',
          state: isShiftActive
              ? FunctionalityCardState.enabled
              : FunctionalityCardState.disabled,
          onTap: isShiftActive
              ? () => _navigateTo(context, '/tramites')
              : null,
        ),

        // 4. Vehículo - Requiere turno activo
        FunctionalityCard(
          icon: Icons.directions_car_outlined, // Icono de vehículo
          title: 'Vehículo',
          subtitle: vehiclePlate != null ? 'Checklist $vehiclePlate' : null,
          state: isShiftActive
              ? FunctionalityCardState.enabled
              : FunctionalityCardState.disabled,
          onTap: isShiftActive
              ? () => _navigateTo(context, '/vehiculo')
              : null,
        ),

        // 5. Vestuario - Requiere turno activo
        FunctionalityCard(
          icon: Icons.checkroom_outlined,
          title: 'Vestuario',
          subtitle: 'Solicitudes',
          state: isShiftActive
              ? FunctionalityCardState.enabled
              : FunctionalityCardState.disabled,
          onTap: isShiftActive
              ? () => _navigateTo(context, '/vestuario')
              : null,
        ),

        // 6. Formación - Disponible siempre
        FunctionalityCard(
          icon: Icons.school_outlined,
          title: 'Formación',
          subtitle: 'Cursos activos',
          state: FunctionalityCardState.enabled,
          onTap: () => _navigateTo(context, '/formacion'),
        ),
      ],
    );
  }

  void _navigateTo(BuildContext context, String route) {
    GoRouter.of(context).push(route);
  }
}
