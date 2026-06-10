import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Asistente DnD'**
  String get appTitle;

  /// No description provided for @mainMenu.
  ///
  /// In es, this message translates to:
  /// **'MENÚ PRINCIPAL'**
  String get mainMenu;

  /// No description provided for @battleSimulation.
  ///
  /// In es, this message translates to:
  /// **'Simulación de batalla'**
  String get battleSimulation;

  /// No description provided for @initiativeTracker.
  ///
  /// In es, this message translates to:
  /// **'Iniciativa (Tracker)'**
  String get initiativeTracker;

  /// No description provided for @createNewCreature.
  ///
  /// In es, this message translates to:
  /// **'Crear Criatura Nueva'**
  String get createNewCreature;

  /// No description provided for @consultBestiary.
  ///
  /// In es, this message translates to:
  /// **'Consultar Bestiario (API)'**
  String get consultBestiary;

  /// No description provided for @mySavedCreatures.
  ///
  /// In es, this message translates to:
  /// **'Mis Criaturas Guardadas'**
  String get mySavedCreatures;

  /// No description provided for @changelogTitle.
  ///
  /// In es, this message translates to:
  /// **'Registro de Cambios (Changelog)'**
  String get changelogTitle;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get version;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'CERRAR'**
  String get close;

  /// No description provided for @preparation.
  ///
  /// In es, this message translates to:
  /// **'Preparación'**
  String get preparation;

  /// No description provided for @round.
  ///
  /// In es, this message translates to:
  /// **'Ronda'**
  String get round;

  /// No description provided for @start.
  ///
  /// In es, this message translates to:
  /// **'INICIAR'**
  String get start;

  /// No description provided for @rollDice.
  ///
  /// In es, this message translates to:
  /// **'Lanzar Dados'**
  String get rollDice;

  /// No description provided for @configureBoard.
  ///
  /// In es, this message translates to:
  /// **'Configurar Tablero'**
  String get configureBoard;

  /// No description provided for @addCreature.
  ///
  /// In es, this message translates to:
  /// **'Añadir Criatura'**
  String get addCreature;

  /// No description provided for @nextTurn.
  ///
  /// In es, this message translates to:
  /// **'Siguiente Turno'**
  String get nextTurn;

  /// No description provided for @turnOf.
  ///
  /// In es, this message translates to:
  /// **'TURNO DE: {name}'**
  String turnOf(String name);

  /// No description provided for @movement.
  ///
  /// In es, this message translates to:
  /// **'MOVIMIENTO:'**
  String get movement;

  /// No description provided for @cells.
  ///
  /// In es, this message translates to:
  /// **'casillas'**
  String get cells;

  /// No description provided for @redoMovement.
  ///
  /// In es, this message translates to:
  /// **'Rehacer movimiento'**
  String get redoMovement;

  /// No description provided for @actions.
  ///
  /// In es, this message translates to:
  /// **'ACCIONES:'**
  String get actions;

  /// No description provided for @reactions.
  ///
  /// In es, this message translates to:
  /// **'REACCIONES:'**
  String get reactions;

  /// No description provided for @legendaryActions.
  ///
  /// In es, this message translates to:
  /// **'ACCIONES LEGENDARIAS:'**
  String get legendaryActions;

  /// No description provided for @quantity.
  ///
  /// In es, this message translates to:
  /// **'Cantidad:'**
  String get quantity;

  /// No description provided for @roll.
  ///
  /// In es, this message translates to:
  /// **'Tirada:'**
  String get roll;

  /// No description provided for @results.
  ///
  /// In es, this message translates to:
  /// **'Resultados:'**
  String get results;

  /// No description provided for @total.
  ///
  /// In es, this message translates to:
  /// **'Total:'**
  String get total;

  /// No description provided for @boardSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño del Tablero'**
  String get boardSize;

  /// No description provided for @grid.
  ///
  /// In es, this message translates to:
  /// **'Cuadrícula:'**
  String get grid;

  /// No description provided for @gridAutoAdjust.
  ///
  /// In es, this message translates to:
  /// **'El tamaño de las casillas se ajustará automáticamente.'**
  String get gridAutoAdjust;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'CANCELAR'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'GUARDAR'**
  String get save;

  /// No description provided for @addToCombat.
  ///
  /// In es, this message translates to:
  /// **'Añadir al combate'**
  String get addToCombat;

  /// No description provided for @emptyQueueMessage.
  ///
  /// In es, this message translates to:
  /// **'La cola de batalla está vacía. Añade criaturas desde el Bestiario o Mis Criaturas primero.'**
  String get emptyQueueMessage;

  /// No description provided for @battleQueue.
  ///
  /// In es, this message translates to:
  /// **'COLA DE BATALLA'**
  String get battleQueue;

  /// No description provided for @clearQueue.
  ///
  /// In es, this message translates to:
  /// **'LIMPIAR COLA'**
  String get clearQueue;

  /// No description provided for @noName.
  ///
  /// In es, this message translates to:
  /// **'Sin nombre'**
  String get noName;

  /// No description provided for @hitPoints.
  ///
  /// In es, this message translates to:
  /// **'PUNTOS DE VIDA'**
  String get hitPoints;

  /// No description provided for @initiative.
  ///
  /// In es, this message translates to:
  /// **'Iniciativa'**
  String get initiative;

  /// No description provided for @removeFromBattle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar de la batalla'**
  String get removeFromBattle;

  /// No description provided for @localRepository.
  ///
  /// In es, this message translates to:
  /// **'Repositorio Local'**
  String get localRepository;

  /// No description provided for @bestiaryApi.
  ///
  /// In es, this message translates to:
  /// **'Bestiario API'**
  String get bestiaryApi;

  /// No description provided for @updateBestiary.
  ///
  /// In es, this message translates to:
  /// **'Actualizar Bestiario'**
  String get updateBestiary;

  /// No description provided for @updateBestiaryMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Deseas actualizar la lista o reconstruir el registro de habilidades?'**
  String get updateBestiaryMessage;

  /// No description provided for @onlyList.
  ///
  /// In es, this message translates to:
  /// **'Solo lista'**
  String get onlyList;

  /// No description provided for @everything.
  ///
  /// In es, this message translates to:
  /// **'Todo'**
  String get everything;

  /// No description provided for @update.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get update;

  /// No description provided for @searchByName.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre...'**
  String get searchByName;

  /// No description provided for @clear.
  ///
  /// In es, this message translates to:
  /// **'LIMPIAR'**
  String get clear;

  /// No description provided for @advancedFilters.
  ///
  /// In es, this message translates to:
  /// **'Filtros Avanzados'**
  String get advancedFilters;

  /// No description provided for @type.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get type;

  /// No description provided for @size.
  ///
  /// In es, this message translates to:
  /// **'Tamaño'**
  String get size;

  /// No description provided for @alignment.
  ///
  /// In es, this message translates to:
  /// **'Alineamiento'**
  String get alignment;

  /// No description provided for @cr.
  ///
  /// In es, this message translates to:
  /// **'CR'**
  String get cr;

  /// No description provided for @sortBy.
  ///
  /// In es, this message translates to:
  /// **'Ordenar por'**
  String get sortBy;

  /// No description provided for @vulnerabilities.
  ///
  /// In es, this message translates to:
  /// **'Vulnerabilidades'**
  String get vulnerabilities;

  /// No description provided for @resistances.
  ///
  /// In es, this message translates to:
  /// **'Resistencias'**
  String get resistances;

  /// No description provided for @immunities.
  ///
  /// In es, this message translates to:
  /// **'Inmunidades'**
  String get immunities;

  /// No description provided for @applyFilters.
  ///
  /// In es, this message translates to:
  /// **'APLICAR FILTROS'**
  String get applyFilters;

  /// No description provided for @nameAsc.
  ///
  /// In es, this message translates to:
  /// **'Nombre (A-Z)'**
  String get nameAsc;

  /// No description provided for @nameDesc.
  ///
  /// In es, this message translates to:
  /// **'Nombre (Z-A)'**
  String get nameDesc;

  /// No description provided for @crAsc.
  ///
  /// In es, this message translates to:
  /// **'CR (Bajo-Alto)'**
  String get crAsc;

  /// No description provided for @crDesc.
  ///
  /// In es, this message translates to:
  /// **'CR (Alto-Bajo)'**
  String get crDesc;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @noCreaturesFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron criaturas.'**
  String get noCreaturesFound;

  /// No description provided for @buildingRegistry.
  ///
  /// In es, this message translates to:
  /// **'Construyendo Registro de Habilidades'**
  String get buildingRegistry;

  /// No description provided for @syncingBestiary.
  ///
  /// In es, this message translates to:
  /// **'Sincronizando el bestiario local. Este proceso solo ocurre una vez.'**
  String get syncingBestiary;

  /// No description provided for @creaturesProcessed.
  ///
  /// In es, this message translates to:
  /// **'{current} / {total} criaturas procesadas'**
  String creaturesProcessed(int current, int total);

  /// No description provided for @all.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get all;

  /// No description provided for @image.
  ///
  /// In es, this message translates to:
  /// **'Imagen'**
  String get image;

  /// No description provided for @imageUrlOrPath.
  ///
  /// In es, this message translates to:
  /// **'URL de imagen o ruta local'**
  String get imageUrlOrPath;

  /// No description provided for @gallery.
  ///
  /// In es, this message translates to:
  /// **'GALERÍA'**
  String get gallery;

  /// No description provided for @basicData.
  ///
  /// In es, this message translates to:
  /// **'Datos Básicos'**
  String get basicData;

  /// No description provided for @name.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get name;

  /// No description provided for @nameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get nameRequired;

  /// No description provided for @hp.
  ///
  /// In es, this message translates to:
  /// **'HP'**
  String get hp;

  /// No description provided for @acValue.
  ///
  /// In es, this message translates to:
  /// **'AC (Valor)'**
  String get acValue;

  /// No description provided for @acType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de AC (ej: natural, armor)'**
  String get acType;

  /// No description provided for @hitDice.
  ///
  /// In es, this message translates to:
  /// **'Hit Dice'**
  String get hitDice;

  /// No description provided for @hpRoll.
  ///
  /// In es, this message translates to:
  /// **'HP Roll'**
  String get hpRoll;

  /// No description provided for @speed.
  ///
  /// In es, this message translates to:
  /// **'Velocidad'**
  String get speed;

  /// No description provided for @walk.
  ///
  /// In es, this message translates to:
  /// **'Walk'**
  String get walk;

  /// No description provided for @fly.
  ///
  /// In es, this message translates to:
  /// **'Fly'**
  String get fly;

  /// No description provided for @swim.
  ///
  /// In es, this message translates to:
  /// **'Swim'**
  String get swim;

  /// No description provided for @attributes.
  ///
  /// In es, this message translates to:
  /// **'Atributos'**
  String get attributes;

  /// No description provided for @str.
  ///
  /// In es, this message translates to:
  /// **'Fuerza (STR)'**
  String get str;

  /// No description provided for @dex.
  ///
  /// In es, this message translates to:
  /// **'Destreza (DEX)'**
  String get dex;

  /// No description provided for @con.
  ///
  /// In es, this message translates to:
  /// **'Constitución (CON)'**
  String get con;

  /// No description provided for @intel.
  ///
  /// In es, this message translates to:
  /// **'Inteligencia (INT)'**
  String get intel;

  /// No description provided for @wis.
  ///
  /// In es, this message translates to:
  /// **'Sabiduría (WIS)'**
  String get wis;

  /// No description provided for @cha.
  ///
  /// In es, this message translates to:
  /// **'Carisma (CHA)'**
  String get cha;

  /// No description provided for @challengeAndXp.
  ///
  /// In es, this message translates to:
  /// **'Desafío y XP'**
  String get challengeAndXp;

  /// No description provided for @profBonus.
  ///
  /// In es, this message translates to:
  /// **'Prof. Bonus'**
  String get profBonus;

  /// No description provided for @senses.
  ///
  /// In es, this message translates to:
  /// **'Sentidos'**
  String get senses;

  /// No description provided for @blindsight.
  ///
  /// In es, this message translates to:
  /// **'Blindsight'**
  String get blindsight;

  /// No description provided for @darkvision.
  ///
  /// In es, this message translates to:
  /// **'Darkvision'**
  String get darkvision;

  /// No description provided for @tremorsense.
  ///
  /// In es, this message translates to:
  /// **'Tremorsense'**
  String get tremorsense;

  /// No description provided for @truesight.
  ///
  /// In es, this message translates to:
  /// **'Truesight'**
  String get truesight;

  /// No description provided for @passivePerception.
  ///
  /// In es, this message translates to:
  /// **'Passive Perception'**
  String get passivePerception;

  /// No description provided for @other.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get other;

  /// No description provided for @languages.
  ///
  /// In es, this message translates to:
  /// **'Idiomas'**
  String get languages;

  /// No description provided for @specialAbilities.
  ///
  /// In es, this message translates to:
  /// **'Habilidades Especiales'**
  String get specialAbilities;

  /// No description provided for @saveCreature.
  ///
  /// In es, this message translates to:
  /// **'GUARDAR CRIATURA'**
  String get saveCreature;

  /// No description provided for @importFromJson.
  ///
  /// In es, this message translates to:
  /// **'Importar desde JSON'**
  String get importFromJson;

  /// No description provided for @jsonHint.
  ///
  /// In es, this message translates to:
  /// **'Pega el JSON completo de la criatura aquí'**
  String get jsonHint;

  /// No description provided for @import.
  ///
  /// In es, this message translates to:
  /// **'Importar'**
  String get import;

  /// No description provided for @jsonError.
  ///
  /// In es, this message translates to:
  /// **'Error en el formato JSON: {error}'**
  String jsonError(String error);

  /// No description provided for @creatureUpdated.
  ///
  /// In es, this message translates to:
  /// **'Criatura actualizada con éxito'**
  String get creatureUpdated;

  /// No description provided for @creatureSaved.
  ///
  /// In es, this message translates to:
  /// **'Criatura guardada con éxito'**
  String get creatureSaved;

  /// No description provided for @editCreature.
  ///
  /// In es, this message translates to:
  /// **'Editar: {name}'**
  String editCreature(String name);

  /// No description provided for @useAsBase.
  ///
  /// In es, this message translates to:
  /// **'Usar como base: {name}'**
  String useAsBase(String name);

  /// No description provided for @random.
  ///
  /// In es, this message translates to:
  /// **'Aleatorio'**
  String get random;

  /// No description provided for @importJson.
  ///
  /// In es, this message translates to:
  /// **'Importar Json'**
  String get importJson;

  /// No description provided for @add.
  ///
  /// In es, this message translates to:
  /// **'AÑADIR'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'BORRAR'**
  String get delete;

  /// No description provided for @editItem.
  ///
  /// In es, this message translates to:
  /// **'Editar {item}'**
  String editItem(String item);

  /// No description provided for @typeToSeeSuggestions.
  ///
  /// In es, this message translates to:
  /// **'Escribe para ver sugerencias...'**
  String get typeToSeeSuggestions;

  /// No description provided for @description.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get description;

  /// No description provided for @emptyRegistry.
  ///
  /// In es, this message translates to:
  /// **'Registro Vacío'**
  String get emptyRegistry;

  /// No description provided for @emptyRegistryMessage.
  ///
  /// In es, this message translates to:
  /// **'No hay habilidades guardadas en el registro local. Es necesario consultar criaturas del bestiario (API) para llenar el registro antes de poder generar una criatura aleatoria.'**
  String get emptyRegistryMessage;

  /// No description provided for @goToApi.
  ///
  /// In es, this message translates to:
  /// **'Ir a la API'**
  String get goToApi;

  /// No description provided for @randomGenerator.
  ///
  /// In es, this message translates to:
  /// **'Generador Aleatorio'**
  String get randomGenerator;

  /// No description provided for @targetCr.
  ///
  /// In es, this message translates to:
  /// **'CR Objetivo'**
  String get targetCr;

  /// No description provided for @generate.
  ///
  /// In es, this message translates to:
  /// **'Generar'**
  String get generate;

  /// No description provided for @randomCreatureGenerated.
  ///
  /// In es, this message translates to:
  /// **'Generada criatura aleatoria CR {cr}'**
  String randomCreatureGenerated(num cr);

  /// No description provided for @combatManagement.
  ///
  /// In es, this message translates to:
  /// **'Gestión de Combates'**
  String get combatManagement;

  /// No description provided for @newCombat.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Combate'**
  String get newCombat;

  /// No description provided for @noSavedCombats.
  ///
  /// In es, this message translates to:
  /// **'No hay combates guardados'**
  String get noSavedCombats;

  /// No description provided for @newCombatUpper.
  ///
  /// In es, this message translates to:
  /// **'NUEVO COMBATE'**
  String get newCombatUpper;

  /// No description provided for @lastChange.
  ///
  /// In es, this message translates to:
  /// **'Último cambio: {date}'**
  String lastChange(String date);

  /// No description provided for @participantsCount.
  ///
  /// In es, this message translates to:
  /// **'Participantes: {count}'**
  String participantsCount(int count);

  /// No description provided for @roundCount.
  ///
  /// In es, this message translates to:
  /// **'Ronda: {round}'**
  String roundCount(int round);

  /// No description provided for @deleteCombat.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Combate'**
  String get deleteCombat;

  /// No description provided for @confirmDeleteCombat.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar \'{name}\'?'**
  String confirmDeleteCombat(String name);

  /// No description provided for @deleteUpper.
  ///
  /// In es, this message translates to:
  /// **'ELIMINAR'**
  String get deleteUpper;

  /// No description provided for @creature.
  ///
  /// In es, this message translates to:
  /// **'Criatura'**
  String get creature;

  /// No description provided for @deleteParticipant.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Participante'**
  String get deleteParticipant;

  /// No description provided for @confirmDeleteParticipant.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar a {name} del combate?'**
  String confirmDeleteParticipant(String name);

  /// No description provided for @addPlayer.
  ///
  /// In es, this message translates to:
  /// **'Añadir Jugador'**
  String get addPlayer;

  /// No description provided for @initiativeBonus.
  ///
  /// In es, this message translates to:
  /// **'Bono Iniciativa'**
  String get initiativeBonus;

  /// No description provided for @editInitiative.
  ///
  /// In es, this message translates to:
  /// **'Editar Iniciativa - {name}'**
  String editInitiative(String name);

  /// No description provided for @initiativeValue.
  ///
  /// In es, this message translates to:
  /// **'Valor de iniciativa'**
  String get initiativeValue;

  /// No description provided for @hpManagement.
  ///
  /// In es, this message translates to:
  /// **'Gestión de Vida - {name}'**
  String hpManagement(String name);

  /// No description provided for @currentHp.
  ///
  /// In es, this message translates to:
  /// **'Vida Actual'**
  String get currentHp;

  /// No description provided for @tempHp.
  ///
  /// In es, this message translates to:
  /// **'Vida Temporal'**
  String get tempHp;

  /// No description provided for @combatName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del Combate'**
  String get combatName;

  /// No description provided for @preparationUpper.
  ///
  /// In es, this message translates to:
  /// **'PREPARACIÓN'**
  String get preparationUpper;

  /// No description provided for @addCreatures.
  ///
  /// In es, this message translates to:
  /// **'Añadir Criaturas'**
  String get addCreatures;

  /// No description provided for @addPlayers.
  ///
  /// In es, this message translates to:
  /// **'Añadir Jugadores'**
  String get addPlayers;

  /// No description provided for @rollMonsters.
  ///
  /// In es, this message translates to:
  /// **'INI. MONSTRUOS'**
  String get rollMonsters;

  /// No description provided for @rollPlayers.
  ///
  /// In es, this message translates to:
  /// **'INI. JUGADORES'**
  String get rollPlayers;

  /// No description provided for @startCombat.
  ///
  /// In es, this message translates to:
  /// **'EMPEZAR COMBATE'**
  String get startCombat;

  /// No description provided for @roundUpper.
  ///
  /// In es, this message translates to:
  /// **'RONDA {round}'**
  String roundUpper(int round);

  /// No description provided for @nextTurnUpper.
  ///
  /// In es, this message translates to:
  /// **'SIGUIENTE TURNO'**
  String get nextTurnUpper;

  /// No description provided for @endCombat.
  ///
  /// In es, this message translates to:
  /// **'TERMINAR COMBATE'**
  String get endCombat;

  /// No description provided for @player.
  ///
  /// In es, this message translates to:
  /// **'JUGADOR'**
  String get player;

  /// No description provided for @addFromQueue.
  ///
  /// In es, this message translates to:
  /// **'Añadir desde la Cola'**
  String get addFromQueue;

  /// No description provided for @emptyQueueBestiary.
  ///
  /// In es, this message translates to:
  /// **'La cola de batalla está vacía. Añade criaturas desde el Bestiario.'**
  String get emptyQueueBestiary;

  /// No description provided for @login.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo Electrónico'**
  String get email;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In es, this message translates to:
  /// **'ENTRAR'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In es, this message translates to:
  /// **'REGISTRARSE'**
  String get signUp;

  /// No description provided for @loginError.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión'**
  String get loginError;

  /// No description provided for @noAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? Regístrate'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? Inicia sesión'**
  String get haveAccount;

  /// No description provided for @welcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido, {name}'**
  String welcome(Object name);

  /// No description provided for @signInWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión con Google'**
  String get signInWithGoogle;

  /// No description provided for @sharePublicly.
  ///
  /// In es, this message translates to:
  /// **'Compartir públicamente'**
  String get sharePublicly;

  /// No description provided for @publicBestiary.
  ///
  /// In es, this message translates to:
  /// **'Bestiario Público'**
  String get publicBestiary;

  /// No description provided for @sharedBy.
  ///
  /// In es, this message translates to:
  /// **'Compartido por: {name}'**
  String sharedBy(String name);

  /// No description provided for @download.
  ///
  /// In es, this message translates to:
  /// **'DESCARGAR'**
  String get download;

  /// No description provided for @creatureShared.
  ///
  /// In es, this message translates to:
  /// **'Criatura compartida en el Bestiario Público'**
  String get creatureShared;

  /// No description provided for @creatureAddedToBattle.
  ///
  /// In es, this message translates to:
  /// **'{name} añadido a batalla'**
  String creatureAddedToBattle(String name);

  /// No description provided for @alreadyShared.
  ///
  /// In es, this message translates to:
  /// **'Esta criatura ya es pública'**
  String get alreadyShared;

  /// No description provided for @noPublicCreatures.
  ///
  /// In es, this message translates to:
  /// **'No hay criaturas compartidas todavía'**
  String get noPublicCreatures;

  /// No description provided for @keepLoggedIn.
  ///
  /// In es, this message translates to:
  /// **'Mantener la sesión iniciada'**
  String get keepLoggedIn;

  /// No description provided for @signInAsGuest.
  ///
  /// In es, this message translates to:
  /// **'ACCEDER COMO INVITADO'**
  String get signInAsGuest;

  /// No description provided for @saveToMyBestiary.
  ///
  /// In es, this message translates to:
  /// **'Añadir a mis criaturas'**
  String get saveToMyBestiary;

  /// No description provided for @initiativeBonusLabel.
  ///
  /// In es, this message translates to:
  /// **'Bono Ini'**
  String get initiativeBonusLabel;

  /// No description provided for @adSpace.
  ///
  /// In es, this message translates to:
  /// **'ESPACIO PARA PUBLICIDAD'**
  String get adSpace;

  /// No description provided for @statBlockLabel.
  ///
  /// In es, this message translates to:
  /// **'Ficha de estadísticas D&D 5e'**
  String get statBlockLabel;

  /// No description provided for @exportJson.
  ///
  /// In es, this message translates to:
  /// **'Exportar como JSON'**
  String get exportJson;

  /// No description provided for @exportPng.
  ///
  /// In es, this message translates to:
  /// **'Exportar como PNG'**
  String get exportPng;

  /// No description provided for @addToBattle.
  ///
  /// In es, this message translates to:
  /// **'Añadir a Batalla'**
  String get addToBattle;

  /// No description provided for @report.
  ///
  /// In es, this message translates to:
  /// **'Reportar'**
  String get report;

  /// No description provided for @reportReason.
  ///
  /// In es, this message translates to:
  /// **'Motivo del reporte'**
  String get reportReason;

  /// No description provided for @reportSuccess.
  ///
  /// In es, this message translates to:
  /// **'Reporte enviado con éxito'**
  String get reportSuccess;

  /// No description provided for @writeReason.
  ///
  /// In es, this message translates to:
  /// **'Escribe el motivo aquí...'**
  String get writeReason;

  /// No description provided for @accountBlocked.
  ///
  /// In es, this message translates to:
  /// **'CUENTA BLOQUEADA'**
  String get accountBlocked;

  /// No description provided for @blockedMessage.
  ///
  /// In es, this message translates to:
  /// **'Tu acceso a la aplicación ha sido restringido.'**
  String get blockedMessage;

  /// No description provided for @blockReasonLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo del bloqueo:'**
  String get blockReasonLabel;

  /// No description provided for @noReasonProvided.
  ///
  /// In es, this message translates to:
  /// **'No se ha proporcionado un motivo específico.'**
  String get noReasonProvided;

  /// No description provided for @contactAdmin.
  ///
  /// In es, this message translates to:
  /// **'Si crees que esto es un error, contacta con soporte.'**
  String get contactAdmin;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
