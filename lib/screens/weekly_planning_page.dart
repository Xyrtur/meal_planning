import 'package:flutter/material.dart';

class WeeklyPlanningPage extends StatelessWidget {
  const WeeklyPlanningPage({super.key});

  Widget dayTile(String dayText) {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text(
      "meow",
      style: TextStyle(color: Colors.white),
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