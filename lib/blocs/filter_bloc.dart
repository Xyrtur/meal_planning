/*
 * Filter button logic for All Recipes page
 * 
 *  * Filter logic
 * Filter by available recipe categories
 * Have filterToggledList > if empty, show all recipes in current recipe list
 *
 *  For each recipe in current list {
 *    for category in recipe.categories {
 *      if recipe.category in toggled filters > add to list + break loop
 * 
 * }
 * }
 * 
 * returns list of Recipes to display
 */
