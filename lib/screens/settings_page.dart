import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/utils/centre.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  List<Widget> changeCategoryArea() {
    return 
    );
  }

  @override
  Widget build(BuildContext context) {
    Centre().init(context);

    return SafeArea(
        child: Scaffold(
      backgroundColor: Centre.bgColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Settings",
            style: Centre.titleText,
          ),
        ],
      ),
    ));
  }
}
