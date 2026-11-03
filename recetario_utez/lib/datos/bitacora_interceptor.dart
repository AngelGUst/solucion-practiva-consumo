import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Registra cada petición, respuesta y error sin exponer lo que la persona
/// escribió: solo método, ruta, código y tiempo.
class BitacoraInterceptor extends Interceptor {
  BitacoraInterceptor({void Function(String linea)? escribir})
    : _escribir = escribir ?? _escribirEnConsola;

  final void Function(String linea) _escribir;

  static const _claveReloj = 'bitacora_reloj';

  static void _escribirEnConsola(String linea) {
    developer.log(linea, name: 'recetario');
  }

  static int _milisegundos(RequestOptions opciones) {
    final reloj = opciones.extra[_claveReloj];
    if (reloj is Stopwatch) return reloj.elapsedMilliseconds;
    return 0;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_claveReloj] = Stopwatch()..start();
    _escribir('→ ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final opciones = response.requestOptions;
    final codigo = response.statusCode ?? 0;
    _escribir(
      '← $codigo ${opciones.method} ${opciones.path} '
      '(${_milisegundos(opciones)} ms)',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final opciones = err.requestOptions;
    final codigo = err.response?.statusCode;
    final detalleCodigo = codigo == null ? '' : ' $codigo';
    _escribir(
      '✗ ${err.type.name}$detalleCodigo ${opciones.method} ${opciones.path} '
      '(${_milisegundos(opciones)} ms)',
    );
    handler.next(err);
  }
}
