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

const List<ChangelogEntry> appChangelog = [
  ChangelogEntry(
    version: "1.0.2",
    date: "2026-05-15",
    changes: [
      "Resolución de Advertencias",
    ],
  ),
  ChangelogEntry(
    version: "1.0.1",
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
    version: "1.0.0",
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
