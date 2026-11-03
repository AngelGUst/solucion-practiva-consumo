import '../dominio/receta.dart';

/// Contrato que la presentación conoce para pedir recetas.
abstract class RecetasRepositorio {
  Future<PaginaRecetas> buscar({String texto = ''});
}
