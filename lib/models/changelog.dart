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
