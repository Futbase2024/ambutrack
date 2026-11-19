import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de protocolos y normativas
abstract class ProtocoloNormativaState extends Equatable {
  const ProtocoloNormativaState();

  @override
  List<Object?> get props => <Object?>[];
}

class ProtocoloNormativaInitial extends ProtocoloNormativaState {
  const ProtocoloNormativaInitial();
}

class ProtocoloNormativaLoading extends ProtocoloNormativaState {
  const ProtocoloNormativaLoading();
}

class ProtocoloNormativaLoaded extends ProtocoloNormativaState {
  const ProtocoloNormativaLoaded(this.protocolos);

  final List<ProtocoloNormativaEntity> protocolos;

  @override
  List<Object?> get props => <Object?>[protocolos];
}

/// Operación de escritura en curso (crear, actualizar o eliminar)
class ProtocoloNormativaSaving extends ProtocoloNormativaState {
  const ProtocoloNormativaSaving();
}

class ProtocoloNormativaDeleted extends ProtocoloNormativaState {
  const ProtocoloNormativaDeleted();
}

class ProtocoloNormativaError extends ProtocoloNormativaState {
  const ProtocoloNormativaError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
