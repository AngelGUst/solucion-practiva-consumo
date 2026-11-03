import 'package:dio/dio.dart';

import 'bitacora_interceptor.dart';

/// Raíz del servicio público de recetas.
const urlDummyJson = 'https://dummyjson.com';

/// Crea el cliente HTTP de la app con HTTPS, tiempos de espera prudentes y
/// la bitácora de desarrollo.
Dio crearDioRecetas({List<Interceptor> interceptores = const []}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: urlDummyJson,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(BitacoraInterceptor());
  dio.interceptors.addAll(interceptores);

  return dio;
}
