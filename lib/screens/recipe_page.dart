import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:meal_planning/blocs/all_recipes_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/blocs/grocery_bloc.dart';
import 'package:meal_planning/blocs/recipe_bloc.dart';
import 'package:meal_planning/blocs/settings_bloc.dart';
import 'package:meal_planning/models/recipe.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:meal_planning/widgets/dialogs/add_grocery_ingredient_dialog.dart';
import 'package:meal_planning/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:meal_planning/widgets/dialogs/filter_category_dialog.dart.dart';
import 'package:sizer/sizer.dart';

class RecipePage extends StatelessWidget {
  final List<String> existingRecipeTitles;
  final GlobalKey<RecipeTextFieldState> titleKey;
  RecipePage({super.key, required this.existingRecipeTitles, required this.titleKey});
  // List of keys will let us validate all their controllers at once when user is finished editing
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ValueNotifier<bool?> deletingRecipe = ValueNotifier<bool?>(false);

  @override
  Widget build(BuildContext context) {
    deletingRecipe.addListener(() {
      if (deletingRecipe.value ?? false) {
        context.read<AllRecipesBloc>().add(const RecipeAddDeleted());
        Navigator.pop(context);
      }
    });

    return SafeArea(
        child: Scaffold(
      backgroundColor: Centre.bgColor,
      body: BlocBuilder<RecipeBloc, RecipeState>(builder: (_, state) {
        List<String> ingredients = state.recipe?.ingredients.split('\n') ?? [];
        List<String> instructions = state.recipe?.instructions.split('\n') ?? [];

        return Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        child: const Icon(Icons.chevron_left),
                      ),
                    ),
                    state is ViewingRecipe
                        ? Expanded(
                            child: Text(
                              state.recipe.title,
                              style: Centre.titleText,
                              maxLines: 2,
                            ),
                          )
                        : Expanded(
                            child: RecipeTextField(
                              key: titleKey,
                              text: (state as EditingRecipe).recipe?.title,
                              existingTitles: existingRecipeTitles,
                            ),
                          ),
                    state is ViewingRecipe
                        ? GestureDetector(
                            onTap: () {
                              context.read<RecipeBloc>().add(EditRecipeClicked(state.recipe));
                            },
                            child: Container(
                              padding: EdgeInsets.all(3.w),
                              child: const Icon(Icons.edit),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              // Validate all the textfields
                              if (formKey.currentState!.validate()) {
                                List<String> newIngredients = List.from(context
                                    .read<RecipeIngredientKeysCubit>()
                                    .state
                                    .map((key) => key.currentState!.controller.text));
                                List<String> newInstructions = List.from(context
                                    .read<RecipeInstructionsKeysCubit>()
                                    .state
                                    .map((key) => key.currentState!.controller.text));

                                if ((state as EditingRecipe).recipe == null) {
                                  Recipe recipe = Recipe(
                                      title: titleKey.currentState!.controller.text,
                                      ingredients: newIngredients.join("\n"),
                                      instructions: newInstructions.join("\n"),
                                      categories: context.read<RecipeCategoriesSelectedCubit>().state);
                                  context.read<RecipeBloc>().add(AddRecipe(recipe));
                                  context.read<AllRecipesBloc>().add(const RecipeAddDeleted());
                                } else {
                                  Recipe recipe = state.recipe!;
                                  recipe.edit(
                                      title: titleKey.currentState!.controller.text,
                                      ingredients: newIngredients.join("\n"),
                                      instructions: newInstructions.join("\n"),
                                      categories: context.read<RecipeCategoriesSelectedCubit>().state);

                                  context.read<RecipeBloc>().add(UpdateRecipe(state.recipe!, recipe));
                                  context.read<AllRecipesBloc>().add(const RecipeAddDeleted());
                                }
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(3.w),
                              child: const Icon(Icons.check),
                            ),
                          ),
                    state.recipe != null
                        ? GestureDetector(
                            onTap: () async {
                              deletingRecipe.value = await showDialog<bool>(
                                  context: context,
                                  builder: (_) {
                                    return BlocProvider.value(
                                      value: context.read<RecipeBloc>(),
                                      child: DeleteConfirmationDialog(recipe: state.recipe!),
                                    );
                                  });
                            },
                            child: Container(padding: EdgeInsets.all(3.w), child: const Icon(Icons.delete)),
                          )
                        : const SizedBox()
                  ],
                ),
                BlocBuilder<RecipeCategoriesSelectedCubit, List<String>>(builder: (anotherContext, categoriesSelected) {
                  return Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 2.w,
                      runSpacing: 0.5.h,
                      children: [
                        for (String category in categoriesSelected)
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 4.w),
                            decoration: BoxDecoration(
                              color: Color(context.read<SettingsBloc>().state.recipeCategoriesMap[category]!)
                                  .withAlpha(100),
                              borderRadius: const BorderRadius.all(Radius.circular(25)),
                              border: Border.all(
                                color: Color(context.read<SettingsBloc>().state.recipeCategoriesMap[category]!),
                                width: 0.5.w,
                              ),
                            ),
                            child: Text(category),
                          ),
                        state is EditingRecipe
                            ? GestureDetector(
                                onTap: () {
                                  showAlignedDialog(
                                      barrierColor: Colors.transparent,
                                      followerAnchor: Alignment.topCenter,
                                      targetAnchor: Alignment.bottomCenter,
                                      offset: Offset(25.w, 2.h),
                                      context: anotherContext,
                                      builder: (BuildContext dialogContext) => GestureDetector(
                                            onTap: () => Navigator.pop(dialogContext),
                                            child: Scaffold(
                                              backgroundColor: Colors.transparent,
                                              body: BlocProvider<RecipeCategoriesSelectedCubit>.value(
                                                value: context.read<RecipeCategoriesSelectedCubit>(),
                                                child: FilterCategoryDialog(
                                                    isWeeklyPlanning: false,
                                                    categoriesMap:
                                                        context.read<SettingsBloc>().state.recipeCategoriesMap),
                                              ),
                                            ),
                                          ));
                                },
                                child: Container(
                                    padding: EdgeInsets.all(2.w),
                                    decoration: ShapeDecoration(
                                      shadows: [
                                        BoxShadow(
                                          color: Centre.shadowbgColor,
                                          spreadRadius: 2,
                                          blurRadius: 7,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                      color: Centre.bgColor,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(20))),
                                    ),
                                    child: const Icon(Icons.add)),
                              )
                            : const SizedBox()
                      ],
                    ),
                  );
                }),
                Text(
                  "Ingredients",
                  style: Centre.semiTitleText,
                ),
                Divider(
                  height: 0.5.h,
                  color: Centre.shadowbgColor,
                ),
                BlocBuilder<RecipeIngredientKeysCubit, List<GlobalKey<RecipeTextFieldState>>>(
                    builder: (_, ingredientKeys) {
                  return SizedBox(
                    height: ((state is ViewingRecipe ? ingredients.length : ingredientKeys.length + 1) / 2).ceil() *
                        (state is ViewingRecipe ? 6.5.h : 9.h),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                      child: MasonryGridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 1.w,
                        mainAxisSpacing: 1.h,
                        itemCount: (state is ViewingRecipe) ? ingredients.length : ingredientKeys.length + 1,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return index == ingredientKeys.length
                              ? GestureDetector(
                                  onTap: () {
                                    context.read<RecipeIngredientKeysCubit>().addKey();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(2.w),
                                    child: const Icon(Icons.add),
                                  ))
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    state is ViewingRecipe
                                        ? const Text(
                                            ' \u2022 ',
                                            textHeightBehavior: TextHeightBehavior(
                                                applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              context
                                                  .read<RecipeIngredientKeysCubit>()
                                                  .deleteKey(key: ingredientKeys[index]);
                                            },
                                            behavior: HitTestBehavior.translucent,
                                            child: Padding(
                                              padding: EdgeInsets.all(2.w),
                                              child: const Icon(Icons.delete),
                                            ),
                                          ),
                                    state is ViewingRecipe
                                        ? Expanded(
                                            child: Text(
                                              ingredients[index],
                                              softWrap: true,
                                              maxLines: 3,
                                            ),
                                          )
                                        : Expanded(
                                            child: RecipeTextField(
                                              key: ingredientKeys[index],
                                              type: TextFieldType.ingredient,
                                              text: ingredients.isEmpty
                                                  ? ""
                                                  : index >= ingredients.length
                                                      ? ""
                                                      : ingredients[index],
                                            ),
                                          )
                                  ],
                                );
                        },
                      ),
                    ),
                  );
                }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Steps", style: Centre.semiTitleText),
                    state is ViewingRecipe
                        ? GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (_) {
                                    return MultiBlocProvider(
                                      providers: [
                                        BlocProvider.value(value: context.read<GroceryBloc>()),
                                        BlocProvider.value(value: context.read<SettingsBloc>()),
                                        BlocProvider<IngredientsAlreadyDraggedCubit>(
                                            create: (_) => IngredientsAlreadyDraggedCubit()),
                                        BlocProvider<MultiSelectIngredientsCubit>(
                                            create: (_) => MultiSelectIngredientsCubit())
                                      ],
                                      child: AddToGroceryListDialog(ingredients: state.recipe.ingredients.split('\n')),
                                    );
                                  });
                            },
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              child: const Icon(Icons.menu),
                            ))
                        : const SizedBox()
                  ],
                ),
                Divider(
                  height: 0.5.h,
                  color: Centre.shadowbgColor,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  child: BlocBuilder<RecipeInstructionsKeysCubit, List<GlobalKey<RecipeTextFieldState>>>(
                      builder: (_, instructionsKeys) {
                    return Column(children: [
                      for (int i = 0;
                          i < ((state is ViewingRecipe) ? instructions.length : instructionsKeys.length);
                          i++)
                        Row(
                          children: [
                            state is EditingRecipe
                                ? GestureDetector(
                                    onTap: () {
                                      context.read<RecipeInstructionsKeysCubit>().deleteKey(key: instructionsKeys[i]);
                                    },
                                    behavior: HitTestBehavior.translucent,
                                    child: Padding(
                                      padding: EdgeInsets.all(2.w),
                                      child: const Icon(Icons.delete),
                                    ),
                                  )
                                : const SizedBox(),
                            Text("${i + 1}"),
                            SizedBox(
                              width: 3.w,
                            ),
                            state is ViewingRecipe
                                ? Expanded(
                                    child: Text(
                                    instructions[i],
                                    maxLines: 5,
                                  ))
                                : Expanded(
                                    child: RecipeTextField(
                                      key: instructionsKeys[i],
                                      type: TextFieldType.instruction,
                                      text: instructions.isEmpty ? "" : instructions[i],
                                    ),
                                  )
                          ],
                        )
                    ]);
                  }),
                ),
                state is EditingRecipe
                    ? GestureDetector(
                        onTap: () {
                          context.read<RecipeInstructionsKeysCubit>().addKey();
                        },
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          child: const Icon(Icons.add),
                        ))
                    : const SizedBox(),
                const Spacer()
              ],
            ),
          ),
        );
      }),
    ));
  }
}

