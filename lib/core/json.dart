/// Tiny helpers for hand-written `fromJson` factories.
/// ponytail: no codegen — read models are small; add json_serializable when
/// models start needing `toJson`/`copyWith` in bulk.
typedef Json = Map<String, dynamic>;

extension JsonRead on Json {
  String str(String key) => (this[key] as Object?)?.toString() ?? '';
  String? strOrNull(String key) {
    final v = this[key] as Object?;
    return v == null || v == '' ? null : v.toString();
  }

  bool flag(String key) => this[key] == true;
  num? number(String key) {
    final v = this[key] as Object?;
    return v is num ? v : num.tryParse('${v ?? ''}');
  }

  List<T> list<T>(String key, T Function(Json) parse) =>
      ((this[key] as List<dynamic>?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(parse)
          .toList(growable: false);

  List<String> strings(String key) =>
      ((this[key] as List<dynamic>?) ?? const []).map((e) => '$e').toList();
}

/// DRF answers either a plain list or a paginated `{results: [...]}` envelope.
List<Json> resultsOf(Object? data) {
  final raw = data is Map<String, dynamic> ? data['results'] : data;
  return (raw as List<dynamic>? ?? const []).whereType<Json>().toList();
}
