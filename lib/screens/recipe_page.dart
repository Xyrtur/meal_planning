import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/blocs/recipe_bloc.dart';
import 'package:meal_planning/blocs/settings_bloc.dart';
import 'package:meal_planning/models/recipe.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:meal_planning/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:meal_planning/widgets/dialogs/filter_category_dialog.dart.dart';
import 'package:sizer/sizer.dart';

class RecipePage extends StatelessWidget {
  final List<String> existingRecipeTitles;
  RecipePage({super.key, required this.existingRecipeTitles});
  // List of keys will let us validate all their controllers at once when user is finished editing
  final GlobalKey<RecipeTextFieldState> titleKey = GlobalKey<RecipeTextFieldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ValueNotifier<bool?> deletingRecipe = ValueNotifier<bool?>(false);

  @override
  Widget build(BuildContext context) {
    deletingRecipe.addListener(() {
      if (deletingRecipe.value ?? false) Navigator.pop(context);
    });

    return SafeArea(child: Scaffold(
      body: BlocBuilder<RecipeBloc, RecipeState>(builder: (_, state) {
        List<String> ingredients = state.recipe?.ingredients.split('\n') ?? [];
        List<String> instructions = state.recipe?.instructions.split('\n') ?? [];

        return Form(
          key: formKey,
          child: Column(
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
                          ),
                        )
                      : RecipeTextField(
                          key: titleKey,
                          text: (state as EditingRecipe).recipe?.title,
                          existingTitles: existingRecipeTitles,
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
                              } else {
                                Recipe recipe = state.recipe!;
                                recipe.edit(
                                    title: titleKey.currentState!.controller.text,
                                    ingredients: newIngredients.join("\n"),
                                    instructions: newInstructions.join("\n"),
                                    categories: context.read<RecipeCategoriesSelectedCubit>().state);

                                context.read<RecipeBloc>().add(UpdateRecipe(state.recipe!, recipe));
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
              Row(
                children: [
                  const Spacer(),
                  Wrap(
                    children: [
                      for (String category in state.recipe?.categories ?? [])
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 4.w),
                          decoration: BoxDecoration(
                            color:
                                Color(context.read<SettingsBloc>().state.recipeCategoriesMap[category]!).withAlpha(100),
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
                                    offset: Offset(1.w, 0),
                                    context: context,
                                    builder: (BuildContext dialogContext) => GestureDetector(
                                          onTap: () => Navigator.pop(dialogContext),
                                          child: Scaffold(
                                            backgroundColor: Colors.transparent,
                                            body: BlocProvider<RecipeCategoriesSelectedCubit>(
                                              create: (_) =>
                                                  RecipeCategoriesSelectedCubit(state.recipe?.categories ?? []),
                                              child: FilterCategoryDialog(
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
                  const Spacer()
                ],
              ),
              BlocBuilder<RecipeIngredientKeysCubit, List<GlobalKey<RecipeTextFieldState>>>(
                  builder: (context, ingredientKeys) {
                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 2.w,
                  mainAxisSpacing: 2.h,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (int i = 0; i < ((state is ViewingRecipe) ? ingredients.length : ingredientKeys.length); i++)
                      Row(
                        children: [
                          state is ViewingRecipe
                              ? const Text(
                                  ' \u2022 ',
                                  textHeightBehavior: TextHeightBehavior(
                                      applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    context.read<RecipeIngredientKeysCubit>().deleteKey(key: ingredientKeys[i]);
                                  },
                                  behavior: HitTestBehavior.translucent,
                                  child: Padding(
                                    padding: EdgeInsets.all(2.w),
                                    child: const Icon(Icons.delete),
                                  ),
                                ),
                          state is ViewingRecipe
                              ? Text(ingredients[i])
                              : RecipeTextField(
                                  key: ingredientKeys[i],
                                  type: TextFieldType.ingredient,
                                  text: ingredients[i],
                                )
                        ],
                      ),
                    state is EditingRecipe
                        ? GestureDetector(
                            onTap: () {
                              context.read<RecipeIngredientKeysCubit>().addKey();
                            },
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              child: const Icon(Icons.add),
                            ))
                        : const SizedBox()
                  ],
                );
              }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Steps", style: Centre.titleText),
                  state is ViewingRecipe
                      ? GestureDetector(
                          onTap: () {
                            // TODO: open grocery dialog
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
              BlocBuilder<RecipeInstructionsKeysCubit, List<GlobalKey<RecipeTextFieldState>>>(
                  builder: (context, instructionsKeys) {
                return Column(children: [
                  for (int i = 0; i < ((state is ViewingRecipe) ? instructions.length : instructionsKeys.length); i++)
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
                        Text("$i"),
                        SizedBox(
                          width: 3.w,
                        ),
                        state is ViewingRecipe
                            ? Text(instructions[i])
                            : RecipeTextField(
                                key: instructionsKeys[i],
                                type: TextFieldType.instruction,
                                text: instructions[i],
                              )
                      ],
                    )
                ]);
              }),
              state is EditingRecipe
                  ? GestureDetector(
                      onTap: () {
                        context.read<RecipeInstructionsKeysCubit>().addKey();
                      },
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        child: const Icon(Icons.add),
                      ))
                  : const SizedBox()
            ],
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
    controller.addListener(() {
      if ((controller.text.length - length).abs() > 1) {
        List<String> fields = controller.text.split('\n');
        if (widget.type == TextFieldType.ingredient) {
          for (String newText in fields) {
            GlobalKey<RecipeTextFieldState> createdKey = context.read<RecipeIngredientKeysCubit>().addKey();
            createdKey.currentState!.controller.text = newText;
          }
        } else if (widget.type == TextFieldType.instruction) {
          for (String newText in fields) {
            GlobalKey<RecipeTextFieldState> createdKey = context.read<RecipeInstructionsKeysCubit>().addKey();
            createdKey.currentState!.controller.text = newText;
          }
        }
      }
      length = controller.text.length;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (text) {
        if (text == null || text.isEmpty) {
          return 'Can\'t be empty';
        } else if (text.length > 50) {
          return 'Too long';
        } else if (widget.existingTitles?.contains(text) ?? false) {
          return 'Title already exists';
        }
        return null;
      },
    );
  }
}
