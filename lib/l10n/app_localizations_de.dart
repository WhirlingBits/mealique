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
  String get loginSuccess => 'Anmeldung erfolgreich.';

  @override
  String loginError(String error) {
    return 'Anmeldefehler: $error';
  }
}
