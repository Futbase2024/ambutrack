import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_sizes.dart';

/// Abre un buscador de personal activo y devuelve el compañero elegido
Future<TPersonalEntity?> showSelectorCompanero(
  BuildContext context, {
  required List<TPersonalEntity> personal,
}) {
  return showModalBottomSheet<TPersonalEntity>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _SelectorCompaneroSheet(personal: personal),
  );
}

class _SelectorCompaneroSheet extends StatefulWidget {
  const _SelectorCompaneroSheet({required this.personal});

  final List<TPersonalEntity> personal;

  @override
  State<_SelectorCompaneroSheet> createState() => _SelectorCompaneroSheetState();
}

class _SelectorCompaneroSheetState extends State<_SelectorCompaneroSheet> {
  String _filtro = '';

  String _nombre(TPersonalEntity p) => '${p.nombre} ${p.apellidos}'.trim().toUpperCase();

  List<TPersonalEntity> get _filtrados {
    final String q = _filtro.trim().toUpperCase();
    final List<TPersonalEntity> lista = q.isEmpty
        ? List<TPersonalEntity>.of(widget.personal)
        : widget.personal.where((TPersonalEntity p) => _nombre(p).contains(q) || (p.dni?.contains(q) ?? false)).toList();
    return lista..sort((TPersonalEntity a, TPersonalEntity b) => _nombre(a).compareTo(_nombre(b)));
  }

  @override
  Widget build(BuildContext context) {
    final List<TPersonalEntity> lista = _filtrados;
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(context).bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Elige a tu compañero',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900),
              ),
              const SizedBox(height: 12),
              TextField(
                autofocus: true,
                onChanged: (String v) => setState(() => _filtro = v),
                textInputAction: TextInputAction.search,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o DNI',
                  prefixIcon: const Icon(Icons.search_rounded),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.gray50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: lista.isEmpty
                    ? const Center(child: Text('Sin resultados', style: TextStyle(color: AppColors.gray600)))
                    : ListView.separated(
                        itemCount: lista.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (BuildContext context, int i) => ListTile(
                          leading: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                          title: Text(_nombre(lista[i])),
                          subtitle: lista[i].categoria == null ? null : Text(lista[i].categoria!),
                          onTap: () => Navigator.of(context).pop(lista[i]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
