import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Enlace directo a un registro de una pantalla de gestión.
///
/// La búsqueda global (Ctrl+K) navega a `ruta?id=<id>&q=<texto>`; la pantalla
/// muestra solo ese registro, seleccionado, con [texto] en el buscador.
class GestionDeepLink {
  const GestionDeepLink({this.id, this.texto});

  /// Lee el enlace de la URL actual (vacío si no hay o si no hay GoRouter)
  factory GestionDeepLink.of(BuildContext context) {
    try {
      final Map<String, String> params = GoRouterState.of(context).uri.queryParameters;
      return GestionDeepLink(id: params['id'], texto: params['q']);
    } on Object {
      return const GestionDeepLink();
    }
  }

  final String? id;
  final String? texto;

  bool get isEmpty => id == null || id!.isEmpty;

  /// Clave para no aplicar dos veces el mismo enlace
  String get clave => '${id ?? ''}|${texto ?? ''}';

  /// Ruta con el enlace al registro
  static String ruta(String path, {required String id, String? texto}) => Uri(
    path: path,
    queryParameters: <String, String>{'id': id, if (texto != null && texto.isNotEmpty) 'q': texto},
  ).toString();
}
