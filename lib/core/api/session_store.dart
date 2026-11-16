import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tokens of the signed-in account. The backend rotates the refresh token on
/// every use, so the new one must be persisted before anything else runs.
class Session {
  const Session({
    required this.access,
    required this.refresh,
    required this.sessionId,
  });

  final String access;
  final String refresh;
  final String sessionId;

  Session copyWith({String? access, String? refresh}) => Session(
        access: access ?? this.access,
        refresh: refresh ?? this.refresh,
        sessionId: sessionId,
      );

  Map<String, String> toJson() =>
      {'access': access, 'refresh': refresh, 'session_id': sessionId};

  static Session? fromJson(Map<String, dynamic> j) {
    final refresh = j['refresh'] as String?;
    final sid = j['session_id'] as String?;
    if (refresh == null || sid == null) return null;
    return Session(
      access: (j['access'] as String?) ?? '',
      refresh: refresh,
      sessionId: sid,
    );
  }
}

/// Keychain / Keystore-backed storage. Memory copy avoids a platform-channel
/// hop on every request.
class SessionStore {
  SessionStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'session';
  final FlutterSecureStorage _storage;
  Session? _current;

  Session? get current => _current;

  Future<Session?> load() async {
    final raw = await _storage.read(key: _key);
    _current = raw == null
        ? null
        : Session.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    return _current;
  }

  Future<void> save(Session s) async {
    _current = s;
    await _storage.write(key: _key, value: jsonEncode(s.toJson()));
  }

  Future<void> clear() async {
    _current = null;
    await _storage.delete(key: _key);
  }
}
