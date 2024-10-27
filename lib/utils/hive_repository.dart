import 'package:hive_ce/hive.dart';
import 'package:meal_planning/models/grocery_item.dart';
import 'package:meal_planning/models/recipe.dart';

class HiveRepository {
  late Box recipesBox;
  late Box mealPlanningBox;
  Map<String, Recipe> recipeTitlestoRecipeMap = {};
  Map<String, int> recipeCategoriesMap = {};
  Map<String, int> groceryCategoriesMap = {};
  Map<String, int> genericCategoriesMap = {};
  Map<String, List<GroceryItem>> groceryItemsMap = {};
  List<String> weeklyMealsList = [];
  List<Recipe> recipeList = [];

  HiveRepository();

  cacheInitialData() {
    recipesBox = Hive.box<Recipe>('recipesBox');
    mealPlanningBox = Hive.box<dynamic>('mealPlanningBox');

    recipeList = recipesBox.values.cast<Recipe>().toList();
    recipeCategoriesMap = mealPlanningBox.get('recipeCategoriesMap') ?? {};
    groceryCategoriesMap = mealPlanningBox.get('groceryCategoriesMap') ?? {};
    genericCategoriesMap = mealPlanningBox.get('genericCategoriesMap') ?? {};
    groceryItemsMap = mealPlanningBox.get('groceryItemsMap') ?? {};

    // TODO: Populate recipeTitlestoRecipeMap

    // TODO: Parse weekly meals list > each day is a list; List of 14 lists, 5 entries each [name, colour]
    // Use name to get recipe.category via recipetitlestorecipemap and use the recipeCategoriesMap to get the color
  }

  /**
   * 
   * filterRecipes(tags){return}
   * 
   * addRecipe
   * deleteRecipe
   * updateRecipe
   * 
   * Planning box hold
   * List<int> weeklyPlanningMeals []
   * updateWeeklyPlanningMeals()
   * Map<String, List<dynamic>> GroceryMap
   * "category" : [colour, [groceryItem]]
   * Map<String, int> recipeCategories (Name, color)
   * 
   * updateGroceryListCategories(add: delete:)
   * 
   * deleteGroceryItems(Map<String, List<GroceryItem>>) { for each category, remove those items from list}
   * 
   * addGroceryItems
   * 
   * 
   */
}
