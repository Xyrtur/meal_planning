import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/all_recipes_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/blocs/grocery_bloc.dart';
import 'package:meal_planning/blocs/import_export_bloc.dart';
import 'package:meal_planning/blocs/recipe_bloc.dart';
import 'package:meal_planning/blocs/settings_bloc.dart';
import 'package:meal_planning/screens/recipe_page.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:meal_planning/utils/hive_repository.dart';
import 'package:r_dotted_line_border/r_dotted_line_border.dart';
import 'package:sizer/sizer.dart';

class AllRecipesPage extends StatelessWidget {
  const AllRecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Centre.bgColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Row(
              children: [
                Text("Recipes", style: Centre.titleText),
                const Spacer(),
                GestureDetector(
                    onTap: () {
                      GlobalKey<RecipeTextFieldState> createdKey =
                          GlobalKey<RecipeTextFieldState>();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => MultiBlocProvider(
                                providers: [
                                  BlocProvider<RecipeBloc>(
                                    create: (_) => RecipeBloc(
                                        context.read<HiveRepository>(), null),
                                  ),
                                  BlocProvider<RecipeCategoriesSelectedCubit>(
                                    create: (_) =>
                                        RecipeCategoriesSelectedCubit([]),
                                  ),
                                  BlocProvider<RecipeIngredientKeysCubit>(
                                    create: (_) => RecipeIngredientKeysCubit(
                                        [GlobalKey<RecipeTextFieldState>()]),
                                  ),
                                  BlocProvider<RecipeInstructionsKeysCubit>(
                                    create: (_) => RecipeInstructionsKeysCubit(
                                        [GlobalKey<RecipeTextFieldState>()]),
                                  ),
                                  BlocProvider.value(
                                    value: context.read<GroceryBloc>(),
                                  ),
                                  BlocProvider.value(
                                    value: context.read<SettingsBloc>(),
                                  ),
                                  BlocProvider<RecipeCategoriesSelectedCubit>(
                                    create: (_) =>
                                        RecipeCategoriesSelectedCubit([]),
                                  ),
                                  BlocProvider<InstructionsListCubit>(
                                    create: (_) => InstructionsListCubit([]),
                                  ),
                                  BlocProvider<IngredientsListCubit>(
                                    create: (_) => IngredientsListCubit([]),
                                  ),
                                  BlocProvider.value(
                                    value: context.read<AllRecipesBloc>(),
                                  ),
                                ],
                                child: RecipePage(
                                    titleKey: createdKey,
                                    existingRecipeTitles: context
                                        .read<HiveRepository>()
                                        .recipeTitlestoRecipeMap
                                        .keys
                                        .toList()),
                              )));
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                        ),
                        child: Icon(Icons.add)))
              ],
            ),
          ),
          const FilterArea(),
          const RecipeSearchbar(),
          RecipeListview(
            isWeeklyPlanning: false,
          )
        ],
      ),
    ));
  }
}

class FilterArea extends StatelessWidget {
  const FilterArea({super.key});

  Widget filterBtn(
      {required int? color,
      required String name,
      required BuildContext context}) {
    return GestureDetector(
      onTap: () {
        context.read<AllRecipesBloc>().add(FilterToggle(name));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: Color(color ?? Colors.grey.value).withAlpha(100),
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          border: RDottedLineBorder.all(
            color: Color(color ?? Colors.grey.value),
            width: 0.5.w,
          ),
        ),
        child: Text(name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, settingsState) {
        context.read<AllRecipesBloc>().add(const CategoryUpdated());
      },
      child: BlocBuilder<AllRecipesBloc, AllRecipesState>(
          buildWhen: (previous, current) {
        return current is FiltersChanged;
      }, builder: (context, state) {
        return Wrap(spacing: 2.w, runSpacing: 1.h, children: [
          Text(
            "Filters:",
            style: Centre.semiTitleText,
          ),
          for (MapEntry<String, int?> item in state.toggledCategories.entries)
            filterBtn(color: item.value, name: item.key, context: context)
        ]);
      }),
    );
  }
}

class RecipeSearchbar extends StatefulWidget {
  const RecipeSearchbar({super.key});

  @override
  State<RecipeSearchbar> createState() => _RecipeSearchbarState();
}

