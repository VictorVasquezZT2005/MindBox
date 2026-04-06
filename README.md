# MindBox

A modern, minimalist, and AI-powered note-taking and management application built with Flutter.

## Características Principales

- **Gestión de Notas:** Crea y edita notas con soporte para Markdown.
- **Asistente IA (Gemini 2.5 Flash):** Resumen de texto, corrección gramatical y expansión de ideas.
- **Seguridad:** Gestión de contraseñas y recordatorios sincronizados.
- **Multiplataforma:** Optimizado para móvil, tablet y escritorio.
- **Diseño Minimalista:** Temas claro y oscuro personalizables.

## Configuración de la IA (Gemini) - SEGURA

Para que tu aplicación sea segura al desplegarla (especialmente en la web), **no escribas tu clave en el código**. En su lugar, inyéctala al compilar:

1. **Obtén tu clave de API:** Ve a [Google AI Studio](https://aistudio.google.com/app/apikey).
2. **Uso en Desarrollo:**
   ```bash
   flutter run --dart-define=GEMINI_API_KEY=tu_clave_real_aqui
   ```
3. **Uso en Despliegue (Web):**
   ```bash
   flutter build web --dart-define=GEMINI_API_KEY=tu_clave_real_aqui
   ```

> **Importante:** Si usas una plataforma de CI/CD (GitHub Actions, Vercel, Firebase), añade `GEMINI_API_KEY` como una variable de entorno en su panel de configuración.

## Primeros Pasos

1. Asegúrate de tener Flutter instalado (`flutter doctor`).
2. Instala las dependencias: `flutter pub get`.
3. Ejecuta la aplicación: `flutter run`.

## Recursos Adicionales

- [Documentación oficial de Flutter](https://docs.flutter.dev/)
- [Gemini API Docs](https://ai.google.dev/docs)
- [Riverpod Documentation](https://riverpod.dev/)
