# Guía de Contribución - Fit Agent

¡Gracias por tu interés en contribuir a Fit Agent! Esta guía te ayudará a configurar el entorno de desarrollo y entender cómo contribuir al proyecto.

## Tabla de Contenidos
1. [Configuración del Entorno](#configuración-del-entorno)
2. [Estructura del Proyecto](#estructura-del-proyecto)
3. [Metodología Scrum](#metodología-scrum)
4. [Sprints y Tareas](#sprints-y-tareas)
5. [Convenciones de Código](#convenciones-de-código)
6. [Pruebas](#pruebas)
7. [Envío de Cambios](#envío-de-cambios)

## Configuración del Entorno

### Requisitos Previos
- Flutter SDK (versión estable más reciente)
- Dart SDK (incluido con Flutter)
- Un editor de código (VS Code o Android Studio recomendados)
- Git

### Pasos de Configuración

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/tu-usuario/fit_agent.git
   cd fit_agent
   ```

2. **Obtener dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar variables de entorno**
   - Copiar `.env.example` a `.env`
   - Configurar las claves de API necesarias en `.env`
   - **IMPORTANTE**: Nunca subas el archivo `.env` al repositorio

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## Estructura del Proyecto

```
lib/
├── main.dart              # Punto de entrada de la aplicación
├── models/                # Modelos de datos
│   ├── user.dart
│   ├── recipe.dart
│   └── ...
├── screens/              # Pantallas de la aplicación
│   ├── home_screen.dart
│   ├── recipe_screen.dart
│   └── ...
├── services/             # Servicios y lógica de negocio
│   ├── ai_recipe_service.dart
│   └── ...
├── widgets/              # Componentes reutilizables
│   ├── custom_bottom_navigation.dart
│   └── ...
└── themes/               # Temas y estilos
    └── app_theme.dart
```

## Metodología Scrum

### Roles
- **Product Owner**: Define las características y prioridades
- **Scrum Master**: Facilita el proceso de desarrollo
- **Equipo de Desarrollo**: Desarrolladores, diseñadores, QA

### Artefactos
- **Product Backlog**: Lista priorizada de características
- **Sprint Backlog**: Tareas para el sprint actual
- **Incremento**: Versión funcional al final de cada sprint

### Eventos
- **Sprint Planning**: Planificación del sprint (2 horas/semana)
- **Daily Standup**: Reunión diaria (15 minutos)
- **Sprint Review**: Demostración del trabajo completado (1 hora/semana)
- **Sprint Retrospective**: Mejora del proceso (1 hora/semana)

## Sprints y Tareas

### Sprint 0: Configuración Inicial (1 semana)

**Objetivo**: Configuración del entorno y arquitectura base.

1.  [ ] **Configurar Proyecto Flutter**:
    *   Crear proyecto Flutter base (`flutter create fit_agent`).
    *   Definir y crear la estructura de carpetas inicial dentro de `lib/` (e.g., `models`, `screens`, `services`, `widgets`, `routes`, `themes`).
    *   Configurar gestión de dependencias: añadir dependencias iniciales a `pubspec.yaml` (e.g., `http`, `flutter_dotenv`, `provider` o `riverpod` si se decide el gestor de estado).
    *   Ejecutar `flutter pub get`.
2.  [ ] **Configurar Control de Versiones**:
    *   Inicializar repositorio Git (`git init`).
    *   Configurar `.gitignore` (asegurando que cubra archivos de Flutter, IDE y `.env`).
    *   Crear `README.md` inicial.
    *   Crear este archivo `CONTRIBUTING.md`.
3.  [ ] **Configurar Herramientas de Desarrollo**:
    *   Configurar `analysis_options.yaml` con el linter (`flutter_lints`) y reglas de análisis estático preferidas.
    *   Asegurar que el formateador de Dart (`dart format .`) funcione correctamente.
    *   Configurar la estructura base para pruebas unitarias y de widgets (crear directorios `test/models`, `test/widgets`, etc.).
4.  [ ] **Configurar Variables de Entorno**:
    *   Añadir `flutter_dotenv` a `pubspec.yaml`.
    *   Crear archivo `.env.example` con las variables necesarias (e.g., `OPENROUTER_API_KEY=your_api_key_here`).
    *   Crear archivo `.env` localmente (instruir al equipo para que lo haga).
    *   Asegurar que `.env` esté en `.gitignore`.
    *   Actualizar `main.dart` para cargar las variables de entorno al inicio.
    *   Añadir `.env` (o el nombre que se le dé, como `assets/.env_file`) a la sección `assets` en `pubspec.yaml`.

### Sprint 1: Fundamentos de la Aplicación - Tema, Modelos Base y Rutas (1-2 semanas)

**Objetivo**: Establecer la apariencia visual básica, los modelos de datos esenciales y el sistema de navegación.

1.  [ ] **Definición del Tema de la Aplicación (`themes/app_theme.dart`)**:
    *   Definir la paleta de colores principal (primario, secundario, acento, fondo, texto).
    *   Configurar la tipografía (fuentes, tamaños para títulos, cuerpo, botones).
    *   Crear `ThemeData` personalizado en `app_theme.dart`.
    *   Aplicar el tema global en `MaterialApp` dentro de `main.dart`.
2.  [ ] **Creación de Modelos de Datos Esenciales (`models/`)**:
    *   [ ] `user.dart`: Definir `UserProfile` (e.g., `id`, `name`, `email`, `dietaryPreferences`, `healthGoals`).
    *   [ ] `recipe.dart`: Definir `Recipe` (e.g., `id`, `title`, `ingredients` (lista de `Ingrediente`), `instructions` (lista de strings), `imageUrl`, `calories`, `prepTime`).
    *   [ ] `ingrediente_seleccionado.dart` (o `ingredient.dart`): Definir `Ingrediente` (e.g., `name`, `quantity`, `unit`, `imageUrl`).
    *   [ ] `menu_option.dart`: Definir `MenuOption` para elementos de navegación o listas (e.g., `route`, `icon`, `title`).
3.  [ ] **Configuración del Sistema de Rutas (`routes/`)**:
    *   [ ] `app_routes.dart`: Definir constantes para todas las rutas nombradas de la aplicación (e.g., `static const String home = '/home';`).
    *   [ ] `main_routes.dart` (o un archivo similar): Crear un manejador de rutas (e.g., una función `generateRoute` o un mapa de rutas) que mapee los nombres de ruta a los widgets de pantalla correspondientes.
    *   [ ] Integrar el sistema de rutas en `MaterialApp` (`onGenerateRoute` o `routes`) en `main.dart`.
    *   [ ] Configurar ruta inicial.
4.  [ ] **Punto de Entrada de la Aplicación (`main.dart`)**:
    *   Configurar `MaterialApp` con el tema y el sistema de rutas.
    *   Inicializar servicios globales si los hubiera (como `dotenv`).

### Sprint 2: Componentes Reutilizables (Widgets) y Pantallas Estructurales (2 semanas)

**Objetivo**: Desarrollar widgets comunes y la estructura de las pantallas principales.

1.  [ ] **Desarrollo de Widgets Comunes (`widgets/`)**:
    *   [ ] `custom_bottom_navigation.dart`: Crear el widget de barra de navegación inferior (UI y manejo de tabs/estado inicial).
    *   [ ] `seleccion_ingredientes.dart`: Diseñar la UI para la selección de ingredientes (e.g., cuadrícula o lista de ingredientes con checkboxes o botones de +/-).
    *   [ ] `ingredientes_seleccionados.dart`: Diseñar la UI para mostrar la lista de ingredientes actualmente seleccionados.
    *   [ ] Crear otros widgets genéricos identificados (e.g., `CustomAppBar`, `RecipeCardPreview`).
2.  [ ] **Creación de Pantallas Esqueleto (`screens/`)**:
    *   [ ] `home_screen.dart`: Estructura básica, integrar `CustomBottomNavigation` (si aplica aquí) y placeholders para `SeleccionIngredientes` e `IngredientesSeleccionados`.
    *   [ ] `recipe_screen.dart`: Placeholder para mostrar una receta detallada.
    *   [ ] `profile_screen.dart`: Placeholder para el perfil del usuario.
    *   [ ] `favorites_screen.dart`: Placeholder para recetas favoritas.
    *   [ ] `history_screen.dart`: Placeholder para historial de recetas.
    *   [ ] `preferences_screen.dart`: Placeholder para las preferencias del usuario.
    *   [ ] `saved_recipes_screen.dart`: Placeholder para recetas guardadas (si es distinto de favoritas).
    *   [ ] Crear `screens.dart` como un archivo barril para exportar todas las pantallas.
3.  [ ] **Navegación Básica**:
    *   Implementar la navegación entre las pantallas esqueleto usando el `CustomBottomNavigation` y otras acciones de UI (e.g., botones temporales).

### Sprint 3: Lógica de Usuario y Servicios Iniciales (2 semanas)

**Objetivo**: Implementar la gestión de datos del usuario y sus preferencias.

1.  [ ] **Servicio de Usuario (`services/user_service.dart`)**:
    *   Definir la interfaz del servicio.
    *   Implementar funciones para cargar y guardar `UserProfile` (inicialmente puede ser mockeado o usar `shared_preferences`).
    *   Implementar funciones para cargar y guardar las preferencias del usuario.
2.  [ ] **Integración del Servicio de Usuario en Pantallas**:
    *   [ ] `profile_screen.dart`: Conectar con `UserService` para mostrar datos del perfil y permitir su edición.
    *   [ ] `preferences_screen.dart`: Conectar con `UserService` para mostrar y modificar las preferencias (dietéticas, etc.).
3.  [ ] **Manejo de Estado para Datos de Usuario**:
    *   Implementar el gestor de estado elegido (Provider, Riverpod, BLoC) para manejar los datos del `UserProfile` y las preferencias globalmente o donde sea necesario.

### Sprint 4: Funcionalidad Principal - Selección de Ingredientes y Generación de Recetas (3 semanas)

**Objetivo**: Implementar la selección interactiva de ingredientes y la integración con la IA para generar recetas.

1.  [ ] **Lógica Interactiva de Selección de Ingredientes**:
    *   En `seleccion_ingredientes.dart`:
        *   Obtener la lista de ingredientes disponibles (puede ser mockeada inicialmente o desde un servicio simple).
        *   Implementar la lógica para añadir/quitar ingredientes de la lista de `IngredientesSeleccionados`.
    *   En `ingredientes_seleccionados.dart`:
        *   Mostrar dinámicamente los ingredientes seleccionados y permitir su remoción o ajuste de cantidad.
    *   Conectar el estado de los ingredientes seleccionados a `home_screen.dart`.
2.  [ ] **Servicio de Generación de Recetas con IA (`services/ai_recipe_service.dart`)**:
    *   Definir la interfaz del servicio.
    *   Implementar la función `generarReceta(List<Ingrediente> ingredientes, UserProfile usuario)`:
        *   Construir el prompt para la API de IA, incluyendo ingredientes y preferencias del usuario.
        *   Realizar la llamada HTTP a la API de OpenRouter (usar `apiKey` de `.env`).
        *   Parsear la respuesta JSON y transformarla en un objeto `Recipe`.
        *   Implementar manejo de errores (networking, API errors) y estados de carga.
3.  [ ] **Flujo de Generación de Recetas**:
    *   En `home_screen.dart`:
        *   Añadir un botón "Generar Receta".
        *   Al pulsar, obtener la lista de `IngredientesSeleccionados` y el `UserProfile`.
        *   Llamar a `ai_recipe_service.dart` para obtener la receta.
        *   Mostrar un indicador de carga durante la generación.
        *   Al recibir la receta, navegar a `recipe_screen.dart` pasando el objeto `Recipe`.
4.  [ ] **Visualización de Receta (`screens/recipe_screen.dart`)**:
    *   Recibir el objeto `Recipe` como argumento.
    *   Mostrar todos los detalles de la receta: título, imagen (si la API la provee o se usa una genérica), ingredientes, instrucciones detalladas, información nutricional (si se incluye).

### Sprint 5: Almacenamiento y Gestión de Recetas (2 semanas)

**Objetivo**: Permitir a los usuarios guardar, ver y gestionar las recetas generadas.

1.  [ ] **Servicio de Almacenamiento de Recetas (`services/recipe_storage_service.dart`)**:
    *   Definir la interfaz del servicio.
    *   Implementar funciones para:
        *   Guardar una receta (e.g., marcar como favorita, añadir al historial).
        *   Obtener recetas favoritas.
        *   Obtener historial de recetas.
        *   Eliminar una receta guardada.
    *   Utilizar almacenamiento local (`shared_preferences` para listas simples o `sqflite` para datos más estructurados).
2.  [ ] **Integración del Almacenamiento en Pantallas**:
    *   [ ] `recipe_screen.dart`: Añadir botones/íconos para "Guardar como Favorita" o "Añadir al Historial", que llamen a `RecipeStorageService`.
    *   [ ] `favorites_screen.dart`: Cargar y mostrar la lista de recetas favoritas desde `RecipeStorageService`. Permitir ver detalle o eliminar de favoritos.
    *   [ ] `history_screen.dart`: Cargar y mostrar el historial de recetas generadas desde `RecipeStorageService`. Permitir ver detalle.
    *   [ ] `saved_recipes_screen.dart` (si es una funcionalidad separada): Implementar su lógica de carga y visualización.

### Sprint 6: Refinamiento, Pruebas Exhaustivas y Documentación Final (2 semanas)

**Objetivo**: Pulir la aplicación, asegurar su calidad mediante pruebas y completar toda la documentación.

1.  [ ] **Pruebas Unitarias y de Widgets**:
    *   Escribir pruebas unitarias para todos los modelos (validaciones, transformaciones).
    *   Escribir pruebas unitarias para la lógica de los servicios (mocks para dependencias externas como HTTP).
    *   Escribir pruebas de widgets para los componentes reutilizables clave y pantallas simples.
2.  [ ] **Pruebas de Integración**:
    *   Crear pruebas de integración para los flujos principales:
        *   Selección de ingredientes -> Generación de receta -> Visualización.
        *   Guardar receta -> Ver en Favoritos/Historial.
        *   Actualización de perfil/preferencias y su reflejo.
3.  [ ] **Refinamiento de UI/UX**:
    *   Realizar una revisión completa de la interfaz de usuario y la experiencia del usuario.
    *   Añadir animaciones sutiles, transiciones y feedback visual donde mejore la experiencia.
    *   Asegurar la consistencia del diseño en toda la aplicación (según `app_theme.dart`).
    *   Probar en diferentes tamaños de pantalla y orientaciones.
4.  [ ] **Manejo Robusto de Estados de Error y Carga**:
    *   Verificar que todas las operaciones asíncronas (llamadas a API, acceso a almacenamiento) muestren indicadores de carga claros.
    *   Asegurar que los errores se manejen de forma elegante, mostrando mensajes útiles al usuario.
5.  [ ] **Documentación del Código**:
    *   Añadir comentarios DartDoc a todas las clases públicas, métodos y propiedades complejas.
6.  [ ] **Actualización de Documentación del Proyecto**:
    *   Revisar y actualizar `README.md` con la descripción final del proyecto, características, capturas de pantalla (si es posible) e instrucciones de ejecución.
    *   Revisar y finalizar `CONTRIBUTING.md`.
7.  [ ] **Optimización del Rendimiento**:
    *   Utilizar Flutter DevTools para perfilar la aplicación.
    *   Identificar y solucionar cuellos de botella en el rendimiento de la UI o la lógica.
    *   Optimizar la carga de imágenes y otros assets.
8.  [ ] **Revisión Final y Preparación para "Entrega" (simulada)**:
    *   Realizar pruebas de aceptación del usuario (UAT) internas del equipo.
    *   Corregir los últimos bugs encontrados.

## Convenciones de Código

### Estilo de Código
- Seguir las [guías de estilo de Flutter](https://dart.dev/guides/language/effective-dart/style)
- Usar nombres descriptivos en inglés
- Documentar funciones y clases públicas

### Estructura de Commits
```
tipo(ámbito): descripción breve

Descripción detallada si es necesario

[OPCIONAL: Cierra #issue]
```

**Tipos de commit**:
- feat: Nueva característica
- fix: Corrección de errores
- docs: Cambios en la documentación
- style: Cambios de formato (puntos y comas, sangría, etc.)
- refactor: Cambios en el código que no corrigen errores ni agregan características
- test: Agregar o corregir pruebas
- chore: Cambios en el proceso de compilación o herramientas auxiliares

## Pruebas

### Tipos de Pruebas
- **Unitarias**: Pruebas de funciones individuales
- **Widget**: Pruebas de componentes de la interfaz
- **Integración**: Pruebas de flujos completos

### Ejecutar Pruebas
```bash
# Todas las pruebas
flutter test

# Pruebas específicas
flutter test test/nombre_del_archivo_test.dart

# Generar cobertura
flutter test --coverage
```

## Envío de Cambios

1. Crear una rama para la característica/corrección:
   ```bash
   git checkout -b feature/nombre-de-la-caracteristica
   ```

2. Hacer commit de los cambios:
   ```bash
   git add .
   git commit -m "tipo(ámbito): descripción breve"
   ```

3. Subir los cambios:
   ```bash
   git push origin feature/nombre-de-la-caracteristica
   ```

4. Crear un Pull Request (PR) en GitHub
   - Describir los cambios realizados
   - Mencionar las issues relacionadas
   - Solicitar revisión a los compañeros

5. Resolver comentarios y aprobaciones
   - Hacer los cambios solicitados
   - Volver a subir los cambios
   - Esperar la aprobación del PR

6. Mergear los cambios
   - Hacer squash y merge
   - Eliminar la rama si ya no es necesaria

¡Gracias por contribuir a Fit Agent! 🚀
