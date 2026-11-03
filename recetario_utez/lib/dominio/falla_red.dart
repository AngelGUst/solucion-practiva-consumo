/// Fallas de red que la aplicación sabe explicar a la persona.
library;

sealed class FallaRed implements Exception {
  const FallaRed();
}

/// No hay conexión o el servidor no respondió.
final class SinConexion extends FallaRed {
  const SinConexion();
}

/// La petición superó el tiempo de espera configurado.
final class TiempoAgotado extends FallaRed {
  const TiempoAgotado();
}

/// El servidor respondió con un código 5xx.
final class ErrorDelServidor extends FallaRed {
  const ErrorDelServidor(this.codigo);

  final int codigo;
}

/// El servidor rechazó la petición con un código distinto de 5xx.
final class PeticionRechazada extends FallaRed {
  const PeticionRechazada(this.codigo);

  final int codigo;
}

/// La respuesta llegó, pero no tiene el formato esperado.
final class RespuestaInvalida extends FallaRed {
  const RespuestaInvalida();
}
