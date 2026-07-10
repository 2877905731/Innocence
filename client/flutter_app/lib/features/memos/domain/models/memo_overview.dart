class MemoOverview {
  const MemoOverview({
    required this.totalCount,
    required this.items,
  });

  final int totalCount;
  final List<MemoCardModel> items;

  factory MemoOverview.empty() {
    return const MemoOverview(
      totalCount: 0,
      items: [],
    );
  }

  factory MemoOverview.fromJson(dynamic json) {
    if (json is List<dynamic>) {
      return MemoOverview(
        totalCount: json.length,
        items: json
            .whereType<Map<String, dynamic>>()
            .map(MemoCardModel.fromJson)
            .toList(),
      );
    }
    if (json is! Map<String, dynamic>) {
      return MemoOverview.empty();
    }
    final itemsJson = json['list'] as List<dynamic>? ?? const [];
    return MemoOverview(
      totalCount: _toInt(json['totalCount'], fallback: itemsJson.length),
      items: itemsJson
          .whereType<Map<String, dynamic>>()
          .map(MemoCardModel.fromJson)
          .toList(),
    );
  }

  bool get hasItems => items.isNotEmpty;

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    return int.tryParse('$value') ?? fallback;
  }
}

class MemoCardModel {
  const MemoCardModel({
    required this.memoId,
    required this.title,
    required this.content,
    required this.totalItemCount,
    required this.checkedItemCount,
    required this.updateTime,
    required this.checkItems,
  });

  final int memoId;
  final String title;
  final String content;
  final int totalItemCount;
  final int checkedItemCount;
  final String updateTime;
  final List<MemoCheckItemModel> checkItems;

  factory MemoCardModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['checkItems'] as List<dynamic>? ?? const [];
    return MemoCardModel(
      memoId: MemoOverview._toInt(json['memoId']),
      title: '${json['title'] ?? ''}',
      content: '${json['content'] ?? ''}',
      totalItemCount: MemoOverview._toInt(json['totalItemCount']),
      checkedItemCount: MemoOverview._toInt(json['checkedItemCount']),
      updateTime: '${json['updateTime'] ?? ''}',
      checkItems: itemsJson
          .whereType<Map<String, dynamic>>()
          .map(MemoCheckItemModel.fromJson)
          .toList(),
    );
  }

  String get displayTitle {
    if (title.trim().isNotEmpty) {
      return title.trim();
    }
    if (content.trim().isNotEmpty) {
      return content.trim().split('\n').first;
    }
    return 'Untitled memo';
  }

  bool get hasChecklist => totalItemCount > 0 || checkItems.isNotEmpty;

  String get progressLabel {
    if (!hasChecklist) {
      return 'Text memo';
    }
    return '$checkedItemCount/$totalItemCount checked';
  }

  String get summaryText {
    if (content.trim().isNotEmpty) {
      return content.trim();
    }
    if (checkItems.isNotEmpty) {
      return checkItems.map((item) => item.itemText).join('  ');
    }
    return 'No content yet';
  }

  MemoCardModel copyWith({
    int? memoId,
    String? title,
    String? content,
    int? totalItemCount,
    int? checkedItemCount,
    String? updateTime,
    List<MemoCheckItemModel>? checkItems,
  }) {
    return MemoCardModel(
      memoId: memoId ?? this.memoId,
      title: title ?? this.title,
      content: content ?? this.content,
      totalItemCount: totalItemCount ?? this.totalItemCount,
      checkedItemCount: checkedItemCount ?? this.checkedItemCount,
      updateTime: updateTime ?? this.updateTime,
      checkItems: checkItems ?? this.checkItems,
    );
  }

  Map<String, dynamic> toSaveJson() {
    return {
      'title': title,
      'content': content,
      'checkItemList': checkItems.map((item) => item.toSaveJson()).toList(),
    };
  }
}

class MemoCheckItemModel {
  const MemoCheckItemModel({
    required this.id,
    required this.itemText,
    required this.checked,
    required this.sortNo,
  });

  final int id;
  final String itemText;
  final bool checked;
  final int sortNo;

  factory MemoCheckItemModel.fromJson(Map<String, dynamic> json) {
    return MemoCheckItemModel(
      id: MemoOverview._toInt(json['id']),
      itemText: '${json['itemText'] ?? ''}',
      checked: json['checked'] == true || json['checked'] == 1,
      sortNo: MemoOverview._toInt(json['sortNo']),
    );
  }

  MemoCheckItemModel copyWith({
    int? id,
    String? itemText,
    bool? checked,
    int? sortNo,
  }) {
    return MemoCheckItemModel(
      id: id ?? this.id,
      itemText: itemText ?? this.itemText,
      checked: checked ?? this.checked,
      sortNo: sortNo ?? this.sortNo,
    );
  }

  Map<String, dynamic> toSaveJson() {
    return {
      'itemText': itemText,
      'checked': checked,
    };
  }
}
