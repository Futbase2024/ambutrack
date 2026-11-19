import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de protocolos y normativas
abstract class ProtocoloNormativaEvent extends Equatable {
  const ProtocoloNormativaEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargar todos los protocolos
class ProtocoloNormativaLoadAllRequested extends ProtocoloNormativaEvent {
  const ProtocoloNormativaLoadAllRequested();
}

/// Crear un protocolo
class ProtocoloNormativaCreateRequested extends ProtocoloNormativaEvent {
  const ProtocoloNormativaCreateRequested(this.protocolo);

  final ProtocoloNormativaEntity protocolo;

  @override
  List<Object?> get props => <Object?>[protocolo];
}

/// Actualizar un protocolo
class ProtocoloNormativaUpdateRequested extends ProtocoloNormativaEvent {
  const ProtocoloNormativaUpdateRequested(this.protocolo);

  final ProtocoloNormativaEntity protocolo;

  @override
  List<Object?> get props => <Object?>[protocolo];
}

/// Eliminar un protocolo
class ProtocoloNormativaDeleteRequested extends ProtocoloNormativaEvent {
  const ProtocoloNormativaDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
