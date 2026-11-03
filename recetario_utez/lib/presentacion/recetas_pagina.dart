import 'package:flutter/material.dart';

import 'recetas_view_model.dart';
import 'tarjeta_receta.dart';

/// Pantalla principal del recetario.
class RecetasPagina extends StatefulWidget {
  const RecetasPagina({super.key, required this.vm});

  final RecetasViewModel vm;

  @override
  State<RecetasPagina> createState() => _RecetasPaginaState();
}

class _RecetasPaginaState extends State<RecetasPagina> {
  final _controlador = TextEditingController();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _buscar() => widget.vm.buscar(_controlador.text);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetario UTEZ'),
      ),
      body: ListenableBuilder(
        listenable: widget.vm,
        builder: (context, _) {
          final vm = widget.vm;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const Key('busqueda'),
                  controller: _controlador,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _buscar(),
                  decoration: const InputDecoration(
                    labelText: '¿Qué receta buscas?',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: const Key('buscar'),
                  onPressed: vm.cargando ? null : _buscar,
                  child: const Text('Buscar recetas'),
                ),
                const SizedBox(height: 16),
                Expanded(child: _contenido(vm)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _contenido(RecetasViewModel vm) {
    return switch (vm.estado) {
      RecetasInicial() => const _Mensaje(
        icono: Icons.menu_book_outlined,
        texto: 'Escribe una receta o déjalo vacío y toca Buscar recetas.',
      ),
      RecetasCargando() => const Center(
        child: CircularProgressIndicator(),
      ),
      RecetasVacias(:final busqueda) => _Mensaje(
        icono: Icons.search_off,
        texto: busqueda.isEmpty
            ? 'No hay recetas disponibles.'
            : 'No encontramos recetas para "$busqueda".',
      ),
      RecetasFallidas(:final mensaje) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            Text(
              mensaje,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: vm.reintentar,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      RecetasListas(:final recetas, :final total) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mostrando ${recetas.length} de $total recetas · '
            'Rápidas: ${vm.rapidas}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: recetas.length,
              itemBuilder: (context, indice) =>
                  TarjetaReceta(receta: recetas[indice]),
            ),
          ),
        ],
      ),
    };
  }
}

class _Mensaje extends StatelessWidget {
  const _Mensaje({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 40),
          const SizedBox(height: 12),
          Text(
            texto,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
