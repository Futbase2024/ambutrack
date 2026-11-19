import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Pestaña "Mis tallas": el trabajador guarda sus tallas para almacén
class MisTallasTab extends StatefulWidget {
  const MisTallasTab({
    required this.idPersonal,
    required this.tallas,
    required this.guardando,
    required this.onGuardar,
    super.key,
  });

  final String idPersonal;
  final TallasPersonalEntity? tallas;
  final bool guardando;
  final ValueChanged<TallasPersonalEntity> onGuardar;

  @override
  State<MisTallasTab> createState() => _MisTallasTabState();
}

class _MisTallasTabState extends State<MisTallasTab> {
  static const List<(String, String, IconData)> _campos = <(String, String, IconData)>[
    ('camiseta', 'Camiseta', Icons.checkroom_outlined),
    ('polo', 'Polo', Icons.checkroom_outlined),
    ('sudadera', 'Sudadera / forro', Icons.checkroom_outlined),
    ('chaqueta', 'Chaqueta / parka', Icons.checkroom_outlined),
    ('pantalon', 'Pantalón', Icons.straighten_outlined),
    ('calzado', 'Calzado (nº)', Icons.hiking_outlined),
    ('guantes', 'Guantes', Icons.back_hand_outlined),
  ];

  late final Map<String, TextEditingController> _c = <String, TextEditingController>{
    for (final (String clave, String _, IconData _) in _campos) clave: TextEditingController(text: _valor(clave)),
    'observaciones': TextEditingController(text: widget.tallas?.observaciones ?? ''),
  };

  String _valor(String clave) {
    final TallasPersonalEntity? t = widget.tallas;
    return switch (clave) {
          'camiseta' => t?.camiseta,
          'polo' => t?.polo,
          'sudadera' => t?.sudadera,
          'chaqueta' => t?.chaqueta,
          'pantalon' => t?.pantalon,
          'calzado' => t?.calzado,
          'guantes' => t?.guantes,
          _ => null,
        } ??
        '';
  }

  @override
  void dispose() {
    for (final TextEditingController c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? _leer(String clave) {
    final String v = _c[clave]!.text.trim().toUpperCase();
    return v.isEmpty ? null : v;
  }

  void _guardar() {
    FocusScope.of(context).unfocus();
    widget.onGuardar(
      TallasPersonalEntity(
        personalId: widget.idPersonal,
        camiseta: _leer('camiseta'),
        polo: _leer('polo'),
        sudadera: _leer('sudadera'),
        chaqueta: _leer('chaqueta'),
        pantalon: _leer('pantalon'),
        calzado: _leer('calzado'),
        guantes: _leer('guantes'),
        observaciones: _c['observaciones']!.text.trim().isEmpty ? null : _c['observaciones']!.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: <Widget>[
        const Text(
          'Almacén usará estas tallas cuando te prepare el vestuario.',
          style: TextStyle(color: AppColors.gray600),
        ),
        const SizedBox(height: 16),
        for (final (String clave, String etiqueta, IconData icono) in _campos)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: _c[clave],
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: etiqueta, prefixIcon: Icon(icono), hintText: 'Ej: L, 42...'),
            ),
          ),
        TextField(
          controller: _c['observaciones'],
          maxLines: 2,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(labelText: 'Observaciones (opcional)'),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: widget.guardando ? null : _guardar,
          icon: const Icon(Icons.save_rounded),
          label: const Text('Guardar mis tallas'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
