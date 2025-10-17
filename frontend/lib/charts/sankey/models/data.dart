import 'package:sprout/charts/sankey/models/link.dart';

/// Represents the complete dataset for a Sankey diagram, including all nodes and links.
class SankeyData {
  final List<String> nodes;
  final List<SankeyLink> links;
  final Map<String, String> colors;

  SankeyData({required this.nodes, required this.links, required this.colors});

  factory SankeyData.fromJson(Map<String, dynamic> json) {
    return SankeyData(
      nodes: (json['nodes'] as List<dynamic>).map((e) => e as String).toList(),
      links: (json['links'] as List<dynamic>).map((e) => SankeyLink.fromJson(e as Map<String, dynamic>)).toList(),
      colors: Map<String, String>.from(json['colors'] as Map),
    );
  }

  Map<String, dynamic> toJson() => {'nodes': nodes, 'links': links.map((e) => e.toJson()).toList()};
}
