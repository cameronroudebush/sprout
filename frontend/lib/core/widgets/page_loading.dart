import 'package:flutter/material.dart';
import 'package:sprout/core/widgets/layout.dart';

/// This widget helps consume the entire space while showing the page is loading data
class PageLoadingWidget extends StatelessWidget {
  static const String defaultLoadingText = "Data is loading...";

  final String loadingText;
  const PageLoadingWidget({super.key, this.loadingText = PageLoadingWidget.defaultLoadingText});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return SproutLayoutBuilder((isDesktop, context, constraints) {
      return SizedBox(
        height: mediaQuery.height - (isDesktop ? 48 : 196),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 24,
          children: [
            CircularProgressIndicator(),
            Text(
              loadingText,
              style: TextStyle(fontSize: isDesktop ? 36 : 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    });
  }
}
