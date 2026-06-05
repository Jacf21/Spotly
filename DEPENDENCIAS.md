# DEPENDENCIAS Y LIBRERÍAS DEL PROYECTO SPOTLY

El proyecto Spotly utiliza un conjunto de librerías y paquetes de Flutter y Dart que facilitan el desarrollo, mejoran la productividad del equipo y garantizan la calidad del software. Estas dependencias permiten implementar funcionalidades complejas de manera eficiente, reduciendo tiempos de desarrollo y manteniendo una arquitectura organizada y escalable.

## Core y fundamentos

Las tecnologías base utilizadas en el proyecto proporcionan la estructura principal para el desarrollo de la aplicación móvil.

- Flutter SDK 3.16+: Framework de desarrollo multiplataforma. Base completa de la aplicación móvil.
- Dart SDK 3.0+: Lenguaje de programación de Flutter. Desarrollo de toda la lógica y la interfaz del sistema.
- supabase_flutter ^2.12.0: Cliente oficial de Supabase para Flutter. Gestión de autenticación, base de datos, almacenamiento y servicios en tiempo real.
- flutter_dotenv ^6.0.0: Gestión de variables de entorno. Protección de credenciales y configuraciones sensibles.

## Arquitectura y manejo de estado

Estas librerías permiten organizar la lógica de negocio y gestionar el flujo de información dentro de la aplicación.

- flutter_bloc ^8.1.6: Implementación del patrón BLoC. Gestión de estados en autenticación, perfiles y administración.
- equatable ^2.0.7: Comparación simplificada de objetos. Optimización de eventos y estados dentro de BLoC.
- dartz ^0.10.1: Programación funcional. Manejo seguro de errores y resultados.
- get_it ^7.7.0: Inyección de dependencias. Centralización de servicios y repositorios.
- provider ^6.1.5+1: Gestión de estado ligera. Utilizado principalmente para AuthProvider.

## Interfaz de usuario, animaciones y diseño

Estas herramientas fueron utilizadas para construir una interfaz moderna, consistente y visualmente atractiva.

- flex_color_scheme ^7.3.1: Gestión avanzada de temas. Personalización de colores y modo oscuro.
- google_fonts ^6.2.1: Fuentes tipográficas de Google. Mejora de la apariencia visual del sistema.
- lucide_icons ^0.257.0: Biblioteca de iconos modernos. Uso general en toda la interfaz.
- font_awesome_flutter ^10.7.0: Colección de iconos FontAwesome. Integración de iconos especializados.
- flutter_animate ^4.5.0: Animaciones declarativas. Transiciones y efectos visuales.
- rive ^0.13.0: Animaciones vectoriales interactivas. Estados de carga y elementos gráficos.
- glass_kit 4.0.2: Efectos glassmorphism. Tarjetas y componentes visuales modernos.
- flutter_custom_clippers ^2.1.0: Recortes personalizados. Fondos y elementos decorativos.

## Multimedia y manejo de archivos

Las siguientes librerías permiten gestionar imágenes y contenido multimedia dentro de la aplicación.

- image_picker ^1.1.0: Selección de imágenes. Captura y selección desde cámara o galería.
- cached_network_image ^3.3.1: Caché de imágenes remotas. Optimización de carga en publicaciones y perfiles.
- story_view ^0.16.5: Visualización de historias. Implementación de historias temporales.
- path ^1.9.0: Manipulación de rutas de archivos. Gestión de archivos temporales e imágenes.

## Navegación, mapas y geolocalización

Estas dependencias permiten la navegación interna de la aplicación y la integración de funcionalidades basadas en ubicación.

- go_router ^13.2.0: Sistema de navegación declarativa. Gestión de rutas y pantallas.
- flutter_map ^8.3.0: Mapas interactivos. Visualización de lugares turísticos y rutas.
- flutter_map_cancellable_tile_provider ^3.1.0: Optimización de mapas. Reducción de consumo de datos durante la navegación.
- geolocator ^14.0.1: Obtención de ubicación GPS. Georreferenciación y localización del usuario.
- geocoding ^3.0.0: Conversión de coordenadas. Traducción entre coordenadas y direcciones.
- latlong2 ^0.9.1: Operaciones geográficas. Cálculo de distancias y ubicaciones.
- http ^1.2.1: Cliente HTTP. Consumo de servicios externos.
- url_launcher ^6.2.5: Apertura de enlaces externos. Integración con navegadores y aplicaciones externas.

## Utilidades y funcionalidades específicas

Estas librerías complementan funcionalidades particulares del sistema.

- intl ^0.19.0: Internacionalización. Formato de fechas, números y configuraciones regionales.
- timeago ^3.7.1: Fechas relativas. Visualización de tiempos transcurridos.
- emoji_picker_flutter ^4.4.0: Selector de emojis. Inclusión de emojis en comentarios y publicaciones.
- share_plus 12.0.2: Compartir contenido. Envío de contenido a aplicaciones externas.

## Desarrollo y pruebas

Estas herramientas apoyan las actividades de desarrollo, mantenimiento y aseguramiento de la calidad del software.

- flutter_lints ^3.0.0: Reglas de calidad de código. Aplicación de buenas prácticas de desarrollo.
- build_runner ^2.4.9: Generación automática de código. Soporte para procesos automatizados y serialización.
- flutter_launcher_icons ^0.14.1: Generación de iconos. Creación automática de iconos para las plataformas soportadas.

## Gestión de dependencias y control de versiones

El proyecto utiliza herramientas especializadas para la administración de dependencias y el control de versiones del código fuente.

- pubspec.yaml: Declaración y configuración de dependencias, recursos y paquetes del proyecto.
- pubspec.lock: Control de versiones exactas de las dependencias instaladas.
- Git: Sistema de control de versiones distribuido.
- GitHub: Plataforma de colaboración y alojamiento del repositorio del proyecto.

## Resumen cuantitativo del ecosistema tecnológico

Total de librerías utilizadas: 36

Categorías:
- Core y fundamentos: 4
- Arquitectura y manejo de estado: 5
- Interfaz de usuario, animaciones y diseño: 8
- Multimedia y manejo de archivos: 4
- Navegación, mapas y geolocalización: 8
- Utilidades y funcionalidades específicas: 4
- Desarrollo y pruebas: 3

## Conclusión de la sección

La selección de tecnologías utilizada en Spotly fue realizada considerando criterios de estabilidad, documentación disponible, soporte de la comunidad y compatibilidad con Flutter y Supabase. Gracias a esta combinación de herramientas, fue posible desarrollar una aplicación escalable, mantenible y con una experiencia de usuario adecuada para los requerimientos del proyecto.

Asimismo, las dependencias seleccionadas facilitaron la implementación de funcionalidades complejas, permitieron mantener una arquitectura organizada y favorecieron el trabajo colaborativo mediante el uso de herramientas de control de versiones y gestión de dependencias.