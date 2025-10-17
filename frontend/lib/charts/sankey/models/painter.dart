import 'dart:ui';

import 'package:sprout/charts/sankey/models/data.dart';
import 'package:sprout/charts/sankey/models/link.dart';

/// Provides all the data required to render a sankey with pre-computed data
class SankeyPainterData {
  final SankeyData sankeyData;
  final Map<String, Rect> nodeRects;
  final Map<SankeyLink, Path> linkPaths;
  final Map<String, double> nodeValues;

  SankeyPainterData({
    required this.sankeyData,
    required this.nodeRects,
    required this.linkPaths,
    required this.nodeValues,
  });

  List<SankeyLink> get links => sankeyData.links;
}
