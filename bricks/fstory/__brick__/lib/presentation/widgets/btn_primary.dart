import 'package:flutter/material.dart';
import 'package:{{appName.snakeCase()}}/common/styles.dart';

class BtnPrimary extends StatelessWidget {
  final String title;
  final void Function() onClick;

  const BtnPrimary({super.key, required this.title, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(100)),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [primaryColor, secondaryColor])),
      child: TextButton(
        onPressed: onClick,
        child: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: secondaryGray),
        ),
      ),
    );
  }
}
