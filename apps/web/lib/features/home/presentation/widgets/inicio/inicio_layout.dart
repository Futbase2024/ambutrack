import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/widgets/alertas_proximas_banner.dart';
import 'package:ambutrack_web/features/home/presentation/widgets/inicio/servicios_en_curso_panel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Ancho a partir del cual el dashboard ocupa la pantalla sin scroll
const double _kAnchoAmplio = 1100;

/// Altura de la franja de gráficas cuando comparte pantalla con los servicios
const double _kAlturaGraficas = 270;

/// Altura de cada panel cuando se apilan (pantallas estrechas)
const double _kAlturaPanelApilado = 380;

/// Layout del dashboard de inicio con el estilo de las pantallas de gestión:
/// barra superior (título, fecha, Actualizar), indicadores del día y paneles
/// de servicios en curso y gráficas.
class InicioLayout extends StatelessWidget {
  const InicioLayout({
    required this.indicadores,
    required this.onRefresh,
    this.servicios,
    this.graficas,
    super.key,
  });

  /// Tarjetas de indicadores del rol
  final Widget indicadores;
  final VoidCallback onRefresh;

  /// Servicios en curso (null = el rol no gestiona servicios)
  final List<TrasladoEntity>? servicios;

  /// Gráficas del rol (null = el rol no tiene gráficas)
  final Widget? graficas;

  static String _hoy() {
    final String texto = DateFormat("EEEE, d 'de' MMMM 'de' y", 'es_ES').format(DateTime.now());
    return texto.isEmpty ? texto : '${texto[0].toUpperCase()}${texto.substring(1)}';
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestionToolbar(
            title: 'Inicio',
            icon: Icons.dashboard_outlined,
            groups: <List<GestionToolbarAction>>[
              <GestionToolbarAction>[
                GestionToolbarAction(icon: Icons.refresh, label: 'Actualizar', onPressed: onRefresh),
              ],
            ],
            trailing: Text(_hoy(), style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) =>
                  constraints.maxWidth >= _kAnchoAmplio ? _CuerpoAncho(layout: this) : _CuerpoApilado(layout: this),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pantalla ancha: indicadores, franja de gráficas a todo el ancho y
/// servicios en curso ocupando el resto (sin scroll de página)
class _CuerpoAncho extends StatelessWidget {
  const _CuerpoAncho({required this.layout});

  final InicioLayout layout;

  @override
  Widget build(BuildContext context) {
    final Widget? graficas = layout.graficas;
    final List<TrasladoEntity>? servicios = layout.servicios;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const AlertasProximasBanner(),
          layout.indicadores,
          if (graficas != null) ...<Widget>[
            const SizedBox(height: 14),
            if (servicios == null) Expanded(child: graficas) else SizedBox(height: _kAlturaGraficas, child: graficas),
          ],
          if (servicios != null) ...<Widget>[
            const SizedBox(height: 14),
            Expanded(child: ServiciosEnCursoPanel(servicios: servicios)),
          ],
        ],
      ),
    );
  }
}

/// Pantalla estrecha: todo apilado con scroll vertical
class _CuerpoApilado extends StatelessWidget {
  const _CuerpoApilado({required this.layout});

  final InicioLayout layout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: <Widget>[
        const AlertasProximasBanner(),
        layout.indicadores,
        if (layout.graficas != null) ...<Widget>[
          const SizedBox(height: 14),
          SizedBox(height: _kAlturaPanelApilado, child: layout.graficas),
        ],
        if (layout.servicios != null) ...<Widget>[
          const SizedBox(height: 14),
          SizedBox(height: _kAlturaPanelApilado, child: ServiciosEnCursoPanel(servicios: layout.servicios!)),
        ],
      ],
    );
  }
}
