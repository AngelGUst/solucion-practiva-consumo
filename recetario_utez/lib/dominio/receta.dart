/// Reglas de negocio del recetario, en Dart puro.
library;

/// Una receta se considera rápida si su tiempo total es a lo más este valor.
const umbralRapidaMinutos = 30;

/// Dificultad declarada por el servicio, traducida al español.
enum Dificultad {
  facil('Fácil'),
  media('Media'),
  dificil('Difícil'),
  desconocida('Sin dato');

  const Dificultad(this.etiqueta);

  final String etiqueta;
}

/// Una receta ya validada, lista para mostrarse.
class Receta {
  const Receta({
    required this.id,
    required this.nombre,
    required this.cocina,
    required this.dificultad,
    required this.minutosPreparacion,
    required this.minutosCoccion,
    required this.porciones,
    required this.calificacion,
    this.etiquetas = const [],
    this.ingredientes = const [],
  });

  final int id;
  final String nombre;
  final String cocina;
  final Dificultad dificultad;
  final int minutosPreparacion;
  final int minutosCoccion;
  final int porciones;
  final double calificacion;
  final List<String> etiquetas;
  final List<String> ingredientes;

  int get tiempoTotal => minutosPreparacion + minutosCoccion;

  bool get esRapida => tiempoTotal <= umbralRapidaMinutos;
}

/// Una página de resultados junto con el total que reporta el servidor.
class PaginaRecetas {
  const PaginaRecetas({required this.recetas, required this.total});

  final List<Receta> recetas;
  final int total;
}
