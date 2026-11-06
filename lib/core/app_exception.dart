/// Errores controlados de la aplicacion.
///
/// La capa de datos convierte cualquier fallo (sin red, tiempo agotado,
/// respuesta invalida...) en una de estas clases. Asi la interfaz siempre
/// recibe un error con un titulo y un mensaje claros, y la app no se cierra.
sealed class AppException implements Exception {
  const AppException(this.title, this.message);

  final String title;
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// No hay conexion a Internet (sin Wi-Fi ni datos, modo avion, DNS caido...).
class NoInternetException extends AppException {
  const NoInternetException()
      : super(
          'Sin conexión a Internet',
          'Revisa tu Wi-Fi o tus datos móviles e inténtalo de nuevo. '
              'Tus favoritos siguen disponibles sin conexión.',
        );
}

/// El servidor tardo demasiado en responder.
class TimeoutAppException extends AppException {
  const TimeoutAppException()
      : super(
          'El servidor tardó demasiado',
          'La conexión es lenta o inestable. Inténtalo de nuevo.',
        );
}

/// El servidor respondio con un codigo HTTP distinto de 200.
class ServerException extends AppException {
  const ServerException(this.statusCode)
      : super(
          'Error del servidor',
          'El servidor respondió con un error. Inténtalo más tarde.',
        );

  final int statusCode;

  @override
  String get message => 'El servidor respondió con el código $statusCode. '
      'Inténtalo más tarde.';
}

/// La respuesta no tiene el formato JSON esperado.
class DataException extends AppException {
  const DataException()
      : super(
          'Datos no válidos',
          'La respuesta del servidor no tiene el formato esperado.',
        );
}

/// No se pudo leer o escribir en el almacenamiento local.
class StorageException extends AppException {
  const StorageException()
      : super(
          'Error al guardar',
          'No se pudieron leer o guardar los favoritos en el dispositivo.',
        );
}

/// Cualquier otro error inesperado.
class UnknownException extends AppException {
  const UnknownException()
      : super(
          'Algo salió mal',
          'Ocurrió un error inesperado. Inténtalo de nuevo.',
        );
}
