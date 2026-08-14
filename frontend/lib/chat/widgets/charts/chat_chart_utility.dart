/// Utility functions for the charts within the chat
class ChatChartUtility {
  /// Strips markdown formatting characters (like **, *, _, #) from strings
  static String sanitizeChartText(String? input, {String defaultValue = ''}) {
    if (input == null || input.isEmpty) return defaultValue;
    return input.replaceAll(RegExp(r'[\*\_\`\#]'), '').trim();
  }
}
