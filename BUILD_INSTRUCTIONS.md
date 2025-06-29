# Instrucciones para compilar y desplegar FIT Agent

Este documento describe el proceso para compilar y desplegar correctamente la aplicación FIT Agent en dispositivos Android, resolviendo los problemas detectados con imágenes y generación de recetas.

## Requisitos previos

- Flutter SDK instalado y actualizado
- Android SDK instalado
- Un dispositivo Android físico o emulador
- API Key de OpenRouter (para la generación de recetas con IA)

## Preparación del entorno

1. Asegúrate de tener Flutter actualizado:

```bash
flutter upgrade
flutter doctor
```

2. Verifica que todas las dependencias estén correctamente instaladas:

```bash
flutter pub get
```

## Configuración de la API Key

Existen dos formas de configurar la API Key para la generación de recetas:

### Opción 1: Usando un archivo .env

1. Crea un archivo `.env` en la raíz del proyecto con este contenido:
```
OPENROUTER_API_KEY=tu_api_key_aquí
```

2. Este archivo es incluido automáticamente durante la compilación gracias a la configuración en `pubspec.yaml`.

### Opción 2: Usando el almacenamiento seguro desde la aplicación

1. En la primera ejecución de la app, se te pedirá que ingreses la API Key.
2. Esta se guardará de forma segura en el almacenamiento encriptado del dispositivo.

## Compilación para desarrollo

Para compilar y ejecutar la app en modo debug:

```bash
flutter run
```

## Compilación para producción (APK)

Para generar una APK optimizada para distribución:

```bash
# Limpia la compilación anterior
flutter clean

# Obtiene dependencias actualizadas
flutter pub get

# Genera APK en modo release
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

# Para generar APKs específicas por arquitectura (más pequeñas)
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols
```

La APK generada se encontrará en:
- APK única: `build/app/outputs/flutter-apk/app-release.apk`
- APKs por arquitectura: 
  - `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
  - `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
  - `build/app/outputs/flutter-apk/app-x86_64-release.apk`

## Compilación para App Bundle (Google Play)

Para distribución en Google Play:

```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

El bundle generado estará en: `build/app/outputs/bundle/release/app-release.aab`

## Solución de problemas comunes

### Imágenes no visibles en la APK instalada

Este problema ha sido resuelto con:
- Implementación de caché de imágenes con `cached_network_image`
- Uso de imágenes de respaldo locales en `/assets/images/`
- Añadido permisos de Internet en `AndroidManifest.xml`

### Generación de recetas fallando

Este problema ha sido resuelto con:
- Implementación de modo offline para recetas
- Almacenamiento seguro de la API key
- Manejo robusto de errores y reintentos en las llamadas a la API
- Migración de SharedPreferences a SQLite para datos persistentes

## Verificación post-instalación

Después de instalar la APK en un dispositivo, verifica:

1. Que las imágenes de recetas se cargan correctamente
2. Que la app funciona incluso sin conexión a internet
3. Que se pueden generar nuevas recetas usando la API
4. Que las recetas y datos de usuario se guardan correctamente

## Notas adicionales

- Se recomiendan dispositivos con Android 6.0 (API 23) o superior
- La app está optimizada para un rendimiento eficiente
- Las imágenes se almacenan en caché para minimizar el uso de datos
