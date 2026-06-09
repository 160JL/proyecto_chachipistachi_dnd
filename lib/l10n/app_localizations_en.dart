// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DnD Companion';

  @override
  String get mainMenu => 'MAIN MENU';

  @override
  String get battleSimulation => 'Battle Simulation';

  @override
  String get initiativeTracker => 'Initiative Tracker';

  @override
  String get createNewCreature => 'Create New Creature';

  @override
  String get consultBestiary => 'Consult Bestiary (API)';

  @override
  String get mySavedCreatures => 'My Saved Creatures';

  @override
  String get changelogTitle => 'Changelog';

  @override
  String get version => 'Version';

  @override
  String get close => 'CLOSE';

  @override
  String get preparation => 'Preparation';

  @override
  String get round => 'Round';

  @override
  String get start => 'START';

  @override
  String get rollDice => 'Roll Dice';

  @override
  String get configureBoard => 'Configure Board';

  @override
  String get addCreature => 'Add Creature';

  @override
  String get nextTurn => 'Next Turn';

  @override
  String turnOf(String name) {
    return 'TURN OF: $name';
  }

  @override
  String get movement => 'MOVEMENT:';

  @override
  String get cells => 'cells';

  @override
  String get redoMovement => 'Redo movement';

  @override
  String get actions => 'ACTIONS:';

  @override
  String get reactions => 'REACTIONS:';

  @override
  String get legendaryActions => 'LEGENDARY ACTIONS:';

  @override
  String get quantity => 'Quantity:';

  @override
  String get roll => 'Roll:';

  @override
  String get results => 'Results:';

  @override
  String get total => 'Total:';

  @override
  String get boardSize => 'Board Size';

  @override
  String get grid => 'Grid:';

  @override
  String get gridAutoAdjust => 'Cell size will adjust automatically.';

  @override
  String get cancel => 'CANCEL';

  @override
  String get save => 'SAVE';

  @override
  String get addToCombat => 'Add to combat';

  @override
  String get emptyQueueMessage =>
      'The battle queue is empty. Add creatures from the Bestiary or My Creatures first.';

  @override
  String get battleQueue => 'BATTLE QUEUE';

  @override
  String get clearQueue => 'CLEAR QUEUE';

  @override
  String get noName => 'No name';

  @override
  String get hitPoints => 'HIT POINTS';

  @override
  String get initiative => 'Initiative';

  @override
  String get removeFromBattle => 'Remove from battle';

  @override
  String get localRepository => 'Local Repository';

  @override
  String get bestiaryApi => 'Bestiary API';

  @override
  String get updateBestiary => 'Update Bestiary';

  @override
  String get updateBestiaryMessage =>
      'Do you want to update the list or rebuild the skill registry?';

  @override
  String get onlyList => 'Only list';

  @override
  String get everything => 'Everything';

  @override
  String get update => 'Update';

  @override
  String get searchByName => 'Search by name...';

  @override
  String get clear => 'CLEAR';

  @override
  String get advancedFilters => 'Advanced Filters';

  @override
  String get type => 'Type';

  @override
  String get size => 'Size';

  @override
  String get alignment => 'Alignment';

  @override
  String get cr => 'CR';

  @override
  String get sortBy => 'Sort by';

  @override
  String get vulnerabilities => 'Vulnerabilities';

  @override
  String get resistances => 'Resistances';

  @override
  String get immunities => 'Immunities';

  @override
  String get applyFilters => 'APPLY FILTERS';

  @override
  String get nameAsc => 'Name (A-Z)';

  @override
  String get nameDesc => 'Name (Z-A)';

  @override
  String get crAsc => 'CR (Low-High)';

  @override
  String get crDesc => 'CR (High-Low)';

  @override
  String get loading => 'Loading...';

  @override
  String get noCreaturesFound => 'No creatures found.';

  @override
  String get buildingRegistry => 'Building Skill Registry';

  @override
  String get syncingBestiary =>
      'Syncing local bestiary. This process only happens once.';

  @override
  String creaturesProcessed(int current, int total) {
    return '$current / $total creatures processed';
  }

  @override
  String get all => 'All';

  @override
  String get image => 'Image';

  @override
  String get imageUrlOrPath => 'Image URL or local path';

  @override
  String get gallery => 'GALLERY';

  @override
  String get basicData => 'Basic Data';

  @override
  String get name => 'Name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get hp => 'HP';

  @override
  String get acValue => 'AC (Value)';

  @override
  String get acType => 'AC Type (e.g., natural, armor)';

  @override
  String get hitDice => 'Hit Dice';

  @override
  String get hpRoll => 'HP Roll';

  @override
  String get speed => 'Speed';

  @override
  String get walk => 'Walk';

  @override
  String get fly => 'Fly';

  @override
  String get swim => 'Swim';

  @override
  String get attributes => 'Attributes';

  @override
  String get str => 'Strength (STR)';

  @override
  String get dex => 'Dexterity (DEX)';

  @override
  String get con => 'Constitution (CON)';

  @override
  String get intel => 'Intelligence (INT)';

  @override
  String get wis => 'Wisdom (WIS)';

  @override
  String get cha => 'Charisma (CHA)';

  @override
  String get challengeAndXp => 'Challenge and XP';

  @override
  String get profBonus => 'Prof. Bonus';

  @override
  String get senses => 'Senses';

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
  String get other => 'Other';

  @override
  String get languages => 'Languages';

  @override
  String get specialAbilities => 'Special Abilities';

  @override
  String get saveCreature => 'SAVE CREATURE';

  @override
  String get importFromJson => 'Import from JSON';

  @override
  String get jsonHint => 'Paste the complete creature JSON here';

  @override
  String get import => 'Import';

  @override
  String jsonError(String error) {
    return 'JSON format error: $error';
  }

  @override
  String get creatureUpdated => 'Creature updated successfully';

  @override
  String get creatureSaved => 'Creature saved successfully';

  @override
  String editCreature(String name) {
    return 'Edit: $name';
  }

  @override
  String useAsBase(String name) {
    return 'Use as base: $name';
  }

  @override
  String get random => 'Random';

  @override
  String get importJson => 'Import Json';

  @override
  String get add => 'ADD';

  @override
  String get delete => 'DELETE';

  @override
  String editItem(String item) {
    return 'Edit $item';
  }

  @override
  String get typeToSeeSuggestions => 'Type to see suggestions...';

  @override
  String get description => 'Description';

  @override
  String get emptyRegistry => 'Empty Registry';

  @override
  String get emptyRegistryMessage =>
      'There are no skills saved in the local registry. It is necessary to consult creatures from the bestiary (API) to fill the registry before being able to generate a random creature.';

  @override
  String get goToApi => 'Go to API';

  @override
  String get randomGenerator => 'Random Generator';

  @override
  String get targetCr => 'Target CR';

  @override
  String get generate => 'Generate';

  @override
  String randomCreatureGenerated(num cr) {
    return 'Random creature generated CR $cr';
  }

  @override
  String get combatManagement => 'Combat Management';

  @override
  String get newCombat => 'New Combat';

  @override
  String get noSavedCombats => 'No saved combats';

  @override
  String get newCombatUpper => 'NEW COMBAT';

  @override
  String lastChange(String date) {
    return 'Last change: $date';
  }

  @override
  String participantsCount(int count) {
    return 'Participants: $count';
  }

  @override
  String roundCount(int round) {
    return 'Round: $round';
  }

  @override
  String get deleteCombat => 'Delete Combat';

  @override
  String confirmDeleteCombat(String name) {
    return 'Are you sure you want to delete \'$name\'?';
  }

  @override
  String get deleteUpper => 'DELETE';

  @override
  String get creature => 'Creature';

  @override
  String get deleteParticipant => 'Delete Participant';

  @override
  String confirmDeleteParticipant(String name) {
    return 'Are you sure you want to delete $name from the combat?';
  }

  @override
  String get addPlayer => 'Add Player';

  @override
  String get initiativeBonus => 'Initiative Bonus';

  @override
  String editInitiative(String name) {
    return 'Edit Initiative - $name';
  }

  @override
  String get initiativeValue => 'Initiative value';

  @override
  String hpManagement(String name) {
    return 'HP Management - $name';
  }

  @override
  String get currentHp => 'Current HP';

  @override
  String get tempHp => 'Temporary HP';

  @override
  String get combatName => 'Combat Name';

  @override
  String get preparationUpper => 'PREPARATION';

  @override
  String get addCreatures => 'Add Creatures';

  @override
  String get addPlayers => 'Add Players';

  @override
  String get rollMonsters => 'ROLL MONSTERS';

  @override
  String get rollPlayers => 'ROLL PLAYERS';

  @override
  String get startCombat => 'START COMBAT';

  @override
  String roundUpper(int round) {
    return 'ROUND $round';
  }

  @override
  String get nextTurnUpper => 'NEXT TURN';

  @override
  String get endCombat => 'END COMBAT';

  @override
  String get player => 'PLAYER';

  @override
  String get addFromQueue => 'Add from Queue';

  @override
  String get emptyQueueBestiary =>
      'The battle queue is empty. Add creatures from the Bestiary.';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'SIGN IN';

  @override
  String get signUp => 'SIGN UP';

  @override
  String get loginError => 'Login error';

  @override
  String get noAccount => 'Don\'t have an account? Sign up';

  @override
  String get haveAccount => 'Already have an account? Login';

  @override
  String welcome(Object name) {
    return 'Welcome, $name';
  }

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get sharePublicly => 'Share Publicly';

  @override
  String get publicBestiary => 'Public Bestiary';

  @override
  String sharedBy(String name) {
    return 'Shared by: $name';
  }

  @override
  String get download => 'DOWNLOAD';

  @override
  String get creatureShared => 'Creature shared in Public Bestiary';

  @override
  String creatureAddedToBattle(String name) {
    return '$name added to battle';
  }

  @override
  String get alreadyShared => 'This creature is already public';

  @override
  String get noPublicCreatures => 'No shared creatures yet';

  @override
  String get keepLoggedIn => 'Keep me logged in';

  @override
  String get signInAsGuest => 'SIGN IN AS GUEST';

  @override
  String get saveToMyBestiary => 'Add to my bestiary';

  @override
  String get initiativeBonusLabel => 'Ini Bonus';

  @override
  String get adSpace => 'ADVERTISING SPACE';

  @override
  String get statBlockLabel => 'D&D 5e Stat Block';

  @override
  String get exportJson => 'Export as JSON';

  @override
  String get exportPng => 'Export as PNG';

  @override
  String get addToBattle => 'Add to Battle';
}
