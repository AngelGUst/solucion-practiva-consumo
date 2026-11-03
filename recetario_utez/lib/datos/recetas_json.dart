import 'package:recetario_utez/dominio/receta.dart';

/// Traduce la dificultad que manda el servicio. Nunca lanza: lo desconocido
/// se representa como [Dificultad.desconocida].
Dificultad dificultadDesdeTexto(Object? valor) {
  return switch (valor) {
    'Easy' => Dificultad.facil,
    'Medium' => Dificultad.media,
    'Hard' => Dificultad.dificil,
    _ => Dificultad.desconocida,
  };
}

/// Convierte un objeto JSON en una [Receta].
///
/// Los campos obligatorios deben venir con el tipo correcto; si no,
/// se lanza [FormatException]. Las listas son opcionales y se toleran
/// ausentes, pero si vienen deben ser listas de textos.
Receta recetaDesdeJson(Map<String, dynamic> json) {
  switch (json) {
    case {
      'id': int id,
      'name': String nombre,
      'cuisine': String cocina,
      'prepTimeMinutes': int minutosPreparacion,
      'cookTimeMinutes': int minutosCoccion,
      'servings': int porciones,
      'rating': num calificacion,
    }:
      return Receta(
        id: id,
        nombre: nombre,
        cocina: cocina,
        dificultad: dificultadDesdeTexto(json['difficulty']),
        minutosPreparacion: minutosPreparacion,
        minutosCoccion: minutosCoccion,
        porciones: porciones,
        calificacion: calificacion.toDouble(),
        etiquetas: _listaDeTextos(json['tags'], 'tags'),
        ingredientes: _listaDeTextos(json['ingredients'], 'ingredients'),
      );
    default:
      throw const FormatException(
        'La receta no tiene los campos obligatorios esperados.',
      );
  }
}

/// Convierte la respuesta de la API en una [PaginaRecetas].
///
/// Una lista vacía es válida; que falte una llave o que un elemento no sea
/// un objeto es un error de formato.
PaginaRecetas paginaDesdeJson(Map<String, dynamic> json) {
  switch (json) {
    case {'recipes': List<dynamic> elementos, 'total': int total}:
      final recetas = <Receta>[];
      for (final elemento in elementos) {
        if (elemento is! Map<String, dynamic>) {
          throw const FormatException(
            'Cada receta debe llegar como un objeto JSON.',
          );
        }
        recetas.add(recetaDesdeJson(elemento));
      }
      return PaginaRecetas(recetas: recetas, total: total);
    default:
      throw const FormatException(
        'La página no tiene los campos "recipes" y "total" esperados.',
      );
  }
}

/// Lee una lista opcional de textos. Ausente o nula equivale a lista vacía.
List<String> _listaDeTextos(Object? valor, String campo) {
  if (valor == null) return const [];
  if (valor is! List) {
    throw FormatException('El campo "$campo" debe ser una lista.');
  }
  final textos = <String>[];
  for (final elemento in valor) {
    if (elemento is! String) {
      throw FormatException('El campo "$campo" debe contener solo textos.');
    }
    textos.add(elemento);
  }
  return textos;
}
