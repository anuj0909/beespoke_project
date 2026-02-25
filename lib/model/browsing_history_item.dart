class BrowsingHistoryItem {
  final int? id;
  final String url;
  final String pageTitle;
  final int productId;
  final String productTitle;
  final DateTime visitedAt;

  const BrowsingHistoryItem({
    this.id,
    required this.url,
    required this.pageTitle,
    required this.productId,
    required this.productTitle,
    required this.visitedAt,
  });



  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'url': url,
    'pageTitle': pageTitle,
    'productId': productId,
    'productTitle': productTitle,
    'visitedAt': visitedAt.toIso8601String(),
  };

  factory BrowsingHistoryItem.fromMap(Map<String, dynamic> map) {
    return BrowsingHistoryItem(
      id: map['id'] as int?,
      url: map['url'] as String,
      pageTitle: map['pageTitle'] as String,
      productId: map['productId'] as int,
      productTitle: map['productTitle'] as String,
      visitedAt: DateTime.parse(map['visitedAt'] as String),
    );
  }



  String get timeAgo {
    final diff = DateTime.now().difference(visitedAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  String get displayUrl {
    try {
      final uri = Uri.parse(url);
      return uri.host + (uri.path.isNotEmpty ? uri.path : '');
    } catch (_) {
      return url;
    }
  }

  @override
  String toString() =>
      'BrowsingHistoryItem(id: $id, url: $url, visitedAt: $visitedAt)';
}