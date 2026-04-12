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
  String get email => 'Email or Username';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get loginDescription =>
      'Sign in with your Mealie server to manage recipes, shopping lists, and meal plans.';

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
  String get confirmLogout =>
      'Are you sure you want to log out? All local data will be deleted.';

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
  String confirmDeleteMeal(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get noMealsPlanned => 'No meals planned.';

  @override
  String mealAddedSuccess(String name) {
    return '\"$name\" added to planner.';
  }

  @override
  String get mealUpdatedSuccess => 'Meal updated successfully.';

  @override
  String get mealDeletedSuccess => 'Meal deleted successfully.';

  @override
  String mealTypeAlreadyPlanned(String mealType) {
    return '$mealType is already planned for this day.';
  }

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
  String get meal => 'Meal';

  @override
  String get loginSuccess => 'Login successful.';

  @override
  String loginError(String error) {
    return 'Login error: $error';
  }

  @override
  String get checkInternetConnection =>
      'Please check your internet connection.';

  @override
  String get serverError => 'A server error occurred. Please try again later.';

  @override
  String get unexpectedError => 'An unexpected error occurred.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get defaultUserName => 'there';

  @override
  String get noPopularRecipesFound => 'No popular recipes found.';

  @override
  String get unknownError => 'An unknown error occurred.';

  @override
  String get featureNotImplemented => 'This feature is not implemented yet.';

  @override
  String get all => 'All';

  @override
  String get filter => 'Filter';

  @override
  String get noRecipesFound => 'No recipes found.';

  @override
  String get recipeNotFound => 'Recipe not found.';

  @override
  String servingsCount(int count) {
    return '$count servings';
  }

  @override
  String minutesShort(String count) {
    return '$count min';
  }

  @override
  String get ingredients => 'Ingredients';

  @override
  String get instructions => 'Instructions';

  @override
  String get trySearchingSomethingElse => 'Try searching for something else.';

  @override
  String get favorite => 'Favorite';

  @override
  String get loadingUser => 'Loading user...';

  @override
  String get serverAndApi => 'Server & API';

  @override
  String get appearanceAndLanguage => 'Appearance & Language';

  @override
  String get sync => 'Sync';

  @override
  String get syncStarted => 'Synchronization started...';

  @override
  String listCreatedSuccess(String name) {
    return '\"$name\" was created';
  }

  @override
  String errorCreating(String error) {
    return 'Error creating: $error';
  }

  @override
  String get shoppingListDeleted => 'Shopping list deleted.';

  @override
  String errorDeleting(String error) {
    return 'Error deleting: $error';
  }

  @override
  String get createFirstListHint => 'Create your first list to get started.';

  @override
  String get createFirstList => 'Create first list';

  @override
  String get allDone => 'All done';

  @override
  String get openItemsSingular => '1 open item';

  @override
  String openItemsPlural(int count) {
    return '$count open items';
  }

  @override
  String errorUpdating(String error) {
    return 'Error updating: $error';
  }

  @override
  String itemAddedSuccess(String name) {
    return '\"$name\" was added';
  }

  @override
  String errorAdding(String error) {
    return 'Error adding: $error';
  }

  @override
  String itemDeletedSuccess(String name) {
    return '\"$name\" was deleted';
  }

  @override
  String errorEditing(String error) {
    return 'Error editing: $error';
  }

  @override
  String get general => 'General';

  @override
  String get listEmpty => 'This list is empty';

  @override
  String get addFirstItemHint => 'Add your first item.';

  @override
  String get itemDetailsPlaceholder => 'Details will be displayed here.';

  @override
  String get offlineMode => 'Offline mode';

  @override
  String get ok => 'OK';

  @override
  String get appearance => 'Appearance';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get useSystemSetting => 'Use system setting';

  @override
  String get appLanguage => 'App Language';

  @override
  String get german => 'German';

  @override
  String get english => 'English';

  @override
  String get notificationSettingsComingSoon =>
      'Notification settings will be available soon.';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get refresh => 'Refresh';

  @override
  String get sort => 'Sort';

  @override
  String get share => 'Share';

  @override
  String get showCompletedItems => 'Show completed items';

  @override
  String get hideCategories => 'Hide categories';

  @override
  String get showCategories => 'Show categories';

  @override
  String get uncheckAllItems => 'Uncheck all items';

  @override
  String get deleteCompletedItems => 'Delete completed items';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snack => 'Snack';

  @override
  String get side => 'Side';

  @override
  String get drink => 'Drink';

  @override
  String get dessert => 'Dessert';

  @override
  String get searchOrEnterRecipeName => 'Search recipe or enter new name';

  @override
  String get newRecipeNameHint => 'Name of the new recipe...';

  @override
  String get continueToDetails => 'Continue to details';

  @override
  String get name => 'Name';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get ingredientsPerLine => 'Ingredients (one per line)';

  @override
  String get servings => 'Servings';

  @override
  String get prepTimeMinutes => 'Prep time (min)';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get newShoppingListNameHint => 'Name of the new shopping list...';

  @override
  String foodCreatedSuccess(String name) {
    return '\"$name\" was created';
  }

  @override
  String errorCreatingFood(String error) {
    return 'Could not create food: $error';
  }

  @override
  String get deleteFood => 'Delete food?';

  @override
  String confirmDeleteFood(String name) {
    return 'Do you really want to delete \"$name\"?';
  }

  @override
  String foodStillInUse(String name) {
    return '\"$name\" is still used in a shopping list or recipe and cannot be deleted.';
  }

  @override
  String deleteFailed(String error) {
    return 'Deletion failed: $error';
  }

  @override
  String get pleaseEnterValidQuantity => 'Please enter a valid quantity';

  @override
  String get pleaseSelectShoppingList => 'Please select a shopping list';

  @override
  String get pleaseSelectOrEnterFood => 'Please select or enter a food';

  @override
  String get addNewItem => 'Add new item';

  @override
  String get pleaseSelectList => 'Please select a list';

  @override
  String get advanced => 'Advanced';

  @override
  String get unit => 'Unit';

  @override
  String get category => 'Category';

  @override
  String get food => 'Food';

  @override
  String get addNewFood => 'Add new food';

  @override
  String get quantity => 'Quantity';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get couldNotLoadFormData => 'Could not load form data.';

  @override
  String get createShoppingList => 'Create shopping list';

  @override
  String get searchRecipes => 'Search for recipes...';

  @override
  String get untitledMeal => 'Untitled Meal';

  @override
  String get addMealToPlanner => 'Add meal';

  @override
  String get editNotImplemented => 'Edit functionality is not implemented yet.';

  @override
  String get addNotImplemented => 'Add functionality is not implemented yet.';

  @override
  String get searchArticle => 'Search article...';

  @override
  String get lastModified => 'Last modified';

  @override
  String doneItems(int count) {
    return '$count done';
  }

  @override
  String openItems(int count) {
    return '$count open';
  }

  @override
  String get renameList => 'Rename list';

  @override
  String get enterNewName => 'Enter new name';

  @override
  String get searchRecipesHint => 'Search for recipes...';

  @override
  String get noRecipesFoundSearch => 'No Recipes Found';

  @override
  String get tryDifferentSearch => 'Try searching for something else.';

  @override
  String get itemDetails => 'Item Details';

  @override
  String get notes => 'Notes';

  @override
  String get noNotes => 'No notes';

  @override
  String get noUnit => 'No unit';

  @override
  String get noFood => 'No food';

  @override
  String get noCategory => 'No category';

  @override
  String get checkedStatus => 'Checked';

  @override
  String get uncheckedStatus => 'Unchecked';

  @override
  String get editQuantity => 'Edit quantity';

  @override
  String get editNotes => 'Edit notes';

  @override
  String get editDisplay => 'Edit display name';

  @override
  String get newQuantity => 'New quantity';

  @override
  String get newNotes => 'New notes';

  @override
  String get newDisplayName => 'New display name';

  @override
  String get toggleChecked => 'Toggle checked';

  @override
  String itemUpdatedSuccess(String name) {
    return '\"$name\" was updated';
  }

  @override
  String get appVersion => 'App Version';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortDirection => 'Direction';

  @override
  String get ascending => 'Ascending';

  @override
  String get descending => 'Descending';

  @override
  String get sortByName => 'Name';

  @override
  String get sortByDateCreated => 'Date created';

  @override
  String get sortByDateUpdated => 'Date updated';

  @override
  String get sortByRating => 'Rating';

  @override
  String get sortByPrepTime => 'Prep time';

  @override
  String get sortByPosition => 'Position';

  @override
  String get sortByChecked => 'Checked status';

  @override
  String get sortByCategory => 'Category';

  @override
  String get recipeYield => 'Yield (e.g. 4 pieces)';

  @override
  String get totalTime => 'Total time (min)';

  @override
  String get cookTime => 'Cook time (min)';

  @override
  String get addIngredient => 'Add Ingredient';

  @override
  String get ingredientsList => 'Ingredients';

  @override
  String get noIngredientsAdded => 'No ingredients added yet.';

  @override
  String get removeIngredient => 'Remove ingredient';

  @override
  String stepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get recipeCategories => 'Categories';

  @override
  String get categoriesHint => 'e.g. Italian, Vegan, ...';

  @override
  String get tags => 'Tags';

  @override
  String get tagsHint => 'e.g. quick, healthy, ...';

  @override
  String get tools => 'Utensils';

  @override
  String get toolsHint => 'e.g. oven, blender, ...';

  @override
  String get instructionsPerStep => 'Preparation Steps';

  @override
  String get noInstructionsAdded => 'No steps added yet';

  @override
  String get addInstructionHint => 'Describe the step...';

  @override
  String get addInstruction => 'Add step';

  @override
  String get recipeNote => 'Recipe Note';

  @override
  String get recipeNoteHint => 'Additional notes...';

  @override
  String get addTag => 'Add';

  @override
  String get removeTag => 'Remove';

  @override
  String get rating => 'Rating';

  @override
  String get recipeCreated => 'Recipe created successfully';

  @override
  String get recipeUpdated => 'Recipe updated successfully';

  @override
  String get error => 'Error';

  @override
  String get description => 'Description';

  @override
  String get discardChanges => 'Discard Changes?';

  @override
  String get discardChangesMessage =>
      'You have unsaved changes. Do you want to discard them?';

  @override
  String get discard => 'Discard';

  @override
  String get editShoppingItem => 'Edit Item';

  @override
  String get displayName => 'Display Name';

  @override
  String get displayNameHint => 'How this item appears in the list';

  @override
  String get checkedStatus_label => 'Status';

  @override
  String get itemSaved => 'Item saved successfully';

  @override
  String get noChanges => 'No changes to save';

  @override
  String listUpdatedSuccess(String name) {
    return '\"$name\" was updated';
  }

  @override
  String get listName => 'List name';

  @override
  String get details => 'Details';

  @override
  String get createdAt => 'Created at';

  @override
  String get updatedAt => 'Updated at';

  @override
  String get items => 'Items';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String updateAvailableMessage(String version) {
    return 'A new version ($version) is available. Would you like to update now?';
  }

  @override
  String get updateNow => 'Update Now';

  @override
  String get later => 'Later';

  @override
  String get selectShoppingList => 'Select Shopping List';

  @override
  String get noShoppingListsFound =>
      'No shopping lists found. Please create one first.';

  @override
  String get noIngredientsToAdd => 'This recipe has no ingredients to add.';

  @override
  String ingredientsAddedToList(String listName) {
    return 'Ingredients added to $listName';
  }

  @override
  String get addAllIngredients => 'Add all ingredients';

  @override
  String get selectIngredients => 'Select ingredients';

  @override
  String get selectIngredientsToAdd => 'Select ingredients to add';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get selectAll => 'Select all';

  @override
  String get deselectAll => 'Deselect all';

  @override
  String get noIngredientsSelected => 'Please select at least one ingredient.';

  @override
  String get notificationPermissionRequired =>
      'Notification permission is required to receive meal reminders.';

  @override
  String get notificationPermissionDenied =>
      'Notification permission denied. Please enable it in settings.';

  @override
  String get enableMealReminders => 'Meal Reminders';

  @override
  String get mealRemindersDescription =>
      'Receive daily reminders for your planned meals.';

  @override
  String get mealTimes => 'Reminder Times';

  @override
  String get breakfastReminder => 'Time for breakfast!';

  @override
  String get lunchReminder => 'Time for lunch!';

  @override
  String get dinnerReminder => 'Time for dinner!';

  @override
  String get mealReminderBody =>
      'Check your meal plan to see what\'s on the menu.';

  @override
  String get mealReminderInfo =>
      'Reminders will notify you daily at the set times. Make sure to plan your meals in advance.';

  @override
  String get backgroundSyncEnabled => 'Background sync enabled';

  @override
  String get backgroundSyncDescription =>
      'Automatically sync your data when you have an internet connection.';

  @override
  String get selectList => 'Select a list';

  @override
  String get randomRecipe => 'Random recipe';

  @override
  String get noRandomRecipeFound =>
      'Could not find a random recipe. Please try again.';
}
