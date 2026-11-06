import 'app_exception.dart';

/// Estado de una pantalla que carga datos: cargando, exito o error.
///
/// Es una clase sellada (sealed): la interfaz usa un `switch` y el
/// compilador obliga a dibujar los tres casos.
sealed class UiState<T> {
  const UiState();
}

class LoadingState<T> extends UiState<T> {
  const LoadingState();
}

class SuccessState<T> extends UiState<T> {
  const SuccessState(this.data);

  final T data;
}

class ErrorState<T> extends UiState<T> {
  const ErrorState(this.error);

  final AppException error;
}
