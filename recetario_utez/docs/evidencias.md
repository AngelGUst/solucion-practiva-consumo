# Evidencias — Recetario UTEZ

**Nombre:** _Completa con tu nombre_
**Matrícula:** _Completa con tu matrícula_
**Fecha:** 3 de noviembre de 2026
**Dispositivo donde se probó:** Chrome 156 en Windows 10 (build web de Flutter)

## 1. Del JSON a Dart

| JSON | Campo Dart | Tipo | Regla (obligatorio, tolerado, valor por defecto) |
|---|---|---|---|
| `id` | `id` | `int` | Obligatorio. Si falta o no es entero → `FormatException`. |
| `name` | `nombre` | `String` | Obligatorio. Si falta o no es texto → `FormatException`. |
| `cuisine` | `cocina` | `String` | Obligatorio. Si falta o no es texto → `FormatException`. |
| `difficulty` | `dificultad` | `Dificultad` | Tolerado. `Easy`→`facil`, `Medium`→`media`, `Hard`→`dificil`; cualquier otro valor, `null` o un número → `desconocida` (nunca lanza). |
| `prepTimeMinutes` | `minutosPreparacion` | `int` | Obligatorio. Si falta o no es entero → `FormatException`. |
| `cookTimeMinutes` | `minutosCoccion` | `int` | Obligatorio. Si falta o no es entero → `FormatException`. |
| `servings` | `porciones` | `int` | Obligatorio. Si falta o no es entero → `FormatException`. |
| `rating` | `calificacion` | `double` | Obligatorio. Se acepta `num` (entero o decimal) y siempre se guarda como `double` con `.toDouble()`. |
| `tags` | `etiquetas` | `List<String>` | Opcional. Ausente o `null` → lista vacía. Si no es lista o trae un elemento que no es texto → `FormatException`. |
| `ingredients` | `ingredientes` | `List<String>` | Opcional. Ausente o `null` → lista vacía. Si no es lista o trae un elemento que no es texto → `FormatException`. |

Los demás campos de DummyJSON (`instructions`, `image`, `caloriesPerServing`, `userId`, `reviewCount`, `mealType`, etc.) se ignoran.

## 2. Escenarios probados con el servicio real

| Escenario | Cómo lo provoqué | Qué vio la persona | Línea de la bitácora | Captura | Prueba del kit que lo cubre |
|---|---|---|---|---|---|
| Éxito | Escribí `chicken` y toqué **Buscar recetas** contra `GET /recipes/search`. | El encabezado «Mostrando 8 de 8 recetas · Rápidas: 1» y ocho tarjetas con nombre, cocina, dificultad, tiempo, porciones y calificación. | `→ GET /recipes/search`<br>`← 200 GET /recipes/search (1159 ms)` | `docs/capturas/01_exito.png` | `etapa3_datos_test.dart`: «200 → PaginaRecetas»; `etapa5_vistas_test.dart`: «texto + botón → indicador y botón apagado → tarjetas». |
| Vacío | Escribí `zzzz` y toqué **Buscar recetas**. El servicio respondió `200` con `"recipes": []`. | El mensaje «No encontramos recetas para "zzzz".» (sin botón de reintentar, porque no es un error). | `→ GET /recipes/search`<br>`← 200 GET /recipes/search (364 ms)` | `docs/capturas/02_vacio.png` | `etapa3_datos_test.dart`: «200 sin resultados → página vacía»; `etapa5_vistas_test.dart`: «vacío con texto dice qué se buscó; sin texto, otro mensaje». |
| Error del servidor | Cambio temporal A: un interceptor cambió `o.path` a `/http/503`, ruta de DummyJSON que responde 503 de verdad. | «El recetario no está disponible (503). Intenta más tarde.» y el botón **Reintentar**. | `→ GET /recipes/search`<br>`✗ badResponse 503 GET /http/503 (361 ms)` | `docs/capturas/03_error_servidor.png` | `etapa3_datos_test.dart`: «503 → ErrorDelServidor(503)»; `etapa4_viewmodel_test.dart`: «FallaRed → Fallidas con el mensaje de mensajePara». |
| Sin red | Cambio temporal C: un interceptor cambió `o.baseUrl` a `https://recetario.invalid` (dominio inexistente), equivalente a quedarse sin conexión. | «Sin conexión. Revisa tu red e intenta de nuevo.» y el botón **Reintentar**. | `→ GET /recipes/search`<br>`✗ connectionError GET /recipes/search (21 ms)` | `docs/capturas/04_sin_red.png` | `etapa3_datos_test.dart`: «sin red → SinConexion»; `etapa4_viewmodel_test.dart`: «mensajePara: un texto claro por falla». |
| Tiempo agotado | Cambio temporal B: un interceptor agregó `delay: 5000` a la query y bajó `connectTimeout` y `receiveTimeout` a 2 s. | «El recetario tardó demasiado en responder. Intenta de nuevo.» y el botón **Reintentar**. | `→ GET /recipes/search`<br>`✗ receiveTimeout GET /recipes/search (2149 ms)` | `docs/capturas/05_tiempo_agotado.png` | `etapa3_datos_test.dart`: «connectTimeout → TiempoAgotado» y «receiveTimeout → TiempoAgotado»; `etapa4_viewmodel_test.dart`: mensaje de `TiempoAgotado`. |

> Los cambios temporales A, B y C se quitaron al terminar. `lib/main.dart` quedó con la versión de la etapa 5 y `verificar_recetario.sh` confirma que no hay `delay`, `/http/...` ni `.invalid` en `lib/`.
>
> Captura adicional del estado inicial: `docs/capturas/00_inicial.png`.

## 3. Preguntas de reflexión

1. **¿En qué se diferencian el escenario «Error del servidor» y «Sin red» desde el punto de vista de HTTP?**
   En el error del servidor sí hubo una transacción HTTP completa: el cliente resolvió el dominio, abrió la conexión, envió el `GET` y el servidor contestó con una respuesta válida cuyo código fue `503`. En «Sin red» no existe respuesta HTTP: la conexión ni siquiera se establece (falla DNS/TCP), así que Dio lo reporta como `connectionError` y no como `badResponse`. Para la persona, el primero significa «el servicio está caído, intenta más tarde»; el segundo, «tu red no llegó al servicio».

2. **¿Por qué «Vacío» no es un error?**
   Porque el servicio respondió `200 OK` con un JSON válido y `"recipes": []`. La petición se completó correctamente; simplemente no había coincidencias. Por eso se representa con el estado `RecetasVacias` y un mensaje que recuerda qué se buscó, no con `RecetasFallidas` ni con un botón de reintentar.

3. **La búsqueda de la persona viaja en la query. ¿Por qué tu bitácora no la escribe?**
   Porque la bitácora solo registra método, ruta (`options.path`), código y tiempo. La ruta es `/recipes/search`, mientras que el texto buscado y `limit` viven en `queryParameters`. Omitirlos evita filtrar en los logs lo que la persona escribe (podría ser información personal) y mantiene la bitácora segura; además, las pruebas verifican que `enchiladas` no aparezca en las líneas.

4. **Si DummyJSON cambiara `rating` por `score`, ¿qué archivos tendrías que modificar y por qué solo esos?**
   Solo `lib/datos/recetas_json.dart`, en el patrón de `recetaDesdeJson` (cambiar la llave `'rating'` por `'score'`). El dominio (`Receta.calificacion`) y la presentación (`TarjetaReceta`) trabajan con el campo tipado, no con el nombre del JSON, así que no cambian. En un proyecto real también se actualizaría la tabla de esta evidencia; el kit de pruebas no se toca.
