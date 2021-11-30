import 'package:flutter/material.dart';

class StudyButton extends StatelessWidget {
  //final bool isActive;
  final VoidCallback onPress;

  const StudyButton({
    //required this.isActive,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: Theme.of(context).backgroundColor),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GestureDetector(
            child: Text(
              'Study this deck',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            onTap: onPress,
          ),
        ),
      ),
    );
  }
}
