import 'package:flutter/foundation.dart';

import '../datos/recetas_repositorio.dart';
import '../dominio/falla_red.dart';
import '../dominio/receta.dart';
import 'mensajes.dart';

/// Los estados posibles de la pantalla. Son excluyentes: solo uno está activo.
sealed class EstadoRecetas {
  const EstadoRecetas();
}

final class RecetasInicial extends EstadoRecetas {
  const RecetasInicial();
}

final class RecetasCargando extends EstadoRecetas {
  const RecetasCargando();
}

final class RecetasListas extends EstadoRecetas {
  const RecetasListas(this.recetas, this.total);

  final List<Receta> recetas;
  final int total;
}

final class RecetasVacias extends EstadoRecetas {
  const RecetasVacias(this.busqueda);

  final String busqueda;
}

final class RecetasFallidas extends EstadoRecetas {
  const RecetasFallidas(this.mensaje);

  final String mensaje;
}

/// Coordina las búsquedas y expone el estado a la pantalla.
class RecetasViewModel extends ChangeNotifier {
  RecetasViewModel(this._repositorio);

  final RecetasRepositorio _repositorio;

  EstadoRecetas _estado = const RecetasInicial();
  String _ultimaBusqueda = '';
  bool _desechado = false;

  EstadoRecetas get estado => _estado;

  bool get cargando => _estado is RecetasCargando;

  String get ultimaBusqueda => _ultimaBusqueda;

  int get rapidas => switch (_estado) {
    RecetasListas(:final recetas) =>
      recetas.where((receta) => receta.esRapida).length,
    _ => 0,
  };

  Future<void> buscar(String texto) async {
    if (cargando) return;

    final limpio = texto.trim();
    _ultimaBusqueda = limpio;

    _estado = const RecetasCargando();
    notifyListeners();

    try {
      final pagina = await _repositorio.buscar(texto: limpio);
      if (_desechado) return;

      _estado = pagina.recetas.isEmpty
          ? RecetasVacias(limpio)
          : RecetasListas(pagina.recetas, pagina.total);
    } on FallaRed catch (falla) {
      if (_desechado) return;
      _estado = RecetasFallidas(mensajePara(falla));
    } catch (_) {
      if (_desechado) return;
      _estado = RecetasFallidas(mensajeInesperado);
    }

    if (!_desechado) notifyListeners();
  }

  Future<void> reintentar() => buscar(_ultimaBusqueda);

  @override
  void dispose() {
    _desechado = true;
    super.dispose();
  }
}
