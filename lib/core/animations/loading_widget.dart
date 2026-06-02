import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {

  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return const Center(

      child: CircularProgressIndicator(

        color: Color(0xFFD4AF37),
      ),
    );
  }
}