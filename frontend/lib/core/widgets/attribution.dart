import 'package:flutter/material.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:url_launcher/url_launcher.dart';

/// Generic component that allows easy attribution
class AttributionWidget extends StatelessWidget {
  final String url;
  final String text;
  final String? imageUrl;

  const AttributionWidget({Key? key, required this.url, required this.text, this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final Uri url = Uri.parse(this.url);
          if (!await launchUrl(url)) {
            throw Exception('Could not launch $url');
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageUrl != null) ...[
              Image.network(
                imageUrl!,
                height: 24, // Adjust height as needed
              ),
              const SizedBox(width: 8), // Spacing between image and text
            ],
            TextWidget(referenceSize: 1.25, text: text),
          ],
        ),
      ),
    );
  }
}
