import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de Proveedores
abstract class ProveedoresState extends Equatable {
  const ProveedoresState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class ProveedoresInitial extends ProveedoresState {
  const ProveedoresInitial();
}

/// Estado de carga
class ProveedoresLoading extends ProveedoresState {
  const ProveedoresLoading();
}

/// Estado con proveedores cargados
class ProveedoresLoaded extends ProveedoresState {
  const ProveedoresLoaded({
    required this.proveedores,
    this.isSearching = false,
    this.searchQuery = '',
  });

  final List<ProveedorEntity> proveedores;
  final bool isSearching;
  final String searchQuery;

  @override
  List<Object?> get props => <Object?>[proveedores, isSearching, searchQuery];

  ProveedoresLoaded copyWith({
    List<ProveedorEntity>? proveedores,
    bool? isSearching,
    String? searchQuery,
  }) {
    return ProveedoresLoaded(
      proveedores: proveedores ?? this.proveedores,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Estado de error
class ProveedoresError extends ProveedoresState {
  const ProveedoresError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Estado de operación en progreso (create/update/delete)
class ProveedoresOperationInProgress extends ProveedoresState {
  const ProveedoresOperationInProgress();
}

/// Estado de operación completada con éxito
class ProveedoresOperationSuccess extends ProveedoresState {
  const ProveedoresOperationSuccess({
    required this.message,
    required this.proveedores,
  });

  final String message;
  final List<ProveedorEntity> proveedores;

  @override
  List<Object?> get props => <Object?>[message, proveedores];
}
