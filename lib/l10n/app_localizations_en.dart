// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome => 'Welcome';

  @override
  String get serverAddress => 'Server Address';

  @override
  String get serverHint => 'https://mealie.example';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get fillAllFields => 'Please fill in server, email, and password.';

  @override
  String get home => 'Home';

  @override
  String get planner => 'Planner';

  @override
  String get settings => 'Settings';

  @override
  String get shopping => 'Shopping';

  @override
  String get logout => 'Logout';

  @override
  String get invalidCredentials => 'Invalid email or password.';

  @override
  String get networkError => 'Network error. Please try again later.';

  @override
  String get recipe => 'Recipe';

  @override
  String get recipes => 'Recipes';

  @override
  String get favorites => 'Favorites';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get search => 'Search';

  @override
  String get noResultsFound => 'No results found.';

  @override
  String get loading => 'Loading...';

  @override
  String get errorOccurred => 'An error occurred. Please try again.';

  @override
  String get profile => 'Profile';

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
  String get cancel => 'Cancel';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get enableDarkMode => 'Enable Dark Mode';

  @override
  String get addRecipe => 'Add Recipe';

  @override
  String get editRecipe => 'Edit Recipe';

  @override
  String get deleteRecipe => 'Delete Recipe';

  @override
  String get confirmDeleteRecipe =>
      'Are you sure you want to delete this recipe?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get shoppingList => 'Shopping List';

  @override
  String get shoppingLists => 'Shopping Lists';

  @override
  String get addToShoppingList => 'Add to Shopping List';

  @override
  String get removeFromShoppingList => 'Remove from Shopping List';

  @override
  String get clearShoppingList => 'Clear Shopping List';

  @override
  String get shoppingListCleared => 'Shopping list cleared.';

  @override
  String get notifications => 'Notifications';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get disableNotifications => 'Disable Notifications';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get save => 'Save';

  @override
  String get changesSaved => 'Changes saved successfully.';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get mealPlanner => 'Meal Planner';

  @override
  String get planYourMeals => 'Plan your meals for the week.';

  @override
  String get addMeal => 'Add Meal';

  @override
  String get addItem => 'Add Item';

  @override
  String get editItem => 'Edit Item';

  @override
  String get deleteItem => 'Delete Item';

  @override
  String get confirmDeleteItem => 'Are you sure you want to delete this item?';

  @override
  String get noItemsPlanned => 'No items planned.';

  @override
  String get editMeal => 'Edit Meal';

  @override
  String get deleteMeal => 'Delete Meal';

  @override
  String get confirmDeleteMeal => 'Are you sure you want to delete this meal?';

  @override
  String get noMealsPlanned => 'No meals planned.';

  @override
  String get noToken => 'No token found. Please log in again.';

  @override
  String get addList => 'Add List';

  @override
  String get createList => 'Create List';

  @override
  String get editList => 'Edit List';

  @override
  String get deleteList => 'Delete List';

  @override
  String get confirmDeleteList => 'Are you sure you want to delete this list?';

  @override
  String get noListsFound => 'No lists found.';

  @override
  String get searchList => 'Search list...';

  @override
  String get addListItem => 'Add List Item';

  @override
  String get editListItem => 'Edit List Item';

  @override
  String get deleteListItem => 'Delete List Item';

  @override
  String get confirmDeleteListItem =>
      'Are you sure you want to delete this list item?';

  @override
  String greetingGoodMorning(Object name) {
    return 'Good morning, $name!';
  }

  @override
  String greetingGoodDay(Object name) {
    return 'Good day, $name!';
  }

  @override
  String greetingGoodEvening(Object name) {
    return 'Good evening, $name!';
  }

  @override
  String greetingGoodNight(Object name) {
    return 'Good night, $name!';
  }

  @override
  String get whatDoYouWantToCook => 'What do you want to cook today?';

  @override
  String get recipeSearch => 'Search for a recipe...';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get popularRecipes => 'Popular Recipes';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get list => 'List';

  @override
  String get item => 'Item';

  @override
  String greeting(Object name) {
    return 'Hello, $name!';
  }

  @override
  String get add => 'Add';

  @override
  String get unnamedMeal => 'Unnamed Meal';

  @override
  String get loginSuccess => 'Login successful.';

  @override
  String loginError(String error) {
    return 'Login error: $error';
  }
}
