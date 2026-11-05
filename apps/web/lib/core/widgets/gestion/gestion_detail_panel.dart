import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_formatters.dart';
import 'package:flutter/material.dart';

/// Pestaña de la ficha lateral
class GestionDetailTab {
  const GestionDetailTab({required this.label, required this.child});

  final String label;
  final Widget child;
}

/// Ficha lateral de detalle del registro seleccionado
class GestionDetailPanel extends StatelessWidget {
  const GestionDetailPanel({
    required this.title,
    required this.tabs,
    this.badges = const <Widget>[],
    this.actions = const <Widget>[],
    super.key,
  });

  final String title;
  final List<Widget> badges;
  final List<GestionDetailTab> tabs;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _PanelHeader(title: title, badges: badges),
          Container(
            height: 36,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.gray600,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              tabs: tabs.map((GestionDetailTab t) => Tab(text: t.label)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: tabs.map((GestionDetailTab t) => t.child).toList(),
            ),
          ),
          if (actions.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.gray200)),
              ),
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < actions.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(child: actions[i]),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.title, required this.badges});

  final String title;
  final List<Widget> badges;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      color: AppColors.gray50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          if (badges.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Wrap(spacing: 14, runSpacing: 4, children: badges),
          ],
        ],
      ),
    );
  }
}

/// Contenido desplazable de una pestaña de la ficha
class GestionDetailBody extends StatelessWidget {
  const GestionDetailBody({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
      children: children,
    );
  }
}

/// Título de sección dentro de la ficha: "──── Contacto ────"
class GestionDetailSection extends StatelessWidget {
  const GestionDetailSection({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Row(
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider(height: 1, color: AppColors.gray200)),
        ],
      ),
    );
  }
}

/// Fila "Etiqueta   Valor" de la ficha
class GestionDetailField extends StatelessWidget {
  const GestionDetailField({
    required this.label,
    this.value,
    this.child,
    this.labelWidth = 110,
    super.key,
  });

  final String label;
  final String? value;

  /// Contenido personalizado en lugar de [value]
  final Widget? child;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    final String text = GestionFormatters.texto(value);
    final bool empty = child == null && text == GestionFormatters.vacio;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12.5, color: AppColors.gray500),
            ),
          ),
          Expanded(
            child: child ??
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: empty ? AppColors.gray300 : AppColors.gray900,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

/// Mensaje cuando no hay ningún registro seleccionado
class GestionDetailEmpty extends StatelessWidget {
  const GestionDetailEmpty({
    this.message = 'Selecciona un registro para ver su ficha',
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.description_outlined, size: 40, color: AppColors.gray300),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.gray500),
            ),
          ],
        ),
      ),
    );
  }
}
