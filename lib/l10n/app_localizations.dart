import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

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
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @serverAddress.
  ///
  /// In en, this message translates to:
  /// **'Server Address'**
  String get serverAddress;

  /// No description provided for @serverHint.
  ///
  /// In en, this message translates to:
  /// **'https://mealie.example'**
  String get serverHint;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your Mealie server to manage recipes, shopping lists, and meal plans.'**
  String get loginDescription;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in server, email, and password.'**
  String get fillAllFields;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @planner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get planner;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out? All local data will be deleted.'**
  String get confirmLogout;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get invalidCredentials;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please try again later.'**
  String get networkError;

  /// No description provided for @recipe.
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get recipe;

  /// No description provided for @recipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipes;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get removeFromFavorites;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get noResultsFound;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorOccurred;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully.'**
  String get passwordUpdated;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @enableDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Enable Dark Mode'**
  String get enableDarkMode;

  /// No description provided for @addRecipe.
  ///
  /// In en, this message translates to:
  /// **'Add Recipe'**
  String get addRecipe;

  /// No description provided for @editRecipe.
  ///
  /// In en, this message translates to:
  /// **'Edit Recipe'**
  String get editRecipe;

  /// No description provided for @deleteRecipe.
  ///
  /// In en, this message translates to:
  /// **'Delete Recipe'**
  String get deleteRecipe;

  /// No description provided for @confirmDeleteRecipe.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this recipe?'**
  String get confirmDeleteRecipe;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @shoppingList.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingList;

  /// No description provided for @shoppingLists.
  ///
  /// In en, this message translates to:
  /// **'Shopping Lists'**
  String get shoppingLists;

  /// No description provided for @addToShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Add to Shopping List'**
  String get addToShoppingList;

  /// No description provided for @removeFromShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Remove from Shopping List'**
  String get removeFromShoppingList;

  /// No description provided for @clearShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Clear Shopping List'**
  String get clearShoppingList;

  /// No description provided for @shoppingListCleared.
  ///
  /// In en, this message translates to:
  /// **'Shopping list cleared.'**
  String get shoppingListCleared;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @disableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Disable Notifications'**
  String get disableNotifications;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved successfully.'**
  String get changesSaved;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @mealPlanner.
  ///
  /// In en, this message translates to:
  /// **'Meal Planner'**
  String get mealPlanner;

  /// No description provided for @planYourMeals.
  ///
  /// In en, this message translates to:
  /// **'Plan your meals for the week.'**
  String get planYourMeals;

  /// No description provided for @addMeal.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get addMeal;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItem;

  /// No description provided for @confirmDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get confirmDeleteItem;

  /// No description provided for @noItemsPlanned.
  ///
  /// In en, this message translates to:
  /// **'No items planned.'**
  String get noItemsPlanned;

  /// No description provided for @editMeal.
  ///
  /// In en, this message translates to:
  /// **'Edit Meal'**
  String get editMeal;

  /// No description provided for @deleteMeal.
  ///
  /// In en, this message translates to:
  /// **'Delete Meal'**
  String get deleteMeal;

  /// No description provided for @confirmDeleteMeal.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String confirmDeleteMeal(String name);

  /// No description provided for @noMealsPlanned.
  ///
  /// In en, this message translates to:
  /// **'No meals planned.'**
  String get noMealsPlanned;

  /// No description provided for @mealAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" added to planner.'**
  String mealAddedSuccess(String name);

  /// No description provided for @mealUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Meal updated successfully.'**
  String get mealUpdatedSuccess;

  /// No description provided for @mealDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Meal deleted successfully.'**
  String get mealDeletedSuccess;

  /// No description provided for @mealTypeAlreadyPlanned.
  ///
  /// In en, this message translates to:
  /// **'{mealType} is already planned for this day.'**
  String mealTypeAlreadyPlanned(String mealType);

  /// No description provided for @noToken.
  ///
  /// In en, this message translates to:
  /// **'No token found. Please log in again.'**
  String get noToken;

  /// No description provided for @addList.
  ///
  /// In en, this message translates to:
  /// **'Add List'**
  String get addList;

  /// No description provided for @createList.
  ///
  /// In en, this message translates to:
  /// **'Create List'**
  String get createList;

  /// No description provided for @editList.
  ///
  /// In en, this message translates to:
  /// **'Edit List'**
  String get editList;

  /// No description provided for @deleteList.
  ///
  /// In en, this message translates to:
  /// **'Delete List'**
  String get deleteList;

  /// No description provided for @confirmDeleteList.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this list?'**
  String get confirmDeleteList;

  /// No description provided for @noListsFound.
  ///
  /// In en, this message translates to:
  /// **'No lists found.'**
  String get noListsFound;

  /// No description provided for @searchList.
  ///
  /// In en, this message translates to:
  /// **'Search list...'**
  String get searchList;

  /// No description provided for @addListItem.
  ///
  /// In en, this message translates to:
  /// **'Add List Item'**
  String get addListItem;

  /// No description provided for @editListItem.
  ///
  /// In en, this message translates to:
  /// **'Edit List Item'**
  String get editListItem;

  /// No description provided for @deleteListItem.
  ///
  /// In en, this message translates to:
  /// **'Delete List Item'**
  String get deleteListItem;

  /// No description provided for @confirmDeleteListItem.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this list item?'**
  String get confirmDeleteListItem;

  /// No description provided for @greetingGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}!'**
  String greetingGoodMorning(Object name);

  /// No description provided for @greetingGoodDay.
  ///
  /// In en, this message translates to:
  /// **'Good day, {name}!'**
  String greetingGoodDay(Object name);

  /// No description provided for @greetingGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}!'**
  String greetingGoodEvening(Object name);

  /// No description provided for @greetingGoodNight.
  ///
  /// In en, this message translates to:
  /// **'Good night, {name}!'**
  String greetingGoodNight(Object name);

  /// No description provided for @whatDoYouWantToCook.
  ///
  /// In en, this message translates to:
  /// **'What do you want to cook today?'**
  String get whatDoYouWantToCook;

  /// No description provided for @recipeSearch.
  ///
  /// In en, this message translates to:
  /// **'Search for a recipe...'**
  String get recipeSearch;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @popularRecipes.
  ///
  /// In en, this message translates to:
  /// **'Popular Recipes'**
  String get popularRecipes;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String greeting(Object name);

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @unnamedMeal.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Meal'**
  String get unnamedMeal;

  /// No description provided for @meal.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get meal;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful.'**
  String get loginSuccess;

  /// Error message shown when login fails
  ///
  /// In en, this message translates to:
  /// **'Login error: {error}'**
  String loginError(String error);

  /// No description provided for @checkInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection.'**
  String get checkInternetConnection;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'A server error occurred. Please try again later.'**
  String get serverError;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get defaultUserName;

  /// No description provided for @noPopularRecipesFound.
  ///
  /// In en, this message translates to:
  /// **'No popular recipes found.'**
  String get noPopularRecipesFound;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred.'**
  String get unknownError;

  /// No description provided for @featureNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'This feature is not implemented yet.'**
  String get featureNotImplemented;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @noRecipesFound.
  ///
  /// In en, this message translates to:
  /// **'No recipes found.'**
  String get noRecipesFound;

  /// No description provided for @recipeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Recipe not found.'**
  String get recipeNotFound;

  /// No description provided for @servingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} servings'**
  String servingsCount(int count);

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesShort(String count);

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @trySearchingSomethingElse.
  ///
  /// In en, this message translates to:
  /// **'Try searching for something else.'**
  String get trySearchingSomethingElse;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @loadingUser.
  ///
  /// In en, this message translates to:
  /// **'Loading user...'**
  String get loadingUser;

  /// No description provided for @serverAndApi.
  ///
  /// In en, this message translates to:
  /// **'Server & API'**
  String get serverAndApi;

  /// No description provided for @appearanceAndLanguage.
  ///
  /// In en, this message translates to:
  /// **'Appearance & Language'**
  String get appearanceAndLanguage;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @syncStarted.
  ///
  /// In en, this message translates to:
  /// **'Synchronization started...'**
  String get syncStarted;

  /// No description provided for @listCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" was created'**
  String listCreatedSuccess(String name);

  /// No description provided for @errorCreating.
  ///
  /// In en, this message translates to:
  /// **'Error creating: {error}'**
  String errorCreating(String error);

  /// No description provided for @shoppingListDeleted.
  ///
  /// In en, this message translates to:
  /// **'Shopping list deleted.'**
  String get shoppingListDeleted;

  /// No description provided for @errorDeleting.
  ///
  /// In en, this message translates to:
  /// **'Error deleting: {error}'**
  String errorDeleting(String error);

  /// No description provided for @createFirstListHint.
  ///
  /// In en, this message translates to:
  /// **'Create your first list to get started.'**
  String get createFirstListHint;

  /// No description provided for @createFirstList.
  ///
  /// In en, this message translates to:
  /// **'Create first list'**
  String get createFirstList;

  /// No description provided for @allDone.
  ///
  /// In en, this message translates to:
  /// **'All done'**
  String get allDone;

  /// No description provided for @openItemsSingular.
  ///
  /// In en, this message translates to:
  /// **'1 open item'**
  String get openItemsSingular;

  /// No description provided for @openItemsPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} open items'**
  String openItemsPlural(int count);

  /// No description provided for @errorUpdating.
  ///
  /// In en, this message translates to:
  /// **'Error updating: {error}'**
  String errorUpdating(String error);

  /// No description provided for @itemAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" was added'**
  String itemAddedSuccess(String name);

  /// No description provided for @errorAdding.
  ///
  /// In en, this message translates to:
  /// **'Error adding: {error}'**
  String errorAdding(String error);

  /// No description provided for @itemDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" was deleted'**
  String itemDeletedSuccess(String name);

  /// No description provided for @errorEditing.
  ///
  /// In en, this message translates to:
  /// **'Error editing: {error}'**
  String errorEditing(String error);

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @listEmpty.
  ///
  /// In en, this message translates to:
  /// **'This list is empty'**
  String get listEmpty;

  /// No description provided for @addFirstItemHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first item.'**
  String get addFirstItemHint;

  /// No description provided for @itemDetailsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Details will be displayed here.'**
  String get itemDetailsPlaceholder;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline mode'**
  String get offlineMode;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @useSystemSetting.
  ///
  /// In en, this message translates to:
  /// **'Use system setting'**
  String get useSystemSetting;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @notificationSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Notification settings will be available soon.'**
  String get notificationSettingsComingSoon;

  /// No description provided for @serverUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get serverUrl;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @showCompletedItems.
  ///
  /// In en, this message translates to:
  /// **'Show completed items'**
  String get showCompletedItems;

  /// No description provided for @hideCategories.
  ///
  /// In en, this message translates to:
  /// **'Hide categories'**
  String get hideCategories;

  /// No description provided for @showCategories.
  ///
  /// In en, this message translates to:
  /// **'Show categories'**
  String get showCategories;

  /// No description provided for @uncheckAllItems.
  ///
  /// In en, this message translates to:
  /// **'Uncheck all items'**
  String get uncheckAllItems;

  /// No description provided for @deleteCompletedItems.
  ///
  /// In en, this message translates to:
  /// **'Delete completed items'**
  String get deleteCompletedItems;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @side.
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get side;

  /// No description provided for @drink.
  ///
  /// In en, this message translates to:
  /// **'Drink'**
  String get drink;

  /// No description provided for @dessert.
  ///
  /// In en, this message translates to:
  /// **'Dessert'**
  String get dessert;

  /// No description provided for @searchOrEnterRecipeName.
  ///
  /// In en, this message translates to:
  /// **'Search recipe or enter new name'**
  String get searchOrEnterRecipeName;

  /// No description provided for @newRecipeNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name of the new recipe...'**
  String get newRecipeNameHint;

  /// No description provided for @continueToDetails.
  ///
  /// In en, this message translates to:
  /// **'Continue to details'**
  String get continueToDetails;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @ingredientsPerLine.
  ///
  /// In en, this message translates to:
  /// **'Ingredients (one per line)'**
  String get ingredientsPerLine;

  /// No description provided for @servings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servings;

  /// No description provided for @prepTimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'Prep time (min)'**
  String get prepTimeMinutes;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @newShoppingListNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name of the new shopping list...'**
  String get newShoppingListNameHint;

  /// No description provided for @foodCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" was created'**
  String foodCreatedSuccess(String name);

  /// No description provided for @errorCreatingFood.
  ///
  /// In en, this message translates to:
  /// **'Could not create food: {error}'**
  String errorCreatingFood(String error);

  /// No description provided for @deleteFood.
  ///
  /// In en, this message translates to:
  /// **'Delete food?'**
  String get deleteFood;

  /// No description provided for @confirmDeleteFood.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete \"{name}\"?'**
  String confirmDeleteFood(String name);

  /// No description provided for @foodStillInUse.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is still used in a shopping list or recipe and cannot be deleted.'**
  String foodStillInUse(String name);

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Deletion failed: {error}'**
  String deleteFailed(String error);

  /// No description provided for @pleaseEnterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity'**
  String get pleaseEnterValidQuantity;

  /// No description provided for @pleaseSelectShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Please select a shopping list'**
  String get pleaseSelectShoppingList;

  /// No description provided for @pleaseSelectOrEnterFood.
  ///
  /// In en, this message translates to:
  /// **'Please select or enter a food'**
  String get pleaseSelectOrEnterFood;

  /// No description provided for @addNewItem.
  ///
  /// In en, this message translates to:
  /// **'Add new item'**
  String get addNewItem;

  /// No description provided for @pleaseSelectList.
  ///
  /// In en, this message translates to:
  /// **'Please select a list'**
  String get pleaseSelectList;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @addNewFood.
  ///
  /// In en, this message translates to:
  /// **'Add new food'**
  String get addNewFood;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @couldNotLoadFormData.
  ///
  /// In en, this message translates to:
  /// **'Could not load form data.'**
  String get couldNotLoadFormData;

  /// No description provided for @createShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Create shopping list'**
  String get createShoppingList;

  /// No description provided for @searchRecipes.
  ///
  /// In en, this message translates to:
  /// **'Search for recipes...'**
  String get searchRecipes;

  /// No description provided for @untitledMeal.
  ///
  /// In en, this message translates to:
  /// **'Untitled Meal'**
  String get untitledMeal;

  /// No description provided for @addMealToPlanner.
  ///
  /// In en, this message translates to:
  /// **'Add meal'**
  String get addMealToPlanner;

  /// No description provided for @editNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Edit functionality is not implemented yet.'**
  String get editNotImplemented;

  /// No description provided for @addNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Add functionality is not implemented yet.'**
  String get addNotImplemented;

  /// No description provided for @searchArticle.
  ///
  /// In en, this message translates to:
  /// **'Search article...'**
  String get searchArticle;

  /// No description provided for @lastModified.
  ///
  /// In en, this message translates to:
  /// **'Last modified'**
  String get lastModified;

  /// No description provided for @doneItems.
  ///
  /// In en, this message translates to:
  /// **'{count} done'**
  String doneItems(int count);

  /// No description provided for @openItems.
  ///
  /// In en, this message translates to:
  /// **'{count} open'**
  String openItems(int count);

  /// No description provided for @renameList.
  ///
  /// In en, this message translates to:
  /// **'Rename list'**
  String get renameList;

  /// No description provided for @enterNewName.
  ///
  /// In en, this message translates to:
  /// **'Enter new name'**
  String get enterNewName;

  /// No description provided for @searchRecipesHint.
  ///
  /// In en, this message translates to:
  /// **'Search for recipes...'**
  String get searchRecipesHint;

  /// No description provided for @noRecipesFoundSearch.
  ///
  /// In en, this message translates to:
  /// **'No Recipes Found'**
  String get noRecipesFoundSearch;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try searching for something else.'**
  String get tryDifferentSearch;

  /// No description provided for @itemDetails.
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get itemDetails;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes'**
  String get noNotes;

  /// No description provided for @noUnit.
  ///
  /// In en, this message translates to:
  /// **'No unit'**
  String get noUnit;

  /// No description provided for @noFood.
  ///
  /// In en, this message translates to:
  /// **'No food'**
  String get noFood;

  /// No description provided for @noCategory.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get noCategory;

  /// No description provided for @checkedStatus.
  ///
  /// In en, this message translates to:
  /// **'Checked'**
  String get checkedStatus;

  /// No description provided for @uncheckedStatus.
  ///
  /// In en, this message translates to:
  /// **'Unchecked'**
  String get uncheckedStatus;

  /// No description provided for @editQuantity.
  ///
  /// In en, this message translates to:
  /// **'Edit quantity'**
  String get editQuantity;

  /// No description provided for @editNotes.
  ///
  /// In en, this message translates to:
  /// **'Edit notes'**
  String get editNotes;

  /// No description provided for @editDisplay.
  ///
  /// In en, this message translates to:
  /// **'Edit display name'**
  String get editDisplay;

  /// No description provided for @newQuantity.
  ///
  /// In en, this message translates to:
  /// **'New quantity'**
  String get newQuantity;

  /// No description provided for @newNotes.
  ///
  /// In en, this message translates to:
  /// **'New notes'**
  String get newNotes;

  /// No description provided for @newDisplayName.
  ///
  /// In en, this message translates to:
  /// **'New display name'**
  String get newDisplayName;

  /// No description provided for @toggleChecked.
  ///
  /// In en, this message translates to:
  /// **'Toggle checked'**
  String get toggleChecked;

  /// No description provided for @itemUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" was updated'**
  String itemUpdatedSuccess(String name);

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortDirection.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get sortDirection;

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortByName;

  /// No description provided for @sortByDateCreated.
  ///
  /// In en, this message translates to:
  /// **'Date created'**
  String get sortByDateCreated;

  /// No description provided for @sortByDateUpdated.
  ///
  /// In en, this message translates to:
  /// **'Date updated'**
  String get sortByDateUpdated;

  /// No description provided for @sortByRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get sortByRating;

  /// No description provided for @sortByPrepTime.
  ///
  /// In en, this message translates to:
  /// **'Prep time'**
  String get sortByPrepTime;

  /// No description provided for @sortByPosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get sortByPosition;

  /// No description provided for @sortByChecked.
  ///
  /// In en, this message translates to:
  /// **'Checked status'**
  String get sortByChecked;

  /// No description provided for @sortByCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get sortByCategory;

  /// No description provided for @recipeYield.
  ///
  /// In en, this message translates to:
  /// **'Yield (e.g. 4 pieces)'**
  String get recipeYield;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total time (min)'**
  String get totalTime;

  /// No description provided for @cookTime.
  ///
  /// In en, this message translates to:
  /// **'Cook time (min)'**
  String get cookTime;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get addIngredient;

  /// No description provided for @ingredientsList.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredientsList;

  /// No description provided for @noIngredientsAdded.
  ///
  /// In en, this message translates to:
  /// **'No ingredients added yet.'**
  String get noIngredientsAdded;

  /// No description provided for @removeIngredient.
  ///
  /// In en, this message translates to:
  /// **'Remove ingredient'**
  String get removeIngredient;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(int current, int total);

  /// No description provided for @recipeCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get recipeCategories;

  /// No description provided for @categoriesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Italian, Vegan, ...'**
  String get categoriesHint;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. quick, healthy, ...'**
  String get tagsHint;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Utensils'**
  String get tools;

  /// No description provided for @toolsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. oven, blender, ...'**
  String get toolsHint;

  /// No description provided for @instructionsPerStep.
  ///
  /// In en, this message translates to:
  /// **'Preparation Steps'**
  String get instructionsPerStep;

  /// No description provided for @noInstructionsAdded.
  ///
  /// In en, this message translates to:
  /// **'No steps added yet'**
  String get noInstructionsAdded;

  /// No description provided for @addInstructionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the step...'**
  String get addInstructionHint;

  /// No description provided for @addInstruction.
  ///
  /// In en, this message translates to:
  /// **'Add step'**
  String get addInstruction;

  /// No description provided for @recipeNote.
  ///
  /// In en, this message translates to:
  /// **'Recipe Note'**
  String get recipeNote;

  /// No description provided for @recipeNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Additional notes...'**
  String get recipeNoteHint;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addTag;

  /// No description provided for @removeTag.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeTag;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @recipeCreated.
  ///
  /// In en, this message translates to:
  /// **'Recipe created successfully'**
  String get recipeCreated;

  /// No description provided for @recipeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recipe updated successfully'**
  String get recipeUpdated;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes?'**
  String get discardChanges;

  /// No description provided for @discardChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to discard them?'**
  String get discardChangesMessage;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;
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
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
