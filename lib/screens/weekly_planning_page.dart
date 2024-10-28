import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/weekly_planning_bloc.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:meal_planning/utils/hive_repository.dart';
import 'package:r_dotted_line_border/r_dotted_line_border.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class WeeklyPlanningPage extends StatelessWidget {
  const WeeklyPlanningPage({super.key});

  Widget weekRangeHeader(BuildContext context) {
    // on initial on weekRangepressed, rebuild
    return BlocBuilder<WeeklyPlanningBloc, WeeklyPlanningState>(
        builder: (context, state) => Container());
  }

  Widget mealTile(String mealName, BuildContext context) {
    final hive = context.read<HiveRepository>();
    return Container(
      decoration: BoxDecoration(
        color: mealName.isEmpty
            ? Colors.grey
            : Color(hive.recipeCategoriesMap[
                hive.recipeTitlestoRecipeMap[mealName]!.category]!),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: RDottedLineBorder.all(
          width: 1,
        ),
      ),
      child: Text(
        mealName,
        textAlign: TextAlign.end,
      ),
    );
  }

  Widget dayTile(
      String dayText, List<String> mealsInDay, BuildContext context) {
    return Container(
      width: Centre.safeBlockHorizontal * 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(dayText),
          for (int i = 0; i < 5; i++) mealTile(mealsInDay[i], context)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Centre.bgColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [],
      ),
    ));
  }
}


/*
 * Column --
 * Container > Row > 3x Container >3x Text
 * Row > Column x2 
 * First col > []
 * Second col > SizedBox > 
 */