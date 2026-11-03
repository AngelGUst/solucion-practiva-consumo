import '../dominio/falla_red.dart';

/// Texto para cualquier error que la app no supo clasificar.
const mensajeInesperado = 'Algo salió mal. Intenta de nuevo.';

/// Traduce una falla de red a un mensaje claro para la persona.
String mensajePara(FallaRed falla) {
  return switch (falla) {
    SinConexion() =>
      'Sin conexión. Revisa tu red e intenta de nuevo.',
    TiempoAgotado() =>
      'El recetario tardó demasiado en responder. Intenta de nuevo.',
    ErrorDelServidor(:final codigo) =>
      'El recetario no está disponible ($codigo). Intenta más tarde.',
    PeticionRechazada() =>
      'No pudimos hacer esa búsqueda. Avisa al equipo de desarrollo.',
    RespuestaInvalida() =>
      'Las recetas llegaron con un formato inesperado.',
  };
}
