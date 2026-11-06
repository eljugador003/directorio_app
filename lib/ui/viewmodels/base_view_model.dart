import 'package:flutter/foundation.dart';

/// Base de los ViewModels.
///
/// Si la pantalla se cierra (dispose) mientras una peticion sigue en curso,
/// la respuesta que llega despues se ignora en lugar de lanzar el error
/// "A ChangeNotifier was used after being disposed".
abstract class BaseViewModel extends ChangeNotifier {
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @protected
  void notifySafely() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
