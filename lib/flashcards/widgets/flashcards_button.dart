import 'package:flutter/material.dart';

class FlashcardsButton extends StatelessWidget {
  final bool isVisible;
  final String title;
  final Icon? icon;
  final VoidCallback onTap;

  const FlashcardsButton({
    required this.isVisible,
    required this.title,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: RawMaterialButton(
          fillColor: Theme.of(context).backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          shape: const StadiumBorder(),
          elevation: 0,
          child: icon ??
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontSize: 24),
              ),
          onPressed: onTap,
        ),
      ),
    );
  }
}
