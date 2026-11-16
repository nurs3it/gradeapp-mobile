import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Last good server answer per key, one file each in the app support dir.
/// Lets every screen open instantly (and offline) with what was seen last.
/// ponytail: file per key, no eviction — data is a few KB per screen; move to
/// sqlite/drift if the cache grows past a few MB.
class JsonCache {
  JsonCache._(this._dir);

  final Directory _dir;
  final _memory = <String, Object?>{};

  /// [name] separates stores: `api_cache` (wiped on sign-out) and `prefs`.
  static Future<JsonCache> open([String name = 'api_cache']) async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/$name');
    await dir.create(recursive: true);
    return JsonCache._(dir);
  }

  File _file(String key) => File('${_dir.path}/${base64Url.encode(utf8.encode(key))}.json');

  Future<Object?> read(String key) async {
    if (_memory.containsKey(key)) return _memory[key];
    final f = _file(key);
    if (!await f.exists()) return null;
    try {
      return _memory[key] = jsonDecode(await f.readAsString());
    } on FormatException {
      return null;
    }
  }

  Future<void> write(String key, Object? data) async {
    _memory[key] = data;
    await _file(key).writeAsString(jsonEncode(data));
  }

  /// Sign-out: another account must never see this one's data.
  Future<void> clear() async {
    _memory.clear();
    if (await _dir.exists()) await _dir.delete(recursive: true);
    await _dir.create(recursive: true);
  }
}
