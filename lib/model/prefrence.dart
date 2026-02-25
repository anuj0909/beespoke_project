enum PreferenceType { liked, disliked }

extension PreferenceTypeX on PreferenceType {
  int get value => this == PreferenceType.liked ? 1 : 0;
  String get label => this == PreferenceType.liked ? 'Liked' : 'Disliked';

  static PreferenceType fromInt(int v) =>
      v == 1 ? PreferenceType.liked : PreferenceType.disliked;
}

class Preference {
  final int productId;
  final String productTitle;
  final String productImage;
  final double productPrice;
  final PreferenceType type;
  final DateTime createdAt;

  const Preference({
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.productPrice,
    required this.type,
    required this.createdAt,
  });


  Map<String, dynamic> toMap() => {
    'productId': productId,
    'type': type.value,
    'productTitle': productTitle,
    'productImage': productImage,
    'productPrice': productPrice,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Preference.fromMap(Map<String, dynamic> map) {
    return Preference(
      productId: map['productId'] as int,
      type: PreferenceTypeX.fromInt(map['type'] as int),
      productTitle: map['productTitle'] as String,
      productImage: map['productImage'] as String,
      productPrice: (map['productPrice'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }


  String get formattedPrice => '\$${productPrice.toStringAsFixed(2)}';

  bool get isLiked => type == PreferenceType.liked;
  bool get isDisliked => type == PreferenceType.disliked;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Preference && productId == other.productId;

  @override
  int get hashCode => productId.hashCode;
}