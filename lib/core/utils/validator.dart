class Validators {
  Validators._();


  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }


  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }


  static bool isValidPrice(double? price) {
    return price != null && price > 0;
  }


  static bool isValidRating(double? rating) {
    return rating != null && rating >= 0 && rating <= 5;
  }


  static String sanitiseTitle(String title) {
    return title.trim().replaceAll(RegExp(r'\s+'), ' ');
  }


  static String truncate(String text, {int maxLength = 60}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength).trimRight()}…';
  }

  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  static String capitalise(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}