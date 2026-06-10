class ChangelogEntry {
  final String version;
  final String date;
  final List<String> changes;

  const ChangelogEntry({
    required this.version,
    required this.date,
    required this.changes,
  });
}

const List<ChangelogEntry> appChangelogES = [
  ChangelogEntry(
    version: "0.9.0",
    date: "2026-05-19",
    changes: [
      "Mejora del Registro de Habilidades: proceso persistente y obligatorio (no se puede cerrar hasta finalizar).",
      "Soporte Multi-usuario: detección automática de cambio de cuenta y actualización inteligente de habilidades locales.",
      "Sincronización total: las habilidades de criaturas creadas o descargadas del Bestiario Público se añaden automáticamente al registro local.",
      "Regeneración Dual: el proceso de reconstrucción ahora procesa tanto la API oficial como tu Repositorio Local.",
      "Gestión de estado mejorada: el registro solo se considera válido al completarse al 100%.",
      "Filtros automáticos en el Bestiario: la lista se actualiza instantáneamente al cambiar cualquier criterio.",
      "Sistema de reportes: los usuarios pueden informar de contenido inapropiado con notificaciones por correo al administrador.",
      "Sistema de seguridad y bloqueos: gestión de acceso restringido a usuarios con visualización del motivo del bloqueo.",
      "Optimización del inicio de sesión automático mediante persistencia nativa de Firebase.",
      "Pequeños ajustes de diseño en el Gestor de Iniciativa para mejorar la adaptabilidad.",
    ],
  ),
  ChangelogEntry(
    version: "0.8.0",
    date: "2026-05-18",
    changes: [
      "Sistema de autenticación mediante Firebase (soporte para Email/Contraseña y Google Sign-In).",
      "Nuevo Bestiario Público de la comunidad impulsado por Firestore para compartir criaturas.",
      "Incorporación de anuncios de Google AdMob (Banner en el Dashboard).",
      "Sincronización del estado VIP del usuario con Firebase Firestore.",
      "Rediseño completo del Simulador de Batalla con menú lateral (Drawer) y barra de información de turno.",
      "Nuevo sistema de búsqueda de criaturas unificado que combina la cola de batalla y el bestiario.",
      "Añadido modo 'Acceder como invitado' para uso local sin necesidad de cuenta Firebase.",
      "Opción de 'Mantener sesión iniciada' con persistencia mediante almacenamiento local.",
      "Visualización del Bono de Iniciativa en el gestor de iniciativa.",
      "Posibilidad de guardar criaturas directamente en el repositorio local desde el Bestiario Público.",
      "Refactorización del Dashboard en un módulo independiente y limpieza de código en main.dart.",
      "Internacionalización completa (Español/Inglés) de todas las nuevas funcionalidades.",
    ],
  ),
  ChangelogEntry(
    version: "0.5.0",
    date: "2026-05-16",
    changes: [
      "Cambio de nombre de la aplicación a 'Asistente DnD' / 'DnD Companion'.",
      "Localización de idioma (añadida traducción a inglés).",
      "Sincronización automática de versión con el Changelog.",
    ],
  ),
  ChangelogEntry(
    version: "0.3.1",
    date: "2026-05-15",
    changes: [
      "Resolución de Advertencias",
    ],
  ),
  ChangelogEntry(
    version: "0.3.0",
    date: "2026-05-15",
    changes: [
      "Cambio de nombre oficial a 'Compañero DnD'.",
      "Añadido número de versión en la pantalla principal.",
      "Corregido error 'saveFile() not implemented' al exportar en navegadores web.",
      "Mejorada la previsualización de imágenes en la versión web.",
      "Añadido este registro de cambios (Changelog).",
      "Optimizaciones menores para el lanzamiento de producción.",
    ],
  ),
  ChangelogEntry(
    version: "0.1.0",
    date: "2026-05-14",
    changes: [
      "Lanzamiento inicial del proyecto.",
      "Generador de criaturas aleatorias basado en CR.",
      "Integración con D&D 5e API.",
      "Repositorio local de criaturas con persistencia.",
      "Simulador de batalla y tracker de iniciativa.",
      "Exportación de fichas en formato JSON e imagen PNG.",
    ],
  ),
];

const List<ChangelogEntry> appChangelogEN = [
  ChangelogEntry(
    version: "0.9.0",
    date: "2026-05-19",
    changes: [
      "Skill Registry Improvements: persistent and mandatory process (cannot be closed until finished).",
      "Multi-user Support: automatic account change detection and smart local skill updates.",
      "Full Synchronization: skills from created or downloaded community creatures are automatically added to the local registry.",
      "Dual Regeneration: the reconstruction process now processes both the official API and your Local Repository.",
      "Improved state management: the registry is only considered valid when 100% complete.",
      "Automatic filtering in Bestiary: the list updates instantly when any criteria change.",
      "Reporting system: users can report inappropriate content with email notifications to the administrator.",
      "Security and blocking system: restricted access management for users with block reason display.",
      "Optimized automatic login using native Firebase persistence.",
      "Minor design adjustments in the Initiative Tracker for better adaptability.",
    ],
  ),
  ChangelogEntry(
    version: "0.8.0",
    date: "2026-05-18",
    changes: [
      "Firebase Authentication system (support for Email/Password and Google Sign-In).",
      "New Community Public Bestiary powered by Firestore for sharing creatures.",
      "Integration of Google AdMob ads (Banner on the Dashboard).",
      "Synchronization of user VIP status with Firebase Firestore.",
      "Complete redesign of the Battle Simulator with a side drawer and turn info bar.",
      "New unified creature search system combining battle queue and bestiary search.",
      "Added 'Sign in as Guest' mode for local use without a Firebase account.",
      "'Keep me logged in' option with session persistence using local storage.",
      "Display of Initiative Bonus in the initiative tracker participant cards.",
      "Ability to save community creatures directly to the local repository from the Public Bestiary.",
      "Dashboard refactored into an independent module and main.dart cleanup.",
      "Full internationalization (Spanish/English) of all new features.",
    ],
  ),
  ChangelogEntry(
    version: "0.5.0",
    date: "2026-05-16",
    changes: [
      "App renamed to 'Asistente DnD' / 'DnD Companion'.",
      "Language localization (added English translation).",
      "Automatic version synchronization with the Changelog.",
    ],
  ),
  ChangelogEntry(
    version: "0.3.1",
    date: "2026-05-15",
    changes: [
      "Warning resolution.",
    ],
  ),
  ChangelogEntry(
    version: "0.3.0",
    date: "2026-05-15",
    changes: [
      "Official name changed to 'Compañero DnD'.",
      "Added version number on the main screen.",
      "Fixed 'saveFile() not implemented' error when exporting in web browsers.",
      "Improved image preview in the web version.",
      "Added this changelog.",
      "Minor optimizations for production release.",
    ],
  ),
  ChangelogEntry(
    version: "0.1.0",
    date: "2026-05-14",
    changes: [
      "Initial project release.",
      "Random creature generator based on CR.",
      "Integration with D&D 5e API.",
      "Local creature repository with persistence.",
      "Battle simulator and initiative tracker.",
      "Export cards in JSON and PNG image format.",
    ],
  ),
];
