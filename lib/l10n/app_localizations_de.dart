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
  String get settings => 'Einstellungen';

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
  String get updateProfile => 'Update Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get oldPassword => 'Old Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get passwordUpdated => 'Password updated successfully.';

  @override
  String get update => 'Update';

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
  String get addRecipe => 'Hinzufügen';

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
  String get shoppingList => 'Einkaufsliste';

  @override
  String get addToShoppingList => 'Hinzufügen zur Einkaufsliste';

  @override
  String get removeFromShoppingList => 'Entfernen von der Einkaufsliste';

  @override
  String get clearShoppingList => 'Einkaufsliste löschen';

  @override
  String get shoppingListCleared => 'Einkaufsliste gelöscht.';

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
  String loginError(String error) {
    return 'Login Fehler: $error';
  }
}
