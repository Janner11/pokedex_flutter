# Pokédex App con Flutter y GraphQL

Esta es una aplicación móvil multiplataforma, desarrollada con Flutter, que funciona como una Pokédex interactiva y moderna. El proyecto no solo consume datos de una API pública, sino que también integra una arquitectura robusta, manejo de estado avanzado, persistencia local para una experiencia offline, y elementos de gamificación.

## Características Principales

- **Lista de Pokémon:** Scroll infinito con carga perezosa (`Lazy Loading`).
- **Búsqueda con Debounce:** Búsqueda eficiente que evita llamadas innecesarias a la API.
- **Modo Offline:** La aplicación guarda la última lista de Pokémon cargada y las imágenes vistas, permitiendo su consulta sin conexión a internet.
- **Pantalla de Detalle Completa:** Muestra información exhaustiva de cada Pokémon, incluyendo:
    - **Stats Base:** Visualizados con un gráfico de radar y una lista detallada con el total.
    - **Debilidades y Resistencias:** Cálculo y visualización de los *matchups* de tipo (x2, x0.5, x0, etc.).
    - **Evoluciones:** Muestra el árbol de evolución completo, incluyendo ramas y las condiciones específicas (nivel, amistad, objeto, etc.).
    - **Movimientos:** Lista completa con filtros por método de aprendizaje, selector de juego y paginación local.
    - **Variantes y Shiny:** Permite cambiar entre formas (Alola, Galar, etc.) y visualizar la versión shiny.
- **Sistema de Favoritos:** Persistencia local usando **Hive**, con modo offline y actualización en tiempo real en la UI.
- **Trivia "¿Quién es este Pokémon?":** Minijuego offline con sistema de puntuación, tiempo límite, ranking local y logros desbloqueables.
- **Mapa de Regiones:** Muestra la región de origen del Pokémon en un mapa interactivo.
- **Internacionalización (i18n):** Soporte para Español e Inglés en la sección de Trivia, con posibilidad de expansión.
- **Tema Oscuro y Claro:** Tema dual con persistencia de la preferencia del usuario.
- **Diseño UI/UX Moderno:** Basado en Material 3, con animaciones `Hero`, microinteracciones y un diseño responsivo.

---

## Arquitectura y Decisiones de Diseño

La aplicación sigue los principios de **Arquitectura Limpia**, dividiendo el código en tres capas principales para asegurar la separación de responsabilidades y la mantenibilidad.

1.  **`presentation/`**: Contiene todos los widgets de Flutter (pantallas, componentes, etc.). Es la capa de la UI y no contiene lógica de negocio. Su única responsabilidad es mostrar los datos y capturar la interacción del usuario.

2.  **`domain/`**: Es el núcleo de la aplicación. Contiene los **modelos** de datos (ej: la clase `Pokemon`). Esta capa no depende de ninguna otra y define las entidades y reglas de negocio. Aquí es donde se realiza la "traducción" de los datos crudos de la API a objetos limpios y estructurados.

3.  **`data/`**: Contiene los **repositorios**, que son los encargados de obtener los datos, ya sea de una fuente remota (API) o local (base de datos).

### Uso de GraphQL

La comunicación con la [PokeAPI](https://pokeapi.co/docs/graphql) se gestiona exclusivamente a través de su endpoint de GraphQL. Para esto, utilizamos el paquete `graphql_flutter`.

- **Cliente GraphQL (`graphql_client.dart`):** Se configura un cliente centralizado que apunta a la API y, muy importante, utiliza `GraphQLCache(store: InMemoryStore())` para implementar una caché en memoria de primer nivel.

- **Declarative Data Fetching:** En lugar de hacer llamadas manuales, usamos el widget `Query`. Este se encarga del ciclo de vida completo de una petición:
    - Muestra un `CircularProgressIndicator` mientras `result.isLoading` es `true`.
    - Muestra un `ErrorView` con opción de reintento si `result.hasException` es `true`.
    - Provee los datos al `builder` cuando la petición es exitosa.

- **Paginación (`fetchMore`):** En la lista principal, el scroll infinito se logra con la función `fetchMore` del `Query`, que ejecuta la misma consulta pero con un `offset` actualizado, y luego combina los resultados antiguos y nuevos.

- **Estrategias de Caché (`FetchPolicy`):**
    - **`cacheAndNetwork`:** Usada en la lista y el detalle. Muestra datos de la caché al instante para una carga rápida, pero siempre busca datos frescos en la red para mantener la app actualizada. Esto fue clave para solucionar el bug de los movimientos de Tutor/Huevo.
    - **`cacheFirst`:** (Comportamiento por defecto). Ideal para datos que no cambian. Si los datos están en caché, los usa; si no, los pide a la red.

### Persistencia Local y Modo Offline con Hive

Hive se utiliza como nuestra base de datos local NoSQL por su velocidad y simplicidad.

- **Favoritos Offline:** `FavoritesRepository` gestiona dos "cajas": una para los IDs (para búsquedas rápidas) y otra para los detalles (`favorite_details`). Al marcar un favorito, se guarda un mapa con los datos esenciales del Pokémon, incluyendo su **imagen convertida a Base64**. La pantalla de favoritos lee exclusivamente de esta caja, garantizando su funcionamiento 100% offline.

- **Último Listado Visto:** De manera similar, `PokemonListScreen` guarda en la caja `pokemon_list_cache` la última lista de Pokémon cargada, incluyendo las imágenes en Base64, para poder mostrarla si la app se inicia sin conexión.

- **Trivia y Temas:** Se usan cajas adicionales para persistir los puntajes del ranking, los logros desbloqueados y la preferencia del modo oscuro del usuario.

### Características Adicionales Implementadas

- **Modo Oscuro:** Se implementó con un `ThemeProvider` (usando `ChangeNotifier`) que escucha los cambios y reconstruye `MaterialApp` con el tema (`appThemeLight` o `appThemeDark`). La preferencia se guarda en Hive.

- **Compartir como Imagen:** La pantalla de detalle usa los paquetes `screenshot` y `share_plus`. Se envuelve una sección visual en un widget `Screenshot`. Al pulsar "Compartir", se captura el widget, se guarda como una imagen temporal en el dispositivo y se abre el diálogo nativo para compartirla.

- **Internacionalización (i18n):** Se implementó un sistema de localización manual en `lib/l10n/` que permite a la Trivia (y potencialmente a toda la app) mostrar textos en Español e Inglés según la configuración del dispositivo.
