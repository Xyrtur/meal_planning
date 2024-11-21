/*
 * onEditClicked
 * onAddGroceryItemsClicked
 * 
 * Detect a paste in ingredients text field and parse it apart via line breaks
 * int length = 0;
 * _phoneController.addListener((){
    if (abs(textEditingController.text.length - length)>1){
        // Do your thingy
    }
    length = _phoneController.length;
});
 * 
 * Detect paste in recipe steps
 *   
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/recipe_bloc.dart';
import 'package:meal_planning/models/recipe.dart';
import 'package:sizer/sizer.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: BlocBuilder<RecipeBloc, RecipeState>(builder: (context, state) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    // TODO: Go back
                  },
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    child: Icon(Icons.chevron_left),
                  ),
                ),
              ],
            )
          ],
        );
      }),
    ));
  }
}
