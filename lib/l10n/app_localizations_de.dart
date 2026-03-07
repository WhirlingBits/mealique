// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get welcome => 'Willkommen';

  @override
  String get serverAddress => 'Server Adresse';

  @override
  String get serverHint => 'https://mealie.example';

  @override
  String get email => 'Email';

  @override
  String get password => 'Passwort';

  @override
  String get login => 'Einloggen';

  @override
  String get fillAllFields => 'Bitte Server, Email und Passwort ausfüllen.';

  @override
  String get home => 'Startseite';

  @override
  String get planner => 'Planer';

  @override
  String get settings => 'Einstellungen';

  @override
  String get shopping => 'Einkaufen';

  @override
  String get logout => 'Logout';

  @override
  String get invalidCredentials => 'Ungültige E-Mail oder Passwort.';

  @override
  String get networkError => 'Netzwerkfehler. Bitte versuche es später erneut.';

  @override
  String get recipe => 'Rezept';

  @override
  String get recipes => 'Rezepte';

  @override
  String get favorites => 'Favoriten';

  @override
  String get addToFavorites => 'Zu Favoriten hinzufügen';

  @override
  String get removeFromFavorites => 'Favoriten entfernen';

  @override
  String get search => 'Suche';

  @override
  String get noResultsFound => 'Keine Ergebnisse gefunden.';

  @override
  String get loading => 'Lade...';

  @override
  String get errorOccurred =>
      'Ein Fehler ist aufgetreten. Bitte versuche es erneut.';

  @override
  String get profile => 'Profil';

  @override
  String get updateProfile => 'Profil aktualisieren';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get oldPassword => 'Altes Passwort';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get confirmNewPassword => 'Neues Passwort bestätigen';

  @override
  String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein.';

  @override
  String get passwordUpdated => 'Passwort erfolgreich aktualisiert.';

  @override
  String get update => 'Aktualisieren';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get language => 'Sprache';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get enableDarkMode => 'Dunkelmodus aktivieren';

  @override
  String get addRecipe => 'Rezept hinzufügen';

  @override
  String get editRecipe => 'Rezept bearbeiten';

  @override
  String get deleteRecipe => 'Rezept löschen';

  @override
  String get confirmDeleteRecipe =>
      'Bist du sicher, dass du dieses Rezept löschen möchtest?';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get shoppingList => 'Einkaufsliste';

  @override
  String get shoppingLists => 'Einkaufslisten';

  @override
  String get addToShoppingList => 'Zur Einkaufsliste hinzufügen';

  @override
  String get removeFromShoppingList => 'Von der Einkaufsliste entfernen';

  @override
  String get clearShoppingList => 'Einkaufsliste leeren';

  @override
  String get shoppingListCleared => 'Einkaufsliste geleert.';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get enableNotifications => 'Benachrichtigungen aktivieren';

  @override
  String get disableNotifications => 'Benachrichtigungen deaktivieren';

  @override
  String get notificationSettings => 'Benachrichtigungseinstellungen';

  @override
  String get save => 'Speichern';

  @override
  String get changesSaved => 'Änderungen erfolgreich gespeichert.';

  @override
  String get about => 'Über';

  @override
  String get version => 'Version';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get privacyPolicy => 'Datenschutz-Bestimmungen';

  @override
  String get mealPlanner => 'Mahlzeitenplaner';

  @override
  String get planYourMeals => 'Plane deine Mahlzeiten für die Woche.';

  @override
  String get addMeal => 'Mahlzeit hinzufügen';

  @override
  String get addItem => 'Element hinzufügen';

  @override
  String get editItem => 'Element bearbeiten';

  @override
  String get deleteItem => 'Element löschen';

  @override
  String get confirmDeleteItem =>
      'Bist du sicher, dass du dieses Element löschen möchtest?';

  @override
  String get noItemsPlanned => 'Keine Elemente geplant.';

  @override
  String get editMeal => 'Mahlzeit bearbeiten';

  @override
  String get deleteMeal => 'Mahlzeit löschen';

  @override
  String get confirmDeleteMeal =>
      'Bist du sicher, dass du diese Mahlzeit löschen möchtest?';

  @override
  String get noMealsPlanned => 'Keine Mahlzeiten geplant.';

  @override
  String get noToken => 'Kein Token gefunden. Bitte melde dich erneut an.';

  @override
  String get addList => 'Liste hinzufügen';

  @override
  String get createList => 'Liste erstellen';

  @override
  String get editList => 'Liste bearbeiten';

  @override
  String get deleteList => 'Liste löschen';

  @override
  String get confirmDeleteList =>
      'Sind Sie sicher, dass Sie diese Liste löschen möchten?';

  @override
  String get noListsFound => 'Keine Listen gefunden.';

  @override
  String get searchList => 'Liste suchen...';

  @override
  String get addListItem => 'Listenelement hinzufügen';

  @override
  String get editListItem => 'Listenelement bearbeiten';

  @override
  String get deleteListItem => 'Listenelement löschen';

  @override
  String get confirmDeleteListItem =>
      'Bist du sicher, dass du dieses Listenelement löschen möchtest?';

  @override
  String greetingGoodMorning(Object name) {
    return 'Guten Morgen, $name!';
  }

  @override
  String greetingGoodDay(Object name) {
    return 'Guten Tag, $name!';
  }

  @override
  String greetingGoodEvening(Object name) {
    return 'Guten Abend, $name!';
  }

  @override
  String greetingGoodNight(Object name) {
    return 'Gute Nacht, $name!';
  }

  @override
  String get whatDoYouWantToCook => 'Was möchtest du heute kochen?';

  @override
  String get recipeSearch => 'Suche nach einem Rezept...';

  @override
  String get today => 'Heute';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get popularRecipes => 'Beliebte Rezepte';

  @override
  String get quickActions => 'Schnellaktionen';

  @override
  String get list => 'Liste';

  @override
  String get item => 'Element';

  @override
  String greeting(Object name) {
    return 'Hallo, $name!';
  }

  @override
  String get add => 'Hinzufügen';

  @override
  String get unnamedMeal => 'Unbenannte Mahlzeit';

  @override
  String get meal => 'Mahlzeit';

  @override
  String get loginSuccess => 'Anmeldung erfolgreich.';

  @override
  String loginError(String error) {
    return 'Anmeldefehler: $error';
  }

  @override
  String get checkInternetConnection => 'Bitte prüfe deine Internetverbindung.';

  @override
  String get serverError =>
      'Ein Serverfehler ist aufgetreten. Bitte versuche es später erneut.';

  @override
  String get unexpectedError => 'Ein unerwarteter Fehler ist aufgetreten.';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get defaultUserName => 'dort';

  @override
  String get noPopularRecipesFound => 'Keine beliebten Rezepte gefunden.';

  @override
  String get unknownError => 'Ein unbekannter Fehler ist aufgetreten.';

  @override
  String get featureNotImplemented =>
      'Diese Funktion ist noch nicht implementiert.';

  @override
  String get all => 'Alle';

  @override
  String get filter => 'Filter';

  @override
  String get noRecipesFound => 'Keine Rezepte gefunden.';

  @override
  String get recipeNotFound => 'Rezept nicht gefunden.';

  @override
  String servingsCount(int count) {
    return '$count Portionen';
  }

  @override
  String minutesShort(String count) {
    return '$count Min';
  }

  @override
  String get ingredients => 'Zutaten';

  @override
  String get instructions => 'Zubereitung';

  @override
  String get trySearchingSomethingElse => 'Versuche etwas anderes zu suchen.';

  @override
  String get favorite => 'Favorit';

  @override
  String get loadingUser => 'Lade Benutzer...';

  @override
  String get serverAndApi => 'Server & API';

  @override
  String get appearanceAndLanguage => 'Darstellung & Sprache';

  @override
  String get sync => 'Sync';

  @override
  String get syncStarted => 'Synchronisierung gestartet...';

  @override
  String listCreatedSuccess(String name) {
    return '\"$name\" wurde erstellt';
  }

  @override
  String errorCreating(String error) {
    return 'Fehler beim Erstellen: $error';
  }

  @override
  String get shoppingListDeleted => 'Einkaufsliste wurde gelöscht.';

  @override
  String errorDeleting(String error) {
    return 'Fehler beim Löschen: $error';
  }

  @override
  String get createFirstListHint => 'Lege deine erste Liste an, um loszulegen.';

  @override
  String get createFirstList => 'Erste Liste erstellen';

  @override
  String get allDone => 'Alle erledigt';

  @override
  String get openItemsSingular => '1 offenes Element';

  @override
  String openItemsPlural(int count) {
    return '$count offene Elemente';
  }

  @override
  String errorUpdating(String error) {
    return 'Fehler beim Aktualisieren: $error';
  }

  @override
  String itemAddedSuccess(String name) {
    return '\"$name\" wurde hinzugefügt';
  }

  @override
  String errorAdding(String error) {
    return 'Fehler beim Hinzufügen: $error';
  }

  @override
  String itemDeletedSuccess(String name) {
    return '\"$name\" wurde gelöscht';
  }

  @override
  String errorEditing(String error) {
    return 'Fehler beim Bearbeiten: $error';
  }

  @override
  String get general => 'Allgemein';

  @override
  String get listEmpty => 'Diese Liste ist leer';

  @override
  String get addFirstItemHint => 'Füge dein erstes Item hinzu.';

  @override
  String get itemDetailsPlaceholder => 'Details werden hier angezeigt.';

  @override
  String get offlineMode => 'Offline-Modus';

  @override
  String get ok => 'OK';

  @override
  String get appearance => 'Darstellung';

  @override
  String get lightMode => 'Heller Modus';

  @override
  String get useSystemSetting => 'Systemeinstellung verwenden';

  @override
  String get appLanguage => 'App-Sprache';

  @override
  String get german => 'Deutsch';

  @override
  String get english => 'English';

  @override
  String get notificationSettingsComingSoon =>
      'Hier werden bald die Benachrichtigungseinstellungen zu finden sein.';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get sort => 'Sortieren';

  @override
  String get share => 'Teilen';

  @override
  String get showCompletedItems => 'Abgeschlossene Items anzeigen';

  @override
  String get hideCategories => 'Kategorien ausblenden';

  @override
  String get showCategories => 'Kategorien anzeigen';

  @override
  String get uncheckAllItems => 'Markierung aller Elemente entfernen';

  @override
  String get deleteCompletedItems => 'Erledigte Elemente löschen';

  @override
  String get breakfast => 'Frühstück';

  @override
  String get lunch => 'Mittagessen';

  @override
  String get dinner => 'Abendessen';

  @override
  String get snack => 'Snack';

  @override
  String get searchOrEnterRecipeName =>
      'Rezept suchen oder neuen Namen eingeben';

  @override
  String get newRecipeNameHint => 'Name des neuen Rezepts...';

  @override
  String get continueToDetails => 'Weiter zu Details';

  @override
  String get name => 'Name';

  @override
  String get descriptionOptional => 'Beschreibung (optional)';

  @override
  String get ingredientsPerLine => 'Zutaten (je Zeile ein Eintrag)';

  @override
  String get servings => 'Portionen';

  @override
  String get prepTimeMinutes => 'Zubereitungszeit (Min)';

  @override
  String get back => 'Zurück';

  @override
  String get done => 'Fertig';

  @override
  String get pleaseEnterName => 'Bitte einen Namen eingeben';

  @override
  String get newShoppingListNameHint => 'Name der neuen Einkaufsliste...';

  @override
  String foodCreatedSuccess(String name) {
    return '\"$name\" wurde erstellt';
  }

  @override
  String errorCreatingFood(String error) {
    return 'Lebensmittel konnte nicht erstellt werden: $error';
  }

  @override
  String get deleteFood => 'Lebensmittel löschen?';

  @override
  String confirmDeleteFood(String name) {
    return 'Möchtest du \"$name\" wirklich löschen?';
  }

  @override
  String foodStillInUse(String name) {
    return '\"$name\" wird noch in einer Einkaufsliste oder einem Rezept verwendet und kann nicht gelöscht werden.';
  }

  @override
  String deleteFailed(String error) {
    return 'Löschen fehlgeschlagen: $error';
  }

  @override
  String get pleaseEnterValidQuantity => 'Bitte eine gültige Menge eingeben';

  @override
  String get pleaseSelectShoppingList => 'Bitte eine Einkaufsliste auswählen';

  @override
  String get pleaseSelectOrEnterFood =>
      'Bitte ein Lebensmittel auswählen oder eingeben';

  @override
  String get addNewItem => 'Neues Item hinzufügen';

  @override
  String get pleaseSelectList => 'Bitte eine Liste wählen';

  @override
  String get advanced => 'Erweitert';

  @override
  String get unit => 'Einheit';

  @override
  String get category => 'Kategorie';

  @override
  String get food => 'Lebensmittel';

  @override
  String get addNewFood => 'Neues Lebensmittel hinzufügen';

  @override
  String get quantity => 'Anzahl';

  @override
  String get notesOptional => 'Notizen (optional)';

  @override
  String get couldNotLoadFormData =>
      'Formulardaten konnten nicht geladen werden.';

  @override
  String get createShoppingList => 'Einkaufsliste erstellen';

  @override
  String get searchRecipes => 'Rezepte suchen...';

  @override
  String get untitledMeal => 'Unbenannte Mahlzeit';

  @override
  String get addMealToPlanner => 'Mahlzeit hinzufügen';

  @override
  String get editNotImplemented =>
      'Die Bearbeitung ist noch nicht implementiert.';

  @override
  String get addNotImplemented =>
      'Das Hinzufügen ist noch nicht implementiert.';

  @override
  String get searchArticle => 'Artikel suchen...';

  @override
  String get lastModified => 'Zuletzt geändert';

  @override
  String doneItems(int count) {
    return '$count erledigt';
  }

  @override
  String openItems(int count) {
    return '$count offen';
  }

  @override
  String get renameList => 'Liste umbenennen';

  @override
  String get enterNewName => 'Neuen Namen eingeben';

  @override
  String get searchRecipesHint => 'Rezepte suchen...';

  @override
  String get noRecipesFoundSearch => 'Keine Rezepte gefunden';

  @override
  String get tryDifferentSearch => 'Versuche etwas anderes zu suchen.';

  @override
  String get itemDetails => 'Artikeldetails';

  @override
  String get notes => 'Notizen';

  @override
  String get noNotes => 'Keine Notizen';

  @override
  String get noUnit => 'Keine Einheit';

  @override
  String get noFood => 'Kein Lebensmittel';

  @override
  String get noCategory => 'Keine Kategorie';

  @override
  String get checkedStatus => 'Erledigt';

  @override
  String get uncheckedStatus => 'Offen';

  @override
  String get editQuantity => 'Menge bearbeiten';

  @override
  String get editNotes => 'Notizen bearbeiten';

  @override
  String get editDisplay => 'Anzeigename bearbeiten';

  @override
  String get newQuantity => 'Neue Menge';

  @override
  String get newNotes => 'Neue Notizen';

  @override
  String get newDisplayName => 'Neuer Anzeigename';

  @override
  String get toggleChecked => 'Status umschalten';

  @override
  String itemUpdatedSuccess(String name) {
    return '\"$name\" wurde aktualisiert';
  }

  @override
  String get appVersion => 'App-Version';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get sortDirection => 'Richtung';

  @override
  String get ascending => 'Aufsteigend';

  @override
  String get descending => 'Absteigend';

  @override
  String get sortByName => 'Name';

  @override
  String get sortByDateCreated => 'Erstellungsdatum';

  @override
  String get sortByDateUpdated => 'Änderungsdatum';

  @override
  String get sortByRating => 'Bewertung';

  @override
  String get sortByPrepTime => 'Zubereitungszeit';

  @override
  String get sortByPosition => 'Position';

  @override
  String get sortByChecked => 'Erledigt-Status';

  @override
  String get sortByCategory => 'Kategorie';
}
