/*
 * Provided to: Recipe page
 * OnSearchClicked
 * Takes in a common list from all recipes page or dialog
 * Make recipe list of names from common  list
 * 
 *   var recipeNames = ["dressing", "Honey Roasted Beets", "Chicken Adobo", "Chili chicken Beets cheems", "peanuts", "coleslaw chick"];
      String searchStr="beet";
      String reg = (searchStr.split(" ").map((word) => '(?=.*' + RegExp.escape(word) + ')').join());
      RegExp reg1 = RegExp("^$reg",caseSensitive: false);
      for (String recipeName in recipeNames){
        if (reg1.hasMatch(recipeName)){

        returns list of Recipes to display, mapped from hive.recipenamesmap
 */
