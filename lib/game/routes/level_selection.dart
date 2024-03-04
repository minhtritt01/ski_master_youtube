import 'package:flutter/material.dart';

class LevelSelection extends StatelessWidget {
  const LevelSelection({super.key, this.onLevelSelected, this.onBackPressed});
  final ValueChanged<int>? onLevelSelected;
  final VoidCallback? onBackPressed;
  static const id = 'level-selection';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Level Selection',
          style: TextStyle(fontSize: 30.0),
        ),
        const SizedBox(
          height: 15.0,
        ),
        Flexible(
            child: GridView.builder(
          shrinkWrap: true,
          itemCount: 6,
          padding: const EdgeInsets.symmetric(horizontal: 100.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisExtent: 50.0,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0),
          itemBuilder: (context, index) {
            return OutlinedButton(
                onPressed: () => onLevelSelected?.call(index + 1),
                child: Text('Level ${index + 1}'));
          },
        )),
        const SizedBox(
          height: 5.0,
        ),
        IconButton(onPressed: onBackPressed, icon: const Icon(Icons.arrow_back))
      ],
    )));
  }
}
