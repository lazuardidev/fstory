import 'package:flutter/material.dart';
import 'package:fstory/common/styles.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: primaryColor),
    );
  }
}
