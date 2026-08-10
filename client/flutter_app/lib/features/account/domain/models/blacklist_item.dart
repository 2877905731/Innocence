class BlacklistItem {
  const BlacklistItem({
    required this.blockedUserId,
    required this.createTime,
  });

  final int blockedUserId;
  final String createTime;

  factory BlacklistItem.fromJson(Map<String, dynamic> json) {
    return BlacklistItem(
      blockedUserId: _toInt(json['blockedUserId']),
      createTime: '${json['createTime'] ?? ''}',
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse('$value') ?? 0;
  }
}