enum TextFieldType { ingredient, instruction }

class RecipeTextField extends StatefulWidget {
  final List<String>? existingTitles;
  final TextFieldType? type;
  final String? text;
  const RecipeTextField({super.key, this.existingTitles, this.text, this.type});

  @override
  State<RecipeTextField> createState() => RecipeTextFieldState();
}

class RecipeTextFieldState extends State<RecipeTextField> {
  final TextEditingController controller = TextEditingController();
  int length = 0;

  @override
  void initState() {
    super.initState();
    controller.text = widget.text ?? "";
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // autofocus: widget.existingTitles != null,
      contextMenuBuilder: (BuildContext context, EditableTextState editableTextState) {
        return AdaptiveTextSelectionToolbar.editable(
          anchors: editableTextState.contextMenuAnchors,
          onLiveTextInput: null,
          onLookUp: null,
          onSearchWeb: null,
          onShare: null,
          clipboardStatus: ClipboardStatus.pasteable,
          // to apply the normal behavior when click on copy (copy in clipboard close toolbar)
          // use an empty function `() {}` to hide this option from the toolbar
          onCopy: null,
          // to apply the normal behavior when click on cut
          onCut: null,
          onPaste: () {
            // editableTextState.textEditingValue.text
            List<String> fields = controller.text.split('\n');
            if (widget.type == TextFieldType.ingredient) {
              for (String newText in fields) {
                // GlobalKey<RecipeTextFieldState> createdKey =
                //     context.read<RecipeIngredientKeysCubit>().addKey();
                // createdKey.currentState!.controller.text = newText;
              }
            } else if (widget.type == TextFieldType.instruction) {
              for (String newText in fields) {
                GlobalKey<RecipeTextFieldState> createdKey = context.read<RecipeInstructionsKeysCubit>().addKey();
                createdKey.currentState!.controller.text = newText;
              }
            }

            // to apply the normal behavior when click on paste (add in input and close toolbar)
            editableTextState.pasteText(SelectionChangedCause.toolbar);
          },
          // to apply the normal behavior when click on select all
          onSelectAll: null,
        );
      },
      controller: controller,
      validator: (text) {
        if (text == null || text.isEmpty) {
          return 'Can\'t be empty';
        } else if (text.length > 50) {
          return 'Too long';
        } else if ((widget.existingTitles?.contains(text) ?? false) && widget.text != text) {
          return 'Title already exists';
        }
        return null;
      },
    );
  }
}
