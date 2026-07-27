import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../app_helper/app_extension.dart';

class UnknownRoute extends StatelessWidget {
  const UnknownRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: context.height,
        width: context.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.warning, size: 150),
            Text('router.unknown.title'.tr()),
            Text('router.unknown.subtitle'.tr()),
          ],
        ),
      ),
    );
  }
}