class _RecipeSearchbarState extends State<RecipeSearchbar> {
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
        child: Row(
          children: [
            GestureDetector(
                onTap: () {
                  context
                      .read<AllRecipesBloc>()
                      .add(SearchClicked(textController.text));
                },
                child: const Icon(Icons.search)),
            Expanded(
                child: TextField(
              controller: textController,
            ))
          ],
        ));
  }
}

class RecipeListview extends StatelessWidget {
  final bool isWeeklyPlanning;
  RecipeListview({super.key, required this.isWeeklyPlanning});
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ImportExportBloc, ImportExportState>(
      listener: (context, state) {
        if (state is ImportFinished) {
          context.read<AllRecipesBloc>().add(const RecipesImported());
        }
      },
      child: Expanded(
        child: BlocConsumer<AllRecipesBloc, AllRecipesState>(
            listener: (context, state) {
          if (state is OpeningRecipePage) {
            if (isWeeklyPlanning) {
              Navigator.pop(context, state.recipe.title);
            } else {
              List<String> ingredients = state.recipe.ingredients.split('\n');
              List<String> instructions = state.recipe.instructions.split('\n');
              final List<GlobalKey<RecipeTextFieldState>> ingredientKeys = [];
              final List<GlobalKey<RecipeTextFieldState>> instructionKeys = [];
              // TextFields for each ingredient
              for (int i = 0; i < ingredients.length; i++) {
                ingredientKeys.add(GlobalKey<RecipeTextFieldState>());
              }

              // TextFields for each instruction step
              for (int i = 0; i < instructions.length; i++) {
                instructionKeys.add(GlobalKey<RecipeTextFieldState>());
              }

              GlobalKey<RecipeTextFieldState> createdKey =
                  GlobalKey<RecipeTextFieldState>();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider<RecipeBloc>(
                              create: (_) => RecipeBloc(
                                  context.read<HiveRepository>(), state.recipe),
                            ),
                            BlocProvider<RecipeCategoriesSelectedCubit>(
                              create: (_) => RecipeCategoriesSelectedCubit(
                                  state.recipe.categories),
                            ),
                            BlocProvider<RecipeIngredientKeysCubit>(
                              create: (_) =>
                                  RecipeIngredientKeysCubit(ingredientKeys),
                            ),
                            BlocProvider<RecipeInstructionsKeysCubit>(
                              create: (_) =>
                                  RecipeInstructionsKeysCubit(instructionKeys),
                            ),
                            BlocProvider.value(
                              value: context.read<GroceryBloc>(),
                            ),
                            BlocProvider.value(
                              value: context.read<SettingsBloc>(),
                            ),
                            BlocProvider<RecipeCategoriesSelectedCubit>(
                              create: (_) => RecipeCategoriesSelectedCubit(
                                  state.recipe.categories),
                            ),
                            BlocProvider<InstructionsListCubit>(
                              create: (_) =>
                                  InstructionsListCubit(instructions),
                            ),
                            BlocProvider<IngredientsListCubit>(
                              create: (_) => IngredientsListCubit(ingredients),
                            ),
                            BlocProvider.value(
                              value: context.read<AllRecipesBloc>(),
                            ),
                          ],
                          child: RecipePage(
                              titleKey: createdKey,
                              existingRecipeTitles: context
                                  .read<HiveRepository>()
                                  .recipeTitlestoRecipeMap
                                  .keys
                                  .toList()))));
            }
          }
        }, buildWhen: (previous, current) {
          return current is! OpeningRecipePage;
        }, builder: (context, state) {
          List<String> sortedRecipeNames = state.filteredRecipeMap.keys.toList()
            ..sort();
          return RawScrollbar(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            trackVisibility: true,
            thumbVisibility: true,
            controller: scrollController,
            thumbColor: Centre.primaryColor.withAlpha(200),
            radius: const Radius.circular(8),
            thickness: 0.5.h,
            child: ListView.builder(
                controller: scrollController,
                itemCount: state.filteredRecipeMap.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      context
                          .read<AllRecipesBloc>()
                          .add(RecipeClicked(sortedRecipeNames[index]));
                    },
                    behavior: HitTestBehavior.translucent,
                    child: ListTile(
                      title: Text(sortedRecipeNames[index]),
                      subtitle: Wrap(
                        spacing: 2.w,
                        runSpacing: 0.5.h,
                        children: [
                          for (int value in state
                              .filteredRecipeMap[sortedRecipeNames[index]]!)
                            Container(
                              width: 2.w,
                              height: 2.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color(value),
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                }),
          );
        }),
      ),
    );
  }
}
