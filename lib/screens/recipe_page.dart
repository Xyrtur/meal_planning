import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
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
import 'package:meal_planning/widgets/shake_widget.dart';
import 'package:sizer/sizer.dart';

class RecipePage extends StatelessWidget {
  final ShakeController _shakeController = ShakeController();
  final List<String> existingRecipeTitles;
  final GlobalKey<RecipeTextFieldState> titleKey;
  final GlobalKey<FormFieldState> prepTimeKey;
  final TextEditingController prepTimeController = TextEditingController();
  RecipePage({super.key, required this.existingRecipeTitles, required this.titleKey, required this.prepTimeKey});
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
        prepTimeController.text = state.recipe?.prepTime ?? "";

        return Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: SizedBox(
              height: 100.h,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Row(
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
                                          categories: context.read<RecipeCategoriesSelectedCubit>().state,
                                          prepTime: prepTimeController.text,
                                        );
                                        context.read<InstructionsListCubit>().replaceList(newList: newInstructions);
                                        context
                                            .read<RecipeInstructionsKeysCubit>()
                                            .replaceList(numKeys: newInstructions.length);
                                        context.read<IngredientsListCubit>().replaceList(newList: newIngredients);
                                        context
                                            .read<RecipeIngredientKeysCubit>()
                                            .replaceList(numKeys: newIngredients.length);
                                        context.read<RecipeBloc>().add(AddRecipe(recipe));
                                        context.read<AllRecipesBloc>().add(const RecipeAddDeleted());
                                      } else {
                                        Recipe recipe = state.recipe!;
                                        recipe.edit(
                                          title: titleKey.currentState!.controller.text,
                                          ingredients: newIngredients.join("\n"),
                                          instructions: newInstructions.join("\n"),
                                          categories: context.read<RecipeCategoriesSelectedCubit>().state,
                                          prepTime: prepTimeController.text,
                                        );
                                        context.read<InstructionsListCubit>().replaceList(newList: newInstructions);
                                        context
                                            .read<RecipeInstructionsKeysCubit>()
                                            .replaceList(numKeys: newInstructions.length);
                                        context.read<IngredientsListCubit>().replaceList(newList: newIngredients);
                                        context
                                            .read<RecipeIngredientKeysCubit>()
                                            .replaceList(numKeys: newIngredients.length);
                                        context.read<RecipeBloc>().add(UpdateRecipe(state.recipe!, recipe));
                                        context.read<AllRecipesBloc>().add(const RecipeAddDeleted());
                                      }
                                    } else {
                                      _shakeController.shake();
                                    }
                                  },
                                  child: ShakeWidget(
                                    controller: _shakeController,
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
                                  child: Container(
                                      padding: EdgeInsets.all(3.w),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Color.fromARGB(255, 78, 3, 27),
                                      )),
                                )
                              : const SizedBox()
                        ],
                      ),
                    ),
                    BlocBuilder<RecipeCategoriesSelectedCubit, List<String>>(
                        builder: (anotherContext, categoriesSelected) {
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
                    Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Row(
                        children: [
                          Text("Prep time: ", style: Centre.listText),
                          state is ViewingRecipe
                              ? Text(state.recipe.prepTime)
                              : SizedBox(
                                  width: 20.w,
                                  child: TextFormField(
                                    key: prepTimeKey,
                                    decoration: const InputDecoration(isDense: true),
                                    style: Centre.recipeText,
                                    controller: prepTimeController,
                                    validator: ((text) {
                                      if (text == null || text.isEmpty) {
                                        return 'Can\'t be empty';
                                      } else if (text.length > 20) {
                                        return 'Too long';
                                      }
                                      return null;
                                    }),
                                  ),
                                )
                        ],
                      ),
                    ),
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
                      List<String> editedIngredientsList = context.read<IngredientsListCubit>().state;

                      return SizedBox(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: state is ViewingRecipe ? 6.w : 3.w, vertical: 2.h),
                          child: MasonryGridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            crossAxisSpacing: 1.w,
                            mainAxisSpacing: 1.h,
                            itemCount: (state is ViewingRecipe) ? ingredients.length : ingredientKeys.length + 1,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return index == ingredientKeys.length
                                  ? GestureDetector(
                                      onTap: () {
                                        context
                                            .read<RecipeIngredientKeysCubit>()
                                            .add(ingredientOrderNumber: -1, numKeys: 1);
                                        context
                                            .read<IngredientsListCubit>()
                                            .add(ingredientOrderNumber: -1, ingredient: "");
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(2.w),
                                        child: const Icon(Icons.add),
                                      ))
                                  : Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                                      .deleteKey(ingredientOrderNumber: index);
                                                  context
                                                      .read<IngredientsListCubit>()
                                                      .delete(ingredientOrderNumber: index);
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
                                                  style: Centre.ingredientText,
                                                  maxLines: 3,
                                                ),
                                              )
                                            : Expanded(
                                                child: RecipeTextField(
                                                  key: ingredientKeys[index],
                                                  ingredientOrderNumber: index,
                                                  type: TextFieldType.ingredient,
                                                  text: editedIngredientsList.isEmpty
                                                      ? ""
                                                      : index >= editedIngredientsList.length
                                                          ? ""
                                                          : editedIngredientsList[index],
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
                                                create: (_) => MultiSelectIngredientsCubit()),
                                            BlocProvider<IngredientToGroceryCategoryHover>(
                                                create: (_) => IngredientToGroceryCategoryHover())
                                          ],
                                          child:
                                              AddToGroceryListDialog(ingredients: state.recipe.ingredients.split('\n')),
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
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: BlocBuilder<RecipeInstructionsKeysCubit, List<GlobalKey<RecipeTextFieldState>>>(
                            builder: (_, instructionsKeys) {
                          List<String> editedInstructionsList = context.read<InstructionsListCubit>().state;

                          return KeyboardVisibilityBuilder(builder: (_, isKeyboardVisible) {
                            if (MediaQuery.of(context).viewInsets.bottom != 0) {
                              if (!isKeyboardVisible) {
                                FocusScope.of(context).unfocus();
                              }
                            }
                            return ReorderableListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                buildDefaultDragHandles: false,
                                onReorder: (oldIndex, newIndex) {
                                  if (state is EditingRecipe) {
                                    if (oldIndex < newIndex) {
                                      newIndex -= 1;
                                    }

                                    context
                                        .read<InstructionsListCubit>()
                                        .reorder(oldIndex: oldIndex, newIndex: newIndex);
                                    context
                                        .read<RecipeInstructionsKeysCubit>()
                                        .reorder(oldIndex: oldIndex, newIndex: newIndex);
                                  }
                                },
                                children: [
                                  for (int i = 0;
                                      i < ((state is ViewingRecipe) ? instructions.length : instructionsKeys.length);
                                      i++)
                                    Column(
                                      key: ValueKey(i),
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: state is EditingRecipe ? 4.w : 2.w,
                                              left: state is EditingRecipe ? 0 : 5.w),
                                          child: Row(
                                            children: [
                                              Column(
                                                spacing: 1.5.h,
                                                children: [
                                                  state is EditingRecipe && !isKeyboardVisible
                                                      ? ReorderableDragStartListener(
                                                          index: i,
                                                          child: const Icon(Icons.drag_handle),
                                                        )
                                                      : const SizedBox(),
                                                  state is EditingRecipe
                                                      ? GestureDetector(
                                                          onTap: () {
                                                            context
                                                                .read<RecipeInstructionsKeysCubit>()
                                                                .deleteKey(stepNumber: i);
                                                            context.read<InstructionsListCubit>().delete(stepNumber: i);
                                                          },
                                                          behavior: HitTestBehavior.translucent,
                                                          child: Padding(
                                                            padding: EdgeInsets.all(2.w),
                                                            child: const Icon(Icons.delete),
                                                          ),
                                                        )
                                                      : const SizedBox(),
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 3.w),
                                                child: Text("${i + 1}", style: Centre.listText),
                                              ),
                                              state is ViewingRecipe
                                                  ? Expanded(
                                                      child: Text(
                                                      instructions[i],
                                                      style: Centre.recipeText,
                                                      maxLines: 7,
                                                    ))
                                                  : Expanded(
                                                      child: RecipeTextField(
                                                        key: instructionsKeys[i],
                                                        stepNumber: i,
                                                        type: TextFieldType.instruction,
                                                        text: editedInstructionsList.isEmpty
                                                            ? ""
                                                            : i >= editedInstructionsList.length
                                                                ? ""
                                                                : editedInstructionsList[i],
                                                      ),
                                                    )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
                                          child: Divider(
                                            color: Centre.dialogBgColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  state is EditingRecipe
                                      ? GestureDetector(
                                          onLongPress: () {},
                                          key: const ValueKey("addbutton"),
                                          onTap: () {
                                            context.read<RecipeInstructionsKeysCubit>().add(stepNumber: -1, numKeys: 1);
                                            context.read<InstructionsListCubit>().add(instruction: "", stepNumber: -1);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.fromLTRB(2.w, 3.h, 2.w, 5.h),
                                            child: const Icon(Icons.add),
                                          ))
                                      : const SizedBox(
                                          key: ValueKey("a box"),
                                        ),
                                ]);
                          });
                        })),
                  ],
                ),
              ),
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
  final int? stepNumber;
  final int? ingredientOrderNumber;
  const RecipeTextField(
      {super.key, this.existingTitles, this.text, this.type, this.stepNumber, this.ingredientOrderNumber});

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
      decoration: const InputDecoration(isDense: true),
      style: Centre.recipeText,
      minLines: 1,
      maxLines: 40,
      contextMenuBuilder: (_, EditableTextState editableTextState) {
        return AdaptiveTextSelectionToolbar.editable(
          anchors: editableTextState.contextMenuAnchors,
          onLiveTextInput: null,
          onLookUp: null,
          onSearchWeb: null,
          onShare: null,
          clipboardStatus: ClipboardStatus.pasteable,
          // to apply the normal behavior when click on copy (copy in clipboard close toolbar)
          // use an empty function `() {}` to hide this option from the toolbar
          onCopy: () {
            editableTextState.copySelection(SelectionChangedCause.toolbar);
          },
          // to apply the normal behavior when click on cut
          onCut: () {
            editableTextState.cutSelection(SelectionChangedCause.toolbar);
          },
          onPaste: () async {
            await editableTextState.pasteText(SelectionChangedCause.toolbar);

            List<String> fields = editableTextState.currentTextEditingValue.text.split('\n');
            fields.removeWhere((value) => value.trim().isEmpty);

            if (widget.type == TextFieldType.ingredient) {
              if (context.mounted) {
                for (int i = 0; i < fields.length; i++) {
                  if (i == 0) {
                    context
                        .read<IngredientsListCubit>()
                        .replace(ingredient: fields[0].trim(), ingredientOrderNumber: widget.ingredientOrderNumber!);
                  } else {
                    context
                        .read<IngredientsListCubit>()
                        .add(ingredient: fields[i].trim(), ingredientOrderNumber: widget.ingredientOrderNumber! + i);
                  }
                }
                context
                    .read<RecipeIngredientKeysCubit>()
                    .add(numKeys: fields.length, ingredientOrderNumber: widget.ingredientOrderNumber!);
              }
            } else if (widget.type == TextFieldType.instruction) {
              if (context.mounted) {
                for (int i = 0; i < fields.length; i++) {
                  if (i == 0) {
                    context
                        .read<InstructionsListCubit>()
                        .replace(instruction: fields[0].trim(), stepNumber: widget.stepNumber!);
                  } else {
                    context
                        .read<InstructionsListCubit>()
                        .add(instruction: fields[i].trim(), stepNumber: widget.stepNumber! + i);
                  }
                }
                context.read<RecipeInstructionsKeysCubit>().add(numKeys: fields.length, stepNumber: widget.stepNumber!);
              }
            }
          },
          // to apply the normal behavior when click on select all
          onSelectAll: null,
        );
      },
      controller: controller,
      validator: (text) {
        if (text == null || text.isEmpty) {
          return 'Can\'t be empty';
        } else if (text.length > 300) {
          return 'Too long';
        } else if ((widget.existingTitles?.contains(text) ?? false) && widget.text != text) {
          return 'Title already exists';
        }
        return null;
      },
    );
  }
}
