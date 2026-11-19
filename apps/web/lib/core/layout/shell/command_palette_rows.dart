import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/layout/shell/shell_navigation.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Altura de cada fila del buscador
const double _kFila = 38;

/// Entrada seleccionable del buscador: un registro o una pantalla
class PaletteEntrada {
  const PaletteEntrada.registro(ResultadoBusquedaEntity this.registro) : destino = null;
  const PaletteEntrada.pantalla(ShellDestino this.destino) : registro = null;

  final ResultadoBusquedaEntity? registro;
  final ShellDestino? destino;
}

/// Icono de cada tipo de registro
IconData _iconoTipo(TipoResultadoBusqueda tipo) {
  switch (tipo) {
    case TipoResultadoBusqueda.vehiculo:
      return Icons.local_shipping_outlined;
    case TipoResultadoBusqueda.paciente:
      return Icons.personal_injury_outlined;
    case TipoResultadoBusqueda.personal:
      return Icons.badge_outlined;
    case TipoResultadoBusqueda.orden:
      return Icons.build_outlined;
    case TipoResultadoBusqueda.otro:
      return Icons.description_outlined;
  }
}

/// Lista de resultados con secciones "Registros" y "Pantallas"
class PaletteResultList extends StatelessWidget {
  const PaletteResultList({
    required this.items,
    required this.numRegistros,
    required this.selectedIndex,
    required this.favoritos,
    required this.onTap,
    super.key,
  });

  final List<PaletteEntrada> items;

  /// Las primeras [numRegistros] entradas son registros; el resto, pantallas
  final int numRegistros;
  final int selectedIndex;
  final List<String> favoritos;
  final ValueChanged<PaletteEntrada> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text('Sin resultados', style: TextStyle(color: AppColors.gray500)),
      );
    }
    final bool conSecciones = numRegistros > 0;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: <Widget>[
        if (conSecciones) const _SectionHeader('Registros'),
        for (int i = 0; i < items.length; i++) ...<Widget>[
          if (conSecciones && i == numRegistros) const _SectionHeader('Pantallas'),
          SizedBox(
            height: _kFila,
            child: _PaletteRow(
              entrada: items[i],
              selected: i == selectedIndex,
              favorito: items[i].destino != null && favoritos.contains(items[i].destino!.route),
              onTap: () => onTap(items[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: AppColors.gray500,
        ),
      ),
    );
  }
}

class _PaletteRow extends StatelessWidget {
  const _PaletteRow({required this.entrada, required this.selected, required this.favorito, required this.onTap});

  final PaletteEntrada entrada;
  final bool selected;
  final bool favorito;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ResultadoBusquedaEntity? r = entrada.registro;
    final ShellDestino? d = entrada.destino;
    final IconData icono = r != null ? _iconoTipo(r.tipo) : d!.item.icon;
    final String titulo = r?.titulo ?? d!.label;
    final String? detalle = r != null
        ? <String?>[r.tipo.label, r.subtitulo].whereType<String>().join(' · ')
        : d!.parent?.label;
    return Material(
      color: selected ? AppColors.primarySurface : Colors.white,
      child: InkWell(
        onTap: onTap,
        hoverColor: AppColors.gray100,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: <Widget>[
              Icon(icono, size: 17, color: selected ? AppColors.primary : AppColors.gray500),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.primary : AppColors.gray900,
                  ),
                ),
              ),
              if (detalle != null && detalle.isNotEmpty) ...<Widget>[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    detalle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                  ),
                ),
              ],
              const Spacer(),
              if (favorito) const Icon(Icons.star_rounded, size: 15, color: AppColors.warning),
              if (selected) const Icon(Icons.keyboard_return, size: 14, color: AppColors.gray400),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pie con atajos de teclado (y aviso mientras se buscan registros)
class PaletteFooter extends StatelessWidget {
  const PaletteFooter({required this.buscando, super.key});

  final bool buscando;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Text(
              '↑↓ moverse   ·   Intro abrir   ·   Esc cerrar',
              style: TextStyle(fontSize: 11.5, color: AppColors.gray500),
            ),
          ),
          if (buscando) ...<Widget>[
            const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5)),
            const SizedBox(width: 6),
            const Text('Buscando registros…', style: TextStyle(fontSize: 11.5, color: AppColors.gray500)),
          ],
        ],
      ),
    );
  }
}
