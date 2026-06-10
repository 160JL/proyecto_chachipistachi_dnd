// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Asistente DnD';

  @override
  String get mainMenu => 'MENÚ PRINCIPAL';

  @override
  String get battleSimulation => 'Simulación de batalla';

  @override
  String get initiativeTracker => 'Iniciativa (Tracker)';

  @override
  String get createNewCreature => 'Crear Criatura Nueva';

  @override
  String get consultBestiary => 'Consultar Bestiario (API)';

  @override
  String get mySavedCreatures => 'Mis Criaturas Guardadas';

  @override
  String get changelogTitle => 'Registro de Cambios (Changelog)';

  @override
  String get version => 'Versión';

  @override
  String get close => 'CERRAR';

  @override
  String get preparation => 'Preparación';

  @override
  String get round => 'Ronda';

  @override
  String get start => 'INICIAR';

  @override
  String get rollDice => 'Lanzar Dados';

  @override
  String get configureBoard => 'Configurar Tablero';

  @override
  String get addCreature => 'Añadir Criatura';

  @override
  String get nextTurn => 'Siguiente Turno';

  @override
  String turnOf(String name) {
    return 'TURNO DE: $name';
  }

  @override
  String get movement => 'MOVIMIENTO:';

  @override
  String get cells => 'casillas';

  @override
  String get redoMovement => 'Rehacer movimiento';

  @override
  String get actions => 'ACCIONES:';

  @override
  String get reactions => 'REACCIONES:';

  @override
  String get legendaryActions => 'ACCIONES LEGENDARIAS:';

  @override
  String get quantity => 'Cantidad:';

  @override
  String get roll => 'Tirada:';

  @override
  String get results => 'Resultados:';

  @override
  String get total => 'Total:';

  @override
  String get boardSize => 'Tamaño del Tablero';

  @override
  String get grid => 'Cuadrícula:';

  @override
  String get gridAutoAdjust =>
      'El tamaño de las casillas se ajustará automáticamente.';

  @override
  String get cancel => 'CANCELAR';

  @override
  String get save => 'GUARDAR';

  @override
  String get addToCombat => 'Añadir al combate';

  @override
  String get emptyQueueMessage =>
      'La cola de batalla está vacía. Añade criaturas desde el Bestiario o Mis Criaturas primero.';

  @override
  String get battleQueue => 'COLA DE BATALLA';

  @override
  String get clearQueue => 'LIMPIAR COLA';

  @override
  String get noName => 'Sin nombre';

  @override
  String get hitPoints => 'PUNTOS DE VIDA';

  @override
  String get initiative => 'Iniciativa';

  @override
  String get removeFromBattle => 'Eliminar de la batalla';

  @override
  String get localRepository => 'Repositorio Local';

  @override
  String get bestiaryApi => 'Bestiario API';

  @override
  String get updateBestiary => 'Actualizar Bestiario';

  @override
  String get updateBestiaryMessage =>
      '¿Deseas actualizar la lista o reconstruir el registro de habilidades?';

  @override
  String get onlyList => 'Solo lista';

  @override
  String get everything => 'Todo';

  @override
  String get update => 'Actualizar';

  @override
  String get searchByName => 'Buscar por nombre...';

  @override
  String get clear => 'LIMPIAR';

  @override
  String get advancedFilters => 'Filtros Avanzados';

  @override
  String get type => 'Tipo';

  @override
  String get size => 'Tamaño';

  @override
  String get alignment => 'Alineamiento';

  @override
  String get cr => 'CR';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get vulnerabilities => 'Vulnerabilidades';

  @override
  String get resistances => 'Resistencias';

  @override
  String get immunities => 'Inmunidades';

  @override
  String get applyFilters => 'APLICAR FILTROS';

  @override
  String get nameAsc => 'Nombre (A-Z)';

  @override
  String get nameDesc => 'Nombre (Z-A)';

  @override
  String get crAsc => 'CR (Bajo-Alto)';

  @override
  String get crDesc => 'CR (Alto-Bajo)';

  @override
  String get loading => 'Cargando...';

  @override
  String get noCreaturesFound => 'No se encontraron criaturas.';

  @override
  String get buildingRegistry => 'Construyendo Registro de Habilidades';

  @override
  String get syncingBestiary =>
      'Sincronizando el bestiario local. Este proceso solo ocurre una vez.';

  @override
  String creaturesProcessed(int current, int total) {
    return '$current / $total criaturas procesadas';
  }

  @override
  String get all => 'Todos';

  @override
  String get image => 'Imagen';

  @override
  String get imageUrlOrPath => 'URL de imagen o ruta local';

  @override
  String get gallery => 'GALERÍA';

  @override
  String get basicData => 'Datos Básicos';

  @override
  String get name => 'Nombre';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get hp => 'HP';

  @override
  String get acValue => 'AC (Valor)';

  @override
  String get acType => 'Tipo de AC (ej: natural, armor)';

  @override
  String get hitDice => 'Hit Dice';

  @override
  String get hpRoll => 'HP Roll';

  @override
  String get speed => 'Velocidad';

  @override
  String get walk => 'Walk';

  @override
  String get fly => 'Fly';

  @override
  String get swim => 'Swim';

  @override
  String get attributes => 'Atributos';

  @override
  String get str => 'Fuerza (STR)';

  @override
  String get dex => 'Destreza (DEX)';

  @override
  String get con => 'Constitución (CON)';

  @override
  String get intel => 'Inteligencia (INT)';

  @override
  String get wis => 'Sabiduría (WIS)';

  @override
  String get cha => 'Carisma (CHA)';

  @override
  String get challengeAndXp => 'Desafío y XP';

  @override
  String get profBonus => 'Prof. Bonus';

  @override
  String get senses => 'Sentidos';

  @override
  String get blindsight => 'Blindsight';

  @override
  String get darkvision => 'Darkvision';

  @override
  String get tremorsense => 'Tremorsense';

  @override
  String get truesight => 'Truesight';

  @override
  String get passivePerception => 'Passive Perception';

  @override
  String get other => 'Otros';

  @override
  String get languages => 'Idiomas';

  @override
  String get specialAbilities => 'Habilidades Especiales';

  @override
  String get saveCreature => 'GUARDAR CRIATURA';

  @override
  String get importFromJson => 'Importar desde JSON';

  @override
  String get jsonHint => 'Pega el JSON completo de la criatura aquí';

  @override
  String get import => 'Importar';

  @override
  String jsonError(String error) {
    return 'Error en el formato JSON: $error';
  }

  @override
  String get creatureUpdated => 'Criatura actualizada con éxito';

  @override
  String get creatureSaved => 'Criatura guardada con éxito';

  @override
  String editCreature(String name) {
    return 'Editar: $name';
  }

  @override
  String useAsBase(String name) {
    return 'Usar como base: $name';
  }

  @override
  String get random => 'Aleatorio';

  @override
  String get importJson => 'Importar Json';

  @override
  String get add => 'AÑADIR';

  @override
  String get delete => 'BORRAR';

  @override
  String editItem(String item) {
    return 'Editar $item';
  }

  @override
  String get typeToSeeSuggestions => 'Escribe para ver sugerencias...';

  @override
  String get description => 'Descripción';

  @override
  String get emptyRegistry => 'Registro Vacío';

  @override
  String get emptyRegistryMessage =>
      'No hay habilidades guardadas en el registro local. Es necesario consultar criaturas del bestiario (API) para llenar el registro antes de poder generar una criatura aleatoria.';

  @override
  String get goToApi => 'Ir a la API';

  @override
  String get randomGenerator => 'Generador Aleatorio';

  @override
  String get targetCr => 'CR Objetivo';

  @override
  String get generate => 'Generar';

  @override
  String randomCreatureGenerated(num cr) {
    return 'Generada criatura aleatoria CR $cr';
  }

  @override
  String get combatManagement => 'Gestión de Combates';

  @override
  String get newCombat => 'Nuevo Combate';

  @override
  String get noSavedCombats => 'No hay combates guardados';

  @override
  String get newCombatUpper => 'NUEVO COMBATE';

  @override
  String lastChange(String date) {
    return 'Último cambio: $date';
  }

  @override
  String participantsCount(int count) {
    return 'Participantes: $count';
  }

  @override
  String roundCount(int round) {
    return 'Ronda: $round';
  }

  @override
  String get deleteCombat => 'Eliminar Combate';

  @override
  String confirmDeleteCombat(String name) {
    return '¿Estás seguro de que quieres eliminar \'$name\'?';
  }

  @override
  String get deleteUpper => 'ELIMINAR';

  @override
  String get creature => 'Criatura';

  @override
  String get deleteParticipant => 'Eliminar Participante';

  @override
  String confirmDeleteParticipant(String name) {
    return '¿Estás seguro de que quieres eliminar a $name del combate?';
  }

  @override
  String get addPlayer => 'Añadir Jugador';

  @override
  String get initiativeBonus => 'Bono Iniciativa';

  @override
  String editInitiative(String name) {
    return 'Editar Iniciativa - $name';
  }

  @override
  String get initiativeValue => 'Valor de iniciativa';

  @override
  String hpManagement(String name) {
    return 'Gestión de Vida - $name';
  }

  @override
  String get currentHp => 'Vida Actual';

  @override
  String get tempHp => 'Vida Temporal';

  @override
  String get combatName => 'Nombre del Combate';

  @override
  String get preparationUpper => 'PREPARACIÓN';

  @override
  String get addCreatures => 'Añadir Criaturas';

  @override
  String get addPlayers => 'Añadir Jugadores';

  @override
  String get rollMonsters => 'INI. MONSTRUOS';

  @override
  String get rollPlayers => 'INI. JUGADORES';

  @override
  String get startCombat => 'EMPEZAR COMBATE';

  @override
  String roundUpper(int round) {
    return 'RONDA $round';
  }

  @override
  String get nextTurnUpper => 'SIGUIENTE TURNO';

  @override
  String get endCombat => 'TERMINAR COMBATE';

  @override
  String get player => 'JUGADOR';

  @override
  String get addFromQueue => 'Añadir desde la Cola';

  @override
  String get emptyQueueBestiary =>
      'La cola de batalla está vacía. Añade criaturas desde el Bestiario.';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get email => 'Correo Electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get signIn => 'ENTRAR';

  @override
  String get signUp => 'REGISTRARSE';

  @override
  String get loginError => 'Error al iniciar sesión';

  @override
  String get noAccount => '¿No tienes cuenta? Regístrate';

  @override
  String get haveAccount => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String welcome(Object name) {
    return 'Bienvenido, $name';
  }

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get sharePublicly => 'Compartir públicamente';

  @override
  String get publicBestiary => 'Bestiario Público';

  @override
  String sharedBy(String name) {
    return 'Compartido por: $name';
  }

  @override
  String get download => 'DESCARGAR';

  @override
  String get creatureShared => 'Criatura compartida en el Bestiario Público';

  @override
  String creatureAddedToBattle(String name) {
    return '$name añadido a batalla';
  }

  @override
  String get alreadyShared => 'Esta criatura ya es pública';

  @override
  String get noPublicCreatures => 'No hay criaturas compartidas todavía';

  @override
  String get keepLoggedIn => 'Mantener la sesión iniciada';

  @override
  String get signInAsGuest => 'ACCEDER COMO INVITADO';

  @override
  String get saveToMyBestiary => 'Añadir a mis criaturas';

  @override
  String get initiativeBonusLabel => 'Bono Ini';

  @override
  String get adSpace => 'ESPACIO PARA PUBLICIDAD';

  @override
  String get statBlockLabel => 'Ficha de estadísticas D&D 5e';

  @override
  String get exportJson => 'Exportar como JSON';

  @override
  String get exportPng => 'Exportar como PNG';

  @override
  String get addToBattle => 'Añadir a Batalla';

  @override
  String get report => 'Reportar';

  @override
  String get reportReason => 'Motivo del reporte';

  @override
  String get reportSuccess => 'Reporte enviado con éxito';

  @override
  String get writeReason => 'Escribe el motivo aquí...';

  @override
  String get accountBlocked => 'CUENTA BLOQUEADA';

  @override
  String get blockedMessage => 'Tu acceso a la aplicación ha sido restringido.';

  @override
  String get blockReasonLabel => 'Motivo del bloqueo:';

  @override
  String get noReasonProvided => 'No se ha proporcionado un motivo específico.';

  @override
  String get contactAdmin =>
      'Si crees que esto es un error, contacta con soporte.';
}
