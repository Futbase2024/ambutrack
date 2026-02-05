import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget de filtro tipo Excel para columnas de tabla
///
/// Muestra un icono de filtro que al hacer clic abre un menú popup
/// con checkboxes para filtrar por múltiples valores
class FiltroDropdownWidget extends StatefulWidget {
  const FiltroDropdownWidget({
    required this.columna,
    required this.valores,
    required this.seleccionados,
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final String columna;
  final Set<String> valores;
  final Set<String> seleccionados;
  final TextEditingController controller;
  final ValueChanged<Set<String>> onChanged;

  @override
  State<FiltroDropdownWidget> createState() => _FiltroDropdownWidgetState();
}

class _FiltroDropdownWidgetState extends State<FiltroDropdownWidget> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    // Limpiar overlay sin llamar a setState (el widget ya no está montado)
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  void _toggleMenu() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showMenu();
    }
  }

  void _showMenu() {
    if (!mounted) {
      return;
    }
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    if (mounted) {
      setState(() {
        _isOpen = true;
      });
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeOverlay,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 4,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 4),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(8),
                  child: _FiltroMenuContent(
                    columna: widget.columna,
                    valores: widget.valores,
                    seleccionados: widget.seleccionados,
                    controller: widget.controller,
                    onChanged: (Set<String> nuevosSeleccionados) {
                      widget.onChanged(nuevosSeleccionados);
                      _removeOverlay();
                    },
                    onCancel: _removeOverlay,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hayFiltrosActivos = widget.seleccionados.isNotEmpty;

    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleMenu,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Icon(
            hayFiltrosActivos ? Icons.filter_alt : Icons.filter_alt_outlined,
            size: 18,
            color: hayFiltrosActivos ? AppColors.primary : AppColors.gray400,
          ),
        ),
      ),
    );
  }
}

/// Contenido del menú de filtros con búsqueda y checkboxes
class _FiltroMenuContent extends StatefulWidget {
  const _FiltroMenuContent({
    required this.columna,
    required this.valores,
    required this.seleccionados,
    required this.controller,
    required this.onChanged,
    required this.onCancel,
  });

  final String columna;
  final Set<String> valores;
  final Set<String> seleccionados;
  final TextEditingController controller;
  final ValueChanged<Set<String>> onChanged;
  final VoidCallback onCancel;

  @override
  State<_FiltroMenuContent> createState() => _FiltroMenuContentState();
}

class _FiltroMenuContentState extends State<_FiltroMenuContent> {
  late Set<String> _temporalSeleccionados;
  late TextEditingController _searchController;
  late List<String> _valoresFiltrados;

  @override
  void initState() {
    super.initState();
    _temporalSeleccionados = Set<String>.from(widget.seleccionados);
    _searchController = TextEditingController(text: widget.controller.text);
    _valoresFiltrados = widget.valores.toList()..sort();
    _searchController.addListener(_filtrarValores);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_filtrarValores)
      ..dispose();
    super.dispose();
  }

  void _filtrarValores() {
    setState(() {
      final String query = _searchController.text.toLowerCase();
      if (query.isEmpty) {
        _valoresFiltrados = widget.valores.toList()..sort();
      } else {
        _valoresFiltrados = widget.valores
            .where((String v) => v.toLowerCase().contains(query))
            .toList()
          ..sort();
      }
    });
  }

  void _toggleSeleccion(String valor) {
    setState(() {
      if (_temporalSeleccionados.contains(valor)) {
        _temporalSeleccionados.remove(valor);
      } else {
        _temporalSeleccionados.add(valor);
      }
    });
  }

  void _seleccionarTodos() {
    setState(() {
      _temporalSeleccionados = Set<String>.from(_valoresFiltrados);
    });
  }

  void _limpiarTodo() {
    setState(() {
      _temporalSeleccionados.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      constraints: const BoxConstraints(maxHeight: 400),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Campo de búsqueda
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            style: GoogleFonts.inter(fontSize: 13),
          ),
          const SizedBox(height: 8),

          // Botones Seleccionar/Limpiar
          Row(
            children: <Widget>[
              Expanded(
                child: TextButton(
                  onPressed: _seleccionarTodos,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  child: Text(
                    'Seleccionar todos',
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: _limpiarTodo,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  child: Text(
                    'Limpiar',
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 16),

          // Lista de checkboxes
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _valoresFiltrados.length,
              itemBuilder: (BuildContext context, int index) {
                final String valor = _valoresFiltrados[index];
                final bool seleccionado = _temporalSeleccionados.contains(valor);

                return CheckboxListTile(
                  value: seleccionado,
                  onChanged: (bool? _) => _toggleSeleccion(valor),
                  title: Text(
                    valor,
                    style: GoogleFonts.inter(fontSize: 13),
                  ),
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          ),

          const Divider(height: 16),

          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: widget.onCancel,
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.inter(fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  widget.controller.text = _searchController.text;
                  widget.onChanged(_temporalSeleccionados);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  'Aplicar',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
