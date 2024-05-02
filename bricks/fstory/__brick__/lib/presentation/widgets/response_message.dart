import 'package:flutter/material.dart';

class ResponseMessage extends StatelessWidget {
  final String image;
  final String message;
  final Function()? onPressed;

  const ResponseMessage({
    super.key,
    required this.image,
    required this.message,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            height: 150,
            width: 150,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (onPressed != null)
            ElevatedButton(
              onPressed: onPressed,
              child: const Text(
                'Refresh',
                style: TextStyle(color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }
}
