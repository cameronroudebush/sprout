/// Represents a link in a Sankey diagram, showing the flow of value from a source to a target.
class SankeyLink {
  final String source;
  final String target;
  final double value;
  final String? description;

  SankeyLink({required this.source, required this.target, required this.value, this.description});

  factory SankeyLink.fromJson(Map<String, dynamic> json) {
    return SankeyLink(
      source: json['source'] as String,
      target: json['target'] as String,
      value: (json['value'] as num).toDouble(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'source': source, 'target': target, 'value': value, 'description': description};
  }
}
