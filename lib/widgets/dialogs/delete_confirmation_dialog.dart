import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/recipe_bloc.dart';
import 'package:meal_planning/models/recipe.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:sizer/sizer.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final Recipe recipe;

  const DeleteConfirmationDialog({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(40))),
        backgroundColor: Centre.shadowbgColor,
        elevation: 5,
        content: SizedBox(
            height: 19.5.h,
            width: 80.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Are you sure?",
                  style: Centre.titleText,
                ),
                SizedBox(
                  height: 2.h,
                ),
                Text(
                  "This will permanently remove ${recipe.title} from your recipes.",
                  maxLines: 2,
                  style: Centre.listText,
                ),
                SizedBox(
                  height: 2.5.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: Text(
                          "Cancel",
                          style: Centre.listText,
                        )),
                    TextButton(
                        onPressed: () {
                          context.read<RecipeBloc>().add(DeleteRecipe(recipe));

                          Navigator.pop(context, true);
                        },
                        child: Text(
                          "OK",
                          style: Centre.listText,
                        ))
                  ],
                )
              ],
            )));
  }
}
